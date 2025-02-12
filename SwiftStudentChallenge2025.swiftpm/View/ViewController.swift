//
//  ViewController.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 30/01/25.
//

import UIKit
import SceneKit

class CubeViewController: UIViewController {
    
    var headDistanceFromCenter: HeadDistanceFromCenter? {
        didSet {
            updateCameraRotation()
        }
    }
    
    var handAction: HandAction? {
        didSet {
            guard let handAction = self.handAction else { return }
            
            switch handAction {
            case .right(let rotationType):
                let adjustedAction = adjustedRotation(.right(rotationType))
                rotate(adjustedAction) { rotatedNodes in
                    print("Rotated nodes: \(rotatedNodes)")
                }
                
            case .left(let rotationType):
                let adjustedAction = adjustedRotation(.left(rotationType))
                rotate(adjustedAction) { rotatedNodes in
                    print("Rotated nodes: \(rotatedNodes)")
                }
                
            case .up(let rotationType):
                let adjustedAction = adjustedRotation(.up(rotationType))
                rotate(adjustedAction) { rotatedNodes in
                    print("Rotated nodes: \(rotatedNodes)")
                }
                
            case .down(let rotationType):
                let adjustedAction = adjustedRotation(.down(rotationType))
                rotate(adjustedAction) { rotatedNodes in
                    print("Rotated nodes: \(rotatedNodes)")
                }
                
            case .face(let rotationType):
                let adjustedAction = adjustedRotation(.face(rotationType))
                rotate(adjustedAction) { rotatedNodes in
                    print("Rotated nodes: \(rotatedNodes)")
                }
                
            case .back(let rotationType):
                let adjustedAction = adjustedRotation(.back(rotationType))
                rotate(adjustedAction) { rotatedNodes in
                    print("Rotated nodes: \(rotatedNodes)")
                }
                
            case .none:
                // Não faz nada quando a ação é .none
                print("No action detected")
            }
        }
    }
    
    // CAMERA
    var currentAngleY: Float = 0
    var currentAngleX: Float = 0

    // LIGHTS
    var ambientLight: SCNLight = SCNLight()
    var omniLight: SCNLight = SCNLight()
    
    // SCREEN
    let screenSize: CGRect = UIScreen.main.bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    // SCENE
    var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
    var rubiksCube: RubiksCube!

    // TOUCHES
    var beganPanHitResult: SCNHitTestResult!
    var beganPanNode: SCNNode!
    var rotationAxis:SCNVector3!

    var edgeDistance975 : Float = 0.975
    var tolerance25: Float = 0.025
    var animationLock = false
    
    // MARK: - DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupGestureRecognizers()
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

    // MARK: - CUBE
    func createRubiksCube() {
        rubiksCube = RubiksCube()
        rootNode.addChildNode(rubiksCube)
    }

