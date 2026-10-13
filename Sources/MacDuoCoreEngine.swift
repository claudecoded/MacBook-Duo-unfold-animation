import Cocoa
import QuartzCore
import CoreGraphics

public class MacDuoCoreEngine: NSViewController {
    private var displayLink: CVDisplayLink?
    private var isAnimating = false
    
    // The target baseline angle where the user typically sits (completely unfolded)
    private var baseAngle: Double = 125.0 
    
    // Core Animation 3D Structural Layers
    private let perspectiveContainer = CALayer()
    private let leftUnfoldPanel = CALayer()
    private let rightUnfoldPanel = CALayer()
    
    public override func loadView() {
        // Fallback to a zero rect if the main screen bounds cannot be read at initialization
        self.view = NSView(frame: NSScreen.main?.frame ?? NSRect.zero)
        self.view.wantsLayer = true
        setupPerspectiveStage()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initializeHardwarePollingLoop()
    }
    
    /// Configures the CALayers with perspective projection matrices
    private func setupPerspectiveStage() {
        guard let mainLayer = view.layer else { return }
        mainLayer.backgroundColor = NSColor.black.cgColor
        
        perspectiveContainer.frame = mainLayer.bounds
        
        // Modifying the m34 component generates a true 3D frustum cone effect (perspective matrix projection)
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = -1.0 / 1100.0 // Value scales depth scaling dynamically
        perspectiveContainer.sublayerTransform = perspectiveTransform
        
        let screenHalfWidth = mainLayer.bounds.width / 2
        let screenHeight = mainLayer.bounds.height
        
        // Setup Left Fold Mesh Panel (Anchor positioned on the right boundary edge for folding inward)
        leftUnfoldPanel.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        leftUnfoldPanel.frame = CGRect(x: 0, y: 0, width: screenHalfWidth, height: screenHeight)
        
        // Setup Right Fold Mesh Panel (Anchor positioned on the left boundary edge for folding inward)
        rightUnfoldPanel.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        rightUnfoldPanel.frame = CGRect(x: screenHalfWidth, y: 0, width: screenHalfWidth, height: screenHeight)
        
        perspectiveContainer.addSublayer(leftUnfoldPanel)
        perspectiveContainer.addSublayer(rightUnfoldPanel)
        mainLayer.addSublayer(perspectiveContainer)
    }
    
    /// Silently captures a high-resolution snapshot of the screen compositor state
    private func snapshotActiveDisplay() -> CGImage? {
        let activeDisplayID = CGMainDisplayID()
        return CGDisplayCreateImage(activeDisplayID)
    }
    
    /// Sections the single display capture matrix into dual matching hardware textures
    private func segmentScreenTextures(from fullCapture: CGImage) {
        let baseWidth = fullCapture.width
        let baseHeight = fullCapture.height
        
        let leftSegmentBoundary = CGRect(x: 0, y: 0, width: baseWidth / 2, height: baseHeight)
        let rightSegmentBoundary = CGRect(x: baseWidth / 2, y: 0, width: baseWidth / 2, height: baseHeight)
        
        if let leftGraphic = fullCapture.cropping(to: leftSegmentBoundary),
           let rightGraphic = fullCapture.cropping(to: rightSegmentBoundary) {
            DispatchQueue.main.async {
                self.leftUnfoldPanel.contents = leftGraphic
                self.rightUnfoldPanel.contents = rightGraphic
            }
        }
    }
    
    /// Sets up a high-precision hardware render thread synchronized with display refresh intervals
    private func initializeHardwarePollingLoop() {
        CVDisplayLinkCreateWithActiveDisplays(&displayLink)
        
        let linkCallback: CVDisplayLinkOutputCallback = { _, _, _, _, _, backgroundContext -> CVReturn in
            let engineInstance = Unmanaged<MacDuoCoreEngine>.fromOpaque(backgroundContext!).takeUnretainedValue()
            engineInstance.evaluateLidStateAndRender()
            return kCVReturnSuccess
        }
        
        if let liveLink = displayLink {
            CVDisplayLinkSetOutputCallback(liveLink, linkCallback, Unmanaged.passUnretained(self).toOpaque())
            CVDisplayLinkStart(liveLink)
        }
    }
    
    /// Checks the C++ bridge layer and maps physics to the animation frame render steps
    private func evaluateLidStateAndRender() {
        let realTimeHardwareAngle = LidSensorBridge.getLidAngle()
        
        // Check if the user initiated a physical closure threshold deviation
        if realTimeHardwareAngle = baseAngle {
                isAnimating = false
                DispatchQueue.main.async {
                    self.view.window?.orderOut(nil)
                }
            }
        }
    }
    
    deinit {
        if let liveLink = displayLink {
            CVDisplayLinkStop(liveLink)
        }
    }
}
