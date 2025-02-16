//
//  ViewController.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 30/01/25.
//

import UIKit
import SceneKit

class CubeViewController: UIViewController {
   
    // MARK: - HEAD CAMERA CONTROLL
    /// head distance from screen center
    var headDistanceFromCenter: HeadDistanceFromCenter? {
        didSet { updateCameraRotationBasedOnUserHead() }
    }
    
    // MARK: - HAND CUBE CONTROLL
    /// hand action made to controll the cube
    var previousHandAction: HandAction? = HandAction.none
    var handAction: HandAction? {
        didSet {
            guard handAction != previousHandAction else { return }
            
            if let newAction = handAction, newAction != .none {
                switch newAction {
                    // camera hand action
                    case .rotateCamera:
                    updateCameraRotation(based: newAction)
                    
                    // cube hand action
                    default:
                        rotate(adjustedRotation(newAction))
                }
            }
            
            previousHandAction = handAction
        }
    }
    
    // MARK: - VARIABLES
    // camera
    var currentAngleY: Float = 0
    var currentAngleX: Float = 0
    var isUserControllingCamera = false

    // screen
    let screenSize: CGRect = UIScreen.main.bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    // scene
    var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
    var rubiksCube: RubiksCube!

    // touch controll
    var beganPanHitResult: SCNHitTestResult!
    var beganPanNode: SCNNode!
    var rotationAxis:SCNVector3!

    var edgeDistance975 : Float = 0.975
    var tolerance25: Float = 0.025
    var isRotating = false
    