    // MARK: - CAMERA
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode = SCNNode()
        cameraNode.camera = camera
        rootNode.addChildNode(cameraNode)
        
        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -5) // CAMERA INITIAL POSITION
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
    }
  
    // MARK: - GESTURE RECOGNIZERS
    func setupGestureRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneTouched(_:)))
        sceneView.gestureRecognizers = [panRecognizer]
    }
    
    // Adicione esta função para atualizar a rotação da câmera
    func updateCameraRotation() {
        guard let distance = headDistanceFromCenter else { return }
        
        // Ajuste estes valores conforme necessário
        let sensitivity: Float = 0.05 // Sensibilidade da rotação
        let maxRotationAngle: Float = .pi / 4 // Ângulo máximo de rotação (45 graus)
        
        // Mapear a distância horizontal para rotação Y (esquerda/direita)
        let horizontalOffset = Float(distance.horizontal - 50) * sensitivity
        let targetRotationY = clamp(value: horizontalOffset, min: -maxRotationAngle, max: maxRotationAngle)
        
        // Mapear a distância vertical para rotação X (cima/baixo)
        let verticalOffset = Float(distance.vertical - 50) * sensitivity
        let targetRotationX = clamp(value: verticalOffset, min: -maxRotationAngle, max: maxRotationAngle)
        
        // Atualizar a rotação da câmera com animação suave
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        cameraNode.eulerAngles.y = -targetRotationY
        cameraNode.eulerAngles.x = -targetRotationX
        SCNTransaction.commit()
    }
    
    private func clamp(value: Float, min: Float, max: Float) -> Float {
        return Swift.max(min, Swift.min(max, value))
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
            
        } else if recognizer.state == .ended && beganPanNode != nil && animationLock == false {

            animationLock = true
            
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
                self.animationLock = false
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
            
            // MARK: - ROTATION AXIS && POSITIONS
            let nodesAdded =  rubiksCube.childNodes { (child, _) -> Bool in
                // (PLANO Z - DIREITA E ESQUERDA) ou (PLANO X - FRENTE E TRÁS)
                // --> <--
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Z")
                    || ((side == CubeSide.front || side == CubeSide.back) && plane == "X") {
                    self.rotationAxis = SCNVector3(0,1,0) // Y
                    return child.position.y.isVeryClose(to: self.beganPanNode.position.y, withTolerance: tolerance25)
                }
                
                
                // (PLANO Y - DIREITA E ESQUERDA) ou (PLANO X - CIMA E BAIXO)
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "X") {
                    self.rotationAxis = SCNVector3(0,0,1) // Z
                    return child.position.z.isVeryClose(to: self.beganPanNode.position.z, withTolerance: tolerance25)
                }
                
                // (PLANO Y - FRENTE E TRÁS) ou (PLANO Z - CIMA E BAIXO)
                // |
                // v e pra cima
                if ((side == CubeSide.front || side == CubeSide.back) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "Z") {
                    self.rotationAxis = SCNVector3(1,0,0) // X
                    return child.position.x.isVeryClose(to: self.beganPanNode.position.x, withTolerance: tolerance25)
                }
                return false
            }
            
            if nodesAdded.count <= 0 {
                self.animationLock = false
                self.beganPanNode = nil
                return
            }
            
            // container that holds all nodes to rotate after touch finished
            let container = SCNNode()
            rootNode.addChildNode(container)
            for nodeToRotate in nodesAdded {
                container.addChildNode(nodeToRotate)
            }
            
            // MARK: - ROTATIONS ACTIONS
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
                self.animationLock = false
                self.beganPanNode = nil
            }
        }
    }
    
            
    func adjustedRotation(_ rotation: HandAction) -> HandAction {

        // camera transformation matrix
        let cameraTransform = cameraNode.simdTransform
        
        // columns.2 -> "FORWARD" vector of camera
        let forward = simd_float3(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)

        // determine which axis has the highest absolute value in the forward vector
        // this tells us which face the player is currently looking at
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
    
    func rotate(_ action: HandAction, completion: @escaping ([SCNNode]) -> Void) {
        let container = SCNNode()
        let (axis, layerPosition, isClockwise) = rotationData(for: action)
        
        let wallNodes = rubiksCube.getWall(forAxis: axis, layerPosition: layerPosition)
        rootNode.addChildNode(container)

        for node in wallNodes {
            container.addChildNode(node)
        }

        let angle: CGFloat = isClockwise ? -.pi/2 : .pi/2
        let rotationAction = SCNAction.rotate(by: angle, around: axis, duration: 0.2)
        rotationAction.timingMode = .easeInEaseOut

        container.runAction(rotationAction) {
            var rotatedNodes: [SCNNode] = []

            for node in container.childNodes {
                let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                node.removeFromParentNode()
                node.transform = transform
                self.rubiksCube.addChildNode(node)
                rotatedNodes.append(node)
            }
            completion(rotatedNodes)
            self.animationLock = false
            self.beganPanNode = nil
        }
    }

    // Converte a ação da mão para os dados necessários para rotação
    private func rotationData(for action: HandAction) -> (SCNVector3, Float, Bool) {
        let offset = rubiksCube.cubeOffsetDistance()

        switch action {
        case .up(let type):
            return (SCNVector3(0, 1, 0), +offset, type == .clockwise)
        case .down(let type):
            return (SCNVector3(0, 1, 0), -offset, type == .counterclockwise)
        case .right(let type):
            return (SCNVector3(1, 0, 0), +offset, type == .clockwise)
        case .left(let type):
            return (SCNVector3(1, 0, 0), -offset, type == .counterclockwise)
        case .face(let type):
            return (SCNVector3(0, 0, 1), +offset, type == .clockwise)
        case .back(let type):
            return (SCNVector3(0, 0, 1), -offset, type == .counterclockwise)
        case .none:
            return (SCNVector3(0, 0, 0), 0, false)
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
