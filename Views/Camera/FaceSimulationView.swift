import SwiftUI
import AVFoundation
import Vision
import Combine

@available(iOS 17.0, *)
struct FaceSimulationView: View {
    @Binding var isRecording: Bool
    var passion: Double
    var energy: Double
    var positivity: Double
    var chosenEmoji: String
    
    @StateObject private var cameraManager = CameraVisionManager()
    @State private var timeRemaining = 7
    @State private var navigateToSummary = false
    
    var challenge: EmojiChallenge { EmojiChallenge.get(for: chosenEmoji) }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let videoAspectRatio: CGFloat = 9.0 / 16.0
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
                .onAppear {
                    cameraManager.targetFeature = challenge.featureToTrack
                    cameraManager.startSession()
                }
                .onDisappear {
                    cameraManager.stopSession()
                }
            
            GeometryReader { geometry in
                let videoRect = calculateVideoRect(for: geometry.size)
                
                Group {
                    switch cameraManager.targetFeature {
                    case .smile, .pout:
                        if !cameraManager.trackedPoints.isEmpty {
                            DrawClosedShape(points: cameraManager.trackedPoints, videoRect: videoRect)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                                .shadow(color: .cyan, radius: 10)
                        }
                        
                    case .eyesWide:
                        ZStack {
                            if cameraManager.leftEyePoints.count >= 4 {
                                DrawClosedShape(points: cameraManager.leftEyePoints, videoRect: videoRect)
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            }
                            if cameraManager.rightEyePoints.count >= 4 {
                                DrawClosedShape(points: cameraManager.rightEyePoints, videoRect: videoRect)
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            }
                        }
                        .shadow(color: .cyan, radius: 10)
                        
                    case .browsUp, .browsDown:
                        ZStack {
                            if !cameraManager.leftEyebrowPoints.isEmpty {
                                DrawOpenShape(points: cameraManager.leftEyebrowPoints, videoRect: videoRect)
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            }
                            if !cameraManager.rightEyebrowPoints.isEmpty {
                                DrawOpenShape(points: cameraManager.rightEyebrowPoints, videoRect: videoRect)
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            }
                        }
                        .shadow(color: .cyan, radius: 10)
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack {
                Text(challenge.instruction)
                    .font(.title2).bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    .padding(.top, 60)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Match Accuracy")
                        .font(.caption).bold().foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        Text("0%")
                            .font(.caption).bold().foregroundColor(.white)
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.3))
                                Capsule()
                                    .fill(
                                        LinearGradient(colors: [.red, .yellow, .green], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .frame(width: geo.size.width * (cameraManager.currentScore / 100))
                                    .animation(.spring(), value: cameraManager.currentScore)
                            }
                        }
                        .frame(height: 10)
                        
                        Text("100%")
                            .font(.caption).bold().foregroundColor(.white)
                    }
                    .padding(.horizontal, 40)
                    
                    Text("\(Int(cameraManager.currentScore))%")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 5)
                }
                .padding(.bottom, 20)
                
                Text("\(timeRemaining)")
                    .font(.system(size: 40, weight: .bold))
                    .padding(20)
                    .background(Circle().fill(Color.black.opacity(0.5)))
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
            }
            
            NavigationLink(destination: SummaryView(isRecording: $isRecording, passion: passion, energy: energy, positivity: positivity, chosenEmoji: chosenEmoji, similarityScore: cameraManager.averageScore), isActive: $navigateToSummary) { EmptyView() }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                cameraManager.stopSession()
                navigateToSummary = true
            }
        }
    }
    func calculateVideoRect(for size: CGSize) -> CGRect {
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
    
    func map(point: CGPoint, to videoRect: CGRect) -> CGPoint {
        let x = videoRect.minX + point.x * videoRect.width
        let y = videoRect.minY + (1.0 - point.y) * videoRect.height
        return CGPoint(x: x, y: y)
    }
}

struct DrawClosedShape: Shape {
    let points: [CGPoint]
    let videoRect: CGRect
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count >= 3 else { return path }
        
        let firstPoint = mapPoint(points[0])
        path.move(to: firstPoint)
        
        for i in 1..<points.count {
            path.addLine(to: mapPoint(points[i]))
        }
        
        path.closeSubpath()
        return path
    }
    
    private func mapPoint(_ point: CGPoint) -> CGPoint {
        let x = videoRect.minX + point.x * videoRect.width
        let y = videoRect.minY + (1.0 - point.y) * videoRect.height
        return CGPoint(x: x, y: y)
    }
}

@available(iOS 17.0, *)
struct DrawOpenShape: Shape {
    let points: [CGPoint]
    let videoRect: CGRect
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !points.isEmpty else { return path }
        
        let firstPoint = mapPoint(points[0])
        path.move(to: firstPoint)
        
        for i in 1..<points.count {
            path.addLine(to: mapPoint(points[i]))
        }
        
        return path
    }
    
    private func mapPoint(_ point: CGPoint) -> CGPoint {
        let x = videoRect.minX + point.x * videoRect.width
        let y = videoRect.minY + (1.0 - point.y) * videoRect.height
        return CGPoint(x: x, y: y)
    }
}

