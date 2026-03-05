//
//  CameraFaceOverlayView.swift
//  FaceFollow
//
//  Created by Pok fun Tse on 19/12/2025.
//

import SwiftUI
import AVFoundation
import Vision
import Combine
@available(iOS 17.0, *)
struct CameraFaceOverlayView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreviewView(cameraManager: cameraManager)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        cameraManager.checkPermissions()
                    }
                
                FacePointsOverlayView(cameraManager: cameraManager)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate , @unchecked Sendable {
    @Published var facePoints: [CGPoint] = []
    @Published var previewSize: CGSize = .zero
    
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let videoAspectRatio: CGFloat = 9.0 / 16.0
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.sessionQueue.async {
                        self.captureSession.startRunning()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                          for: .video,
                                                          position: .front) else {
            print("No front camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoOutputQueue"))
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            if let connection = videoOutput.connection(with: .video) {
                connection.videoOrientation = .portrait
                
                connection.isVideoMirrored = true
            }
            
            sessionQueue.async {
                self.captureSession.startRunning()
            }
            
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func setPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        previewLayer = layer
        previewSize = layer.bounds.size
    }
    
    func videoRect(for size: CGSize) -> CGRect {
        let viewAspect = size.width / size.height
        var rect = CGRect.zero
        
        if viewAspect > videoAspectRatio {
            rect.size.width = size.width
            rect.size.height = size.width / videoAspectRatio
            rect.origin.y = (size.height - rect.height) / 2
        } else {
            rect.size.height = size.height
            rect.size.width = size.height * videoAspectRatio
            rect.origin.x = (size.width - rect.width) / 2
        }
        return rect
    }
    
    func screenPoint(from normalizedPoint: CGPoint, in boundingBox: CGRect) -> CGPoint {
        let absX = boundingBox.origin.x + normalizedPoint.x * boundingBox.width
        let absY = boundingBox.origin.y + normalizedPoint.y * boundingBox.height
        let mirroredX = 1.0 - absX
        let videoRect = videoRect(for: previewSize)
        let screenX = videoRect.minX + mirroredX * videoRect.width
        let screenY = videoRect.minY + (1.0 - absY) * videoRect.height
        
        return CGPoint(x: screenX, y: screenY)
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Face detection error: \(error)")
                return
            }
            
            guard let results = request.results as? [VNFaceObservation] else { return }
            self.processFaceObservations(results)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .up,
                                            options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
    
    private func processFaceObservations(_ observations: [VNFaceObservation]) {
        var newFacePoints: [CGPoint] = []
        
        for face in observations {
            let boundingBox = face.boundingBox
            let centerPoint = screenPoint(from: CGPoint(x: 0.5, y: 0.5), in: boundingBox)
            newFacePoints.append(centerPoint)
            guard let landmarks = face.landmarks else { continue }
            let landmarkRegions: [(VNFaceLandmarkRegion2D?, Bool)] = [
                (landmarks.faceContour, false),
                (landmarks.leftEyebrow, true),
                (landmarks.rightEyebrow, true),
                (landmarks.leftEye, true),
                (landmarks.rightEye, true),
                (landmarks.nose, false),
                (landmarks.noseCrest, false),
                (landmarks.outerLips, true),
                (landmarks.innerLips, true)
            ]
            
            for (landmark, shouldReverse) in landmarkRegions {
                guard let landmark = landmark else { continue }
                
                var points = landmark.normalizedPoints.map { normalizedPoint in
                    self.screenPoint(from: normalizedPoint, in: boundingBox)
                }
                
                if shouldReverse {
                    points.reverse()
                }
                
                newFacePoints.append(contentsOf: points)
            }
        }
        
        DispatchQueue.main.async {
            self.facePoints = newFacePoints
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        
        if let connection = previewLayer.connection {
            connection.videoOrientation = .portrait
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            cameraManager.setPreviewLayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
            
            cameraManager.previewSize = uiView.bounds.size
            
            if let connection = layer.connection {
                connection.videoOrientation = .portrait
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }
    }
}

struct FacePointsOverlayView: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<cameraManager.facePoints.count, id: \.self) { index in
                    let point = cameraManager.facePoints[index]
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .position(x: point.x, y: point.y)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