    // MARK: - DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupGestureRecognizer()
        createRubiksCube()
        setupCamera()
    }
    
    // MARK: - SCENE
    func setupScene() {
        screenWidth = Float(screenSize.width)
        screenHeight = Float(screenSize.height)
        
        // sceneview
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .clear
        sceneView.showsStatistics = false
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(sceneView)
        rootNode = sceneView.scene!.rootNode
        
        // light
        sceneView.autoenablesDefaultLighting = false
    }

    // MARK: - CREATE CUBE
    func createRubiksCube() {
        rubiksCube = RubiksCube()
        rootNode.addChildNode(rubiksCube)
    }

    // MARK: - CREATE CAMERA
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode = SCNNode()
        cameraNode.camera = camera
        rootNode.addChildNode(cameraNode)
        
        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -5) // CAMERA INITIAL POSITION
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
    }
  
    // MARK: - GESTURE RECOGNIZER
    func setupGestureRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneTouched(_:)))
        sceneView.gestureRecognizers = [panRecognizer]
    }
    
    @objc
    func sceneTouched(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        // ROTATIONS
        let translation = recognizer.translation(in: sceneView)
        
        // Perform rotation based on translation
        let newRotationX = -Float(translation.y) * (.pi)/180
        let newRotationY = -Float(translation.x) * (.pi)/180
        
        // MARK: - 2 FINGERS: CAMERA
        if recognizer.numberOfTouches == 2  {
            cameraNode.eulerAngles.x = currentAngleX + newRotationX
            cameraNode.eulerAngles.y = currentAngleY + newRotationY
        } else if recognizer.state == .ended {
            currentAngleX = cameraNode.eulerAngles.x
            currentAngleY = cameraNode.eulerAngles.y
        }
        
        // MARK: - 1 FINGER: CUBE
        if recognizer.numberOfTouches == 1
            && hitResults.count > 0
            && recognizer.state == .began
            && beganPanNode == nil {
            
            beganPanHitResult = hitResults.first
            beganPanNode = beganPanHitResult.node
            
        } else if recognizer.state == .ended && beganPanNode != nil && isRotating == false {

            isRotating = true
            
            // TOUCH
            let touch_Location = recognizer.location(in: sceneView) // touch position
            let projectedOrigin = sceneView.projectPoint(beganPanHitResult.worldCoordinates) // initial coordinates from initial touch point in 3D
            let estimatedPoint = sceneView.unprojectPoint(SCNVector3( Float(touch_Location.x),
                                                                      Float(touch_Location.y),
                                                                      projectedOrigin.z) )
            
            // PLANE
            var plane = "?"
            var direction = 1
            
            // DIFFS
            let xDiff = estimatedPoint.x - beganPanHitResult.worldCoordinates.x // RELATIVE MOVEMENT SINCE BEGINING OF TOUCH UNTIL NOW
            let yDiff = estimatedPoint.y - beganPanHitResult.worldCoordinates.y
            let zDiff = estimatedPoint.z - beganPanHitResult.worldCoordinates.z
            
            let absXDiff = abs(xDiff)
            let absYDiff = abs(yDiff)
            let absZDiff = abs(zDiff)
            
            // SIDE TOUCHED (NOT ROTATED CUBE SIDE)
            var side: CubeSide!
            side = selectedCubeSide(hitResult: beganPanHitResult, edgeDistanceFromOrigin: edgeDistance975)
            
            if side == CubeSide.none {
                self.isRotating = false
                self.beganPanNode = nil
                return
            }
            
            // MARK: - DIRECTION
            // RIGH ou LEFT
            if side == CubeSide.right || side == CubeSide.left {
                if absYDiff > absZDiff {
                    plane = "Y"
                    if side == CubeSide.right { direction = yDiff > 0 ? 1 : -1 }
                    else { direction = yDiff > 0 ? -1 : 1 }
                }
                else {
                    plane = "Z"
                    if side == CubeSide.right {  direction = zDiff > 0 ? -1 : 1 }
                    else { direction = zDiff > 0 ? 1 : -1 }
                }
            }
            
            // UP or DOWN
            else if side == CubeSide.up || side == CubeSide.down {
                if absXDiff > absZDiff {
                    plane = "X"
                    if side == CubeSide.up { direction = xDiff > 0 ? -1 : 1 }
                    else { direction = xDiff > 0 ? 1 : -1 }
                }
                else {
                    plane = "Z"
                    if side == CubeSide.up { direction = zDiff > 0 ? 1 : -1 }
                    else { direction = zDiff > 0 ? -1 : 1 }
                }
            }
            
            // BACK or FRONT
            else if side == CubeSide.back || side == CubeSide.front {
                if absXDiff > absYDiff {
                    plane = "X"
                    if side == CubeSide.back { direction = xDiff > 0 ? -1 : 1 }
                    else { direction = xDiff > 0 ? 1 : -1 }
                }
                else {
                    plane = "Y"
                    if side == CubeSide.back { direction = yDiff > 0 ? 1 : -1 }
                    else { direction = yDiff > 0 ? -1 : 1 }
                }
            }
            
            let nodesAdded =  rubiksCube.childNodes { (child, _) -> Bool in
                // PLANE Z || PLANE X
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Z")
                    || ((side == CubeSide.front || side == CubeSide.back) && plane == "X") {
                    self.rotationAxis = SCNVector3(0,1,0) // Y
                    return child.position.y.isVeryClose(to: self.beganPanNode.position.y, withTolerance: tolerance25)
                }
                
                // PLANE Y || PLANE X
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "X") {
                    self.rotationAxis = SCNVector3(0,0,1) // Z
                    return child.position.z.isVeryClose(to: self.beganPanNode.position.z, withTolerance: tolerance25)
                }
                
                // PLANE Y || PLANE Z
                if ((side == CubeSide.front || side == CubeSide.back) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "Z") {
                    self.rotationAxis = SCNVector3(1,0,0) // X
                    return child.position.x.isVeryClose(to: self.beganPanNode.position.x, withTolerance: tolerance25)
                }
                return false
            }
            
            // didn't catch any node on the cube, so cancel
            if nodesAdded.count <= 0 {
                self.isRotating = false
                self.beganPanNode = nil
                return
            }
            
            // container that holds all nodes to rotate after touch finished
            let container = SCNNode()
            rootNode.addChildNode(container)
            for nodeToRotate in nodesAdded {
                container.addChildNode(nodeToRotate)
            }
            
            // rotation action
            let rotationAngle = CGFloat(direction) * .pi/2
            let rotation_Action = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.2)
            let finalRotation_Action: SCNAction = rotation_Action
    
            container.runAction(finalRotation_Action) {
                for node: SCNNode in nodesAdded {
                    let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                    node.removeFromParentNode()
                    node.transform = transform
                    self.rubiksCube.addChildNode(node)
                }
                self.isRotating = false
                self.beganPanNode = nil
            }
        }
    }
    
    // MARK: - CAMERA HEAD CONTROLL
    func updateCameraRotationBasedOnUserHead() {
        guard let distance = headDistanceFromCenter, !isUserControllingCamera else { return }
        
        let sensitivity: Float = 0.03
        let maxRotationAngle: Float = .pi / 4 // 45 degrees
        
        // horizontal offset
        let horizontalOffset = Float(distance.horizontal - 60) * sensitivity
        let targetRotationY = clamp(value: horizontalOffset, min: -maxRotationAngle, max: maxRotationAngle)
        
        // vertical offset
        let verticalOffset = Float(distance.vertical - 50) * sensitivity
        let targetRotationX = clamp(value: verticalOffset, min: -maxRotationAngle, max: maxRotationAngle)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        cameraNode.eulerAngles.y = currentAngleY - targetRotationY
        cameraNode.eulerAngles.x = -targetRotationX
        SCNTransaction.commit()
    }
    private func clamp(value: Float, min: Float, max: Float) -> Float {
        return Swift.max(min, Swift.min(max, value))
    }
    
    func updateCameraRotation(based onAction: HandAction) {
        guard case .rotateCamera(let rotationType) = onAction else { return }
        
        let rotationAngle: Float = rotationType == .clockwise ? -.pi / 2 : .pi / 2
        
        isUserControllingCamera = true
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        cameraNode.eulerAngles.y += rotationAngle
        SCNTransaction.commit()
        
        currentAngleY += rotationAngle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isUserControllingCamera = false
        }
    }
    
    // MARK: - CUBE ROTATION HAND ACTION
    // adjusted rotation based on which face the user is looking at
    func adjustedRotation(_ rotation: HandAction) -> HandAction {

        // camera transformation matrix
        let cameraTransform = cameraNode.simdTransform
        
        // columns.2 = "FORWARD" vector of camera
        let forward = simd_float3(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)

        // which axis has the highest absolute value on the forward
        // which face the player is currently looking at
        let dominantAxis = abs(forward.x) > abs(forward.y) && abs(forward.x) > abs(forward.z) ? "x" :
                           abs(forward.y) > abs(forward.x) && abs(forward.y) > abs(forward.z) ? "y" : "z"
        
        switch dominantAxis {
        case "x":
            if forward.x > 0 {
                // looking at the right face
                switch rotation {
                case .up(let direction): return .up(direction)
                case .down(let direction): return .down(direction)
                case .left(let direction): return .face(direction)
                case .right(let direction): return .back(direction)
                case .face(let direction): return .left(direction)
                case .back(let direction): return .right(direction)
                default: return rotation
                }
            } else {
                // looking at the left face
                switch rotation {
                case .up(let direction): return .up(direction)
                case .down(let direction): return .down(direction)
                case .left(let direction): return .back(direction)
                case .right(let direction): return .face(direction)
                case .face(let direction): return .right(direction)
                case .back(let direction): return .left(direction)
                default: return rotation
                }
            }
            
        case "y":
            if forward.y > 0 {
                // looking at the top face
                switch rotation {
                case .up(let direction): return .back(direction)
                case .down(let direction): return .face(direction)
                case .left(let direction): return .left(direction)
                case .right(let direction): return .right(direction)
                case .face(let direction): return .up(direction)
                case .back(let direction): return .down(direction)
                default: return rotation
                }
            } else {
                // looking at the bottom face
                switch rotation {
                case .up(let direction): return .face(direction)
                case .down(let direction): return .back(direction)
                case .left(let direction): return .left(direction)
                case .right(let direction): return .right(direction)
                case .face(let direction): return .down(direction)
                case .back(let direction): return .up(direction)
                default: return rotation
                }
            }
            
        case "z":
            if forward.z > 0 {
                // looking at the front face
                switch rotation {
                case .up(let direction): return .up(direction)
                case .down(let direction): return .down(direction)
                case .left(let direction): return .left(direction)
                case .right(let direction): return .right(direction)
                case .face(let direction): return .face(direction)
                case .back(let direction): return .back(direction)
                default: return rotation
                }
            } else {
                // looking at the back face
                switch rotation {
                case .up(let direction): return .up(direction)
                case .down(let direction): return .down(direction)
                case .left(let direction): return .right(direction)
                case .right(let direction): return .left(direction)
                case .face(let direction): return .back(direction)
                case .back(let direction): return .face(direction)
                default: return rotation
                }
            }
            
        default:
            return rotation
        }
    }
    
    // MARK: - ROTATES CUBE SIDE
    /// rotates a specific cube side based on the users hand action made
    func rotate(_ action: HandAction) {
        guard !isRotating else { return }

        isRotating = true

        // invisible container / rotation axis / rotation angle
        let container = SCNNode(), axis = action.axis, angle = action.angle

        // nodes that will be rotated
        let wallNodes = rubiksCube.getWall(for: action)
        rootNode.addChildNode(container)

        // adding the nodes to the container
        for node in wallNodes { container.addChildNode(node) }

        // rotation action
        let rotationAction = SCNAction.rotate(by: angle, around: axis, duration: 0.2)
        rotationAction.timingMode = .easeInEaseOut

        container.runAction(rotationAction) {
            for node in container.childNodes {
                let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                node.removeFromParentNode()
                node.transform = transform
                self.rubiksCube.addChildNode(node)
            }

            self.isRotating = false
            self.beganPanNode = nil
        }
    }
    
    // CUBE SELECTED SIDE (NOT ROTATED SIDE)
    private func selectedCubeSide(hitResult: SCNHitTestResult, edgeDistanceFromOrigin:Float) -> CubeSide {
        // X
        if beganPanHitResult.worldCoordinates.x.isVeryClose(to: edgeDistanceFromOrigin, withTolerance: tolerance25) { return .right }
        else if beganPanHitResult.worldCoordinates.x.isVeryClose(to: -edgeDistanceFromOrigin, withTolerance: tolerance25) { return .left }
        
        // Y
        else if beganPanHitResult.worldCoordinates.y.isVeryClose(to: edgeDistanceFromOrigin, withTolerance: tolerance25) { return .up }
        else if beganPanHitResult.worldCoordinates.y.isVeryClose(to: -edgeDistanceFromOrigin, withTolerance: tolerance25) { return .down }
        
        // Z
        else if beganPanHitResult.worldCoordinates.z.isVeryClose(to: edgeDistanceFromOrigin, withTolerance: tolerance25) { return .front }
        else if beganPanHitResult.worldCoordinates.z.isVeryClose(to: -edgeDistanceFromOrigin, withTolerance: tolerance25) { return .back }
        return .none
    }
}