@available(iOS 17.0, *)
class CameraVisionManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    @Published var currentScore: Double = 0.0
    @Published var trackedPoints: [CGPoint] = []
    @Published var leftEyePoints: [CGPoint] = []
    @Published var rightEyePoints: [CGPoint] = []
    @Published var leftEyebrowPoints: [CGPoint] = []
    @Published var rightEyebrowPoints: [CGPoint] = []
    
    var targetFeature: FacialFeature = .smile
    var scoreHistory: [Double] = []
    
    private var userMinSmile: Double = 0.22
    private var userMaxSmile: Double = 0.42
    private var userMinPout: Double = 0.15
    private var userMaxPout: Double = 0.28
    private var userMinBrowRaise: Double = 0.05
    private var userMaxBrowRaise: Double = 0.15
    private var userMinBrowLower: Double = 0.02
    private var userMaxBrowLower: Double = 0.08
    private var userMinEyeOpen: Double = 0.03
    private var userMaxEyeOpen: Double = 0.09
    
    private var calibrationFrames: Int = 0
    private let calibrationFramesNeeded = 30
    
    var averageScore: Double {
        guard !scoreHistory.isEmpty else { return 0 }
        return scoreHistory.max() ?? 0
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupCamera()
            if !self.session.inputs.isEmpty {
                self.session.startRunning()
            } else {
                print("Running on simulator: Camera feed disabled. Injecting mock score.")
                DispatchQueue.main.async {
                    self.currentScore = -1
                    self.scoreHistory.append(-1)
                }
            }
        }
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        defer {
            session.commitConfiguration()
        }
        
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("No camera detected (Likely running on Simulator).")
            return
        }
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        output.alwaysDiscardsLateVideoFrames = true
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            if let connection = output.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { [weak self] req, err in
            guard let self = self,
                  let results = req.results as? [VNFaceObservation],
                  let face = results.first else {
                return
            }
            
            let boundingBox = face.boundingBox
            let faceWidth = boundingBox.width
            let faceHeight = boundingBox.height
            
            var score: Double = 0
            
            if let landmarks = face.landmarks {
                score = self.calculateScore(for: self.targetFeature,
                                            landmarks: landmarks,
                                            boundingBox: boundingBox,
                                            faceWidth: faceWidth,
                                            faceHeight: faceHeight)
                
                self.updateVisualizationPoints(for: self.targetFeature,
                                               landmarks: landmarks,
                                               boundingBox: boundingBox)
                
                if self.calibrationFrames < self.calibrationFramesNeeded {
                    self.calibrateRanges(for: self.targetFeature,
                                         landmarks: landmarks,
                                         boundingBox: boundingBox,
                                         faceWidth: faceWidth,
                                         faceHeight: faceHeight)
                    self.calibrationFrames += 1
                }
            }
            
            DispatchQueue.main.async {
                self.currentScore = score
                self.scoreHistory.append(score)
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    
    private func calculateScore(for feature: FacialFeature,
                                landmarks: VNFaceLandmarks2D,
                                boundingBox: CGRect,
                                faceWidth: Double,
                                faceHeight: Double) -> Double {
        
        switch feature {
        case .smile:
            guard let lips = landmarks.outerLips,
                  lips.normalizedPoints.count >= 2 else { return 0 }
            
            let points = lips.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let width = distance(points[0], points[points.count/2]) / faceWidth
            
            return normalizeScore(width, minIn: userMinSmile, maxIn: userMaxSmile)
            
        case .pout:
            guard let lips = landmarks.innerLips ?? landmarks.outerLips,
                  lips.normalizedPoints.count >= 2 else { return 0 }
            
            let points = lips.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let width = distance(points[0], points[points.count/2]) / faceWidth
            
            let rawScore = normalizeScore(width, minIn: userMinPout, maxIn: userMaxPout)
            return 100 - rawScore
            
        case .browsUp:
            guard let leftBrow = landmarks.leftEyebrow,
                  let leftEye = landmarks.leftEye,
                  !leftBrow.normalizedPoints.isEmpty else { return 0 }
            
            let browPoints = leftBrow.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let eyePoints = leftEye.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            
            let browY = browPoints.map { $0.y }.reduce(0, +) / Double(browPoints.count)
            let eyeY = eyePoints.map { $0.y }.reduce(0, +) / Double(eyePoints.count)
            let distance = (eyeY - browY) / faceHeight
            
            return 100 - normalizeScore(distance, minIn: userMinBrowRaise, maxIn: userMaxBrowRaise)
            
        case .browsDown:
            guard let leftBrow = landmarks.leftEyebrow,
                  let leftEye = landmarks.leftEye,
                  !leftBrow.normalizedPoints.isEmpty else { return 0 }
            
            let browPoints = leftBrow.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let eyePoints = leftEye.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            
            let browY = browPoints.map { $0.y }.reduce(0, +) / Double(browPoints.count)
            let eyeY = eyePoints.map { $0.y }.reduce(0, +) / Double(eyePoints.count)
            let distance = (eyeY - browY) / faceHeight
            
            return normalizeScore(distance, minIn: userMinBrowLower, maxIn: userMaxBrowLower)
            
            
        case .eyesWide:
            guard let leftEye = landmarks.leftEye,
                  leftEye.normalizedPoints.count >= 4 else { return 0 }
            
            let points = leftEye.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let top = points[1].y
            let bottom = points[3].y
            let height = (bottom - top) / faceHeight
            
            return 100 - (normalizeScore(height, minIn: userMinEyeOpen, maxIn: userMaxEyeOpen))
        }
    }
    
    private func normalizeScore(_ value: Double, minIn: Double, maxIn: Double) -> Double {
        guard maxIn > minIn else { return 0 }
        let normalized = (value - minIn) / (maxIn - minIn) * 100.0
        return min(max(normalized, 0), 100.0)
    }
    
    
    private func calibrateRanges(for feature: FacialFeature,
                                 landmarks: VNFaceLandmarks2D,
                                 boundingBox: CGRect,
                                 faceWidth: Double,
                                 faceHeight: Double) {
        
        switch feature {
        case .smile:
            guard let lips = landmarks.outerLips,
                  lips.normalizedPoints.count >= 2 else { return }
            
            let points = lips.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let width = distance(points[0], points[points.count/2]) / faceWidth
            
            if width < userMinSmile { userMinSmile = width }
            if width > userMaxSmile { userMaxSmile = width }
            
        case .pout:
            guard let lips = landmarks.innerLips ?? landmarks.outerLips,
                  lips.normalizedPoints.count >= 2 else { return }
            
            let points = lips.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let width = distance(points[0], points[points.count/2]) / faceWidth
            
            if width < userMinPout { userMinPout = width }
            if width > userMaxPout { userMaxPout = width }
            
        case .browsUp, .browsDown:
            guard let leftBrow = landmarks.leftEyebrow,
                  let leftEye = landmarks.leftEye,
                  !leftBrow.normalizedPoints.isEmpty else { return }
            
            let browPoints = leftBrow.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let eyePoints = leftEye.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            
            let browY = browPoints.map { $0.y }.reduce(0, +) / Double(browPoints.count)
            let eyeY = eyePoints.map { $0.y }.reduce(0, +) / Double(eyePoints.count)
            let distance = (eyeY - browY) / faceHeight
            
            if feature == .browsUp {
                if distance < userMinBrowRaise { userMinBrowRaise = distance }
                if distance > userMaxBrowRaise { userMaxBrowRaise = distance }
            } else {
                if distance < userMinBrowLower { userMinBrowLower = distance }
                if distance > userMaxBrowLower { userMaxBrowLower = distance }
            }
            
        case .eyesWide:
            guard let leftEye = landmarks.leftEye,
                  leftEye.normalizedPoints.count >= 4 else { return }
            
            let points = leftEye.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
            let top = points[1].y
            let bottom = points[3].y
            let height = (bottom - top) / faceHeight
            
            if height < userMinEyeOpen { userMinEyeOpen = height }
            if height > userMaxEyeOpen { userMaxEyeOpen = height }
        }
    }
    
    
    private func updateVisualizationPoints(for feature: FacialFeature,
                                           landmarks: VNFaceLandmarks2D,
                                           boundingBox: CGRect) {
        switch feature {
        case .smile, .pout:
            if let lips = landmarks.outerLips {
                let points = lips.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
                DispatchQueue.main.async {
                    self.trackedPoints = points
                }
            }
            
        case .eyesWide:
            if let left = landmarks.leftEye, let right = landmarks.rightEye {
                let leftPoints = left.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
                let rightPoints = right.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
                
                DispatchQueue.main.async {
                    self.leftEyePoints = leftPoints
                    self.rightEyePoints = rightPoints
                }
            }
            
        case .browsUp, .browsDown:
            if let left = landmarks.leftEyebrow, let right = landmarks.rightEyebrow {
                let leftPoints = left.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
                let rightPoints = right.normalizedPoints.map { absoluteMirroredPoint($0, in: boundingBox) }
                
                DispatchQueue.main.async {
                    self.leftEyebrowPoints = leftPoints
                    self.rightEyebrowPoints = rightPoints
                }
            }
        }
    }
    
    private func absoluteMirroredPoint(_ point: CGPoint, in boundingBox: CGRect) -> CGPoint {
        let absX = boundingBox.origin.x + point.x * boundingBox.width
        let absY = boundingBox.origin.y + point.y * boundingBox.height
        return CGPoint(x: absX, y: absY)
    }
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> Double {
        return sqrt(pow(Double(p2.x - p1.x), 2) + pow(Double(p2.y - p1.y), 2))
    }
}

@available(iOS 17.0, *)
struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        if let connection = view.videoPreviewLayer.connection {
            connection.videoOrientation = .portrait
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        if let connection = uiView.videoPreviewLayer.connection {
            connection.videoOrientation = .portrait
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
    }
}
