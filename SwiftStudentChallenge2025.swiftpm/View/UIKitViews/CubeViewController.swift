//
//  CubeViewController.swift
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
    var isUserControllingCamera = false

    // screen
    let screenSize: CGRect = UIScreen.main.bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    // scene
    var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
    var cube: Cube!

    // touch controll
    var cameraHeadControllLock: Bool = true
    var cameraHandControllLock: Bool = true
    var cubeFaceRotationLock: Bool = true
    var isRotating = false
    
    // MARK: - DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
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
        
        createConcreteRoom()
        addLighting()
    }
    
    func addLighting() {
        // ceiling
        let ceilingLightNode = SCNNode()
        let ceilingLight = SCNLight()
        
        ceilingLight.type = .omni
        ceilingLight.color = UIColor.white
        ceilingLight.intensity = 800
        ceilingLight.attenuationStartDistance = 5
        ceilingLight.attenuationEndDistance = 50
        
        ceilingLightNode.light = ceilingLight
        ceilingLightNode.position = SCNVector3(0, 10, 0)
        
        rootNode.addChildNode(ceilingLightNode)

        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        
        ambientLight.type = .ambient
        ambientLight.color = UIColor.darkGray
        
        ambientLightNode.light = ambientLight
        rootNode.addChildNode(ambientLightNode)
    }


    // MARK: - CREATE CUBE
    func createRubiksCube() {
        cube = Cube()
        rootNode.addChildNode(cube)
    }

    // MARK: - CREATE CAMERA
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode = SCNNode()
        cameraNode.camera = camera
        rootNode.addChildNode(cameraNode)
        
        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -5)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        cameraNode.camera?.fieldOfView = 90
    }
    
    func createConcreteRoom() {
        let floorSize: Float = 60
        let wallHeight: Float = 20
        let wallThickness: Float = 0.2
        let floorHeight: Float = 0.2
        let roomYOffset: Float = 6
        
        let wallTexture = UIImage(named: "bgWalls") // WALLS TEXTURE
        let floorCeilingTexture = UIImage(named: "bgGround") // GROUND AND CEILING TEXTURE

        func createWall(width: Float, height: Float, depth: Float, position: SCNVector3, texture: UIImage?) -> SCNNode {
            let wallGeometry = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(depth), chamferRadius: 0)

            let material = SCNMaterial()
            material.diffuse.contents = texture ?? UIColor.gray
            material.lightingModel = .phong

            wallGeometry.materials = [material]

            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = position
            return wallNode
        }

        let leftWall = createWall(width: wallThickness, height: wallHeight, depth: floorSize, position: SCNVector3(-floorSize / 2, roomYOffset, 0), texture: wallTexture)
        let rightWall = createWall(width: wallThickness, height: wallHeight, depth: floorSize, position: SCNVector3(floorSize / 2, roomYOffset, 0), texture: wallTexture)
        let backWall = createWall(width: floorSize, height: wallHeight, depth: wallThickness, position: SCNVector3(0, roomYOffset, -floorSize / 2), texture: wallTexture)
        let frontWall = createWall(width: floorSize, height: wallHeight, depth: wallThickness, position: SCNVector3(0, roomYOffset, floorSize / 2), texture: wallTexture)

        let floor = createWall(width: floorSize, height: floorHeight, depth: floorSize, position: SCNVector3(0, roomYOffset - wallHeight / 2, 0), texture: floorCeilingTexture)
        let ceiling = createWall(width: floorSize, height: floorHeight, depth: floorSize, position: SCNVector3(0, roomYOffset + wallHeight / 2, 0), texture: floorCeilingTexture)

        rootNode.addChildNode(leftWall)
        rootNode.addChildNode(rightWall)
        rootNode.addChildNode(backWall)
        rootNode.addChildNode(frontWall)
        rootNode.addChildNode(floor)
        rootNode.addChildNode(ceiling)
    }
  
    
    // MARK: - CAMERA HEAD CONTROLL
    func updateCameraRotationBasedOnUserHead() {
        guard let distance = headDistanceFromCenter, !isUserControllingCamera, !cameraHeadControllLock else { return }
        
        let sensitivity: Float = 0.015
        let maxRotation: Float = .pi / 4  // 45 degrees for normal movement rotation
        let iPadCameraPosition = UserIpadSchemaManager.getCameraPosition() // getting user's iPad's camera position
        
        // horizontal offset
        let horizontalOffset = iPadCameraPosition == .side ?
            Float(distance.horizontal - 50) * sensitivity :
            Float(distance.horizontal - 25) * sensitivity
        
        let targetRotationY = clamp(value: horizontalOffset, min: -maxRotation, max: maxRotation)
        
        // vertical offset
        let verticalOffset = iPadCameraPosition == .side ?
            Float(distance.vertical - 50) * sensitivity :
            Float(distance.vertical) * sensitivity
        
        let targetRotationX = clamp(value: verticalOffset, min: -maxRotation, max: maxRotation)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        cameraNode.eulerAngles.y = currentAngleY - targetRotationY
        cameraNode.eulerAngles.x = -targetRotationX
        SCNTransaction.commit()
    }

    private func clamp(value: Float, min: Float, max: Float) -> Float {
        return Swift.max(min, Swift.min(max, value))
    }

    // ROTATES THE ENTIRE CUBE (camera controll)
    func updateCameraRotation(based onAction: HandAction) {
        guard case .rotateCamera(let rotationType) = onAction else { return }
        guard !cameraHandControllLock else { return }
        
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
        guard !isRotating, !cubeFaceRotationLock else { return }

        isRotating = true

        // invisible container / rotation axis / rotation angle
        let container = SCNNode(), axis = action.axis, angle = action.angle

        // nodes that will be rotated
        let wallNodes = cube.getWall(for: action)
        rootNode.addChildNode(container)

        // adding the nodes to the container
        for node in wallNodes { container.addChildNode(node) }

        // rotation action
        let rotationAction = SCNAction.rotate(by: angle, around: axis, duration: 0.2)
        rotationAction.timingMode = .easeInEaseOut

        container.runAction(rotationAction) {
            for node in container.childNodes {
                let transform = node.parent!.convertTransform(node.transform, to: self.cube)
                node.removeFromParentNode()
                node.transform = transform
                self.cube.addChildNode(node)
            }

            self.isRotating = false
        }
    }

    // MARK: - APPSTATE CHANGES
    func updateAppState(_ state: AppState) {
        switch state {
        // MARK: HOME
        case .home:
            adjustCameraPositionToHome()
            cameraHeadControllLock = true
            cameraHandControllLock = true
            cubeFaceRotationLock = true

        // MARK: STORYTELLING BEGGINING
        case .storyTellingBegginig(let storyTellingBegginigPhases):
            switch storyTellingBegginigPhases {
            case .first:
                adjustCameraPositionPhaseFirst()

                animateRubiksCubeRotation(startAngle: 0, numberOfRotations: 20, duration: 15, isDecelerating: false) {
                    self.finalRotationAngle = self.cube.rotation.w
                }

            case .fourth:
                animateRubiksCubeRotation(startAngle: finalRotationAngle, numberOfRotations: 2, duration: 7, isDecelerating: true) {}
                adjustCameraPositionPhaseFourth()
                return

            default:
                break
            }

        // MARK: ALERTS CARDS
        case .alertsCards(_):
            return

        // MARK: SCENE TUTORIAL
        case .sceneTutorial(let sceneTutorialPhases):
            switch sceneTutorialPhases {
            case .intro:
                return

            case .headCameraTracking:
                // ALLOW CAMERA HEAD CONTROLL
                cameraHeadControllLock = false
                return

            case .handActionCameraRotation:
                // ALLOW CAMERA CONTROLL ROTTATION
                cameraHandControllLock = false
                return

            case .handActionCubeRightSideRotation:
                // AALOW SIDEROTATION
                cubeFaceRotationLock = false
            }

        case .freeMode:
            // FREE ALL CONTROLLS
            cameraHeadControllLock = false
            cameraHandControllLock = false
            cubeFaceRotationLock = false
        }
    }

    // MARK: ADJUST CAMERA POSITION
    func adjustCameraPositionToHome() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        self.cameraNode.position = SCNVector3Make(0, 0, 0)
        self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -5)
        self.cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        SCNTransaction.commit()
    }

    func adjustCameraPositionPhaseFirst() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 3
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -3)
        SCNTransaction.commit()
    }

    func adjustCameraPositionPhaseFourth() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 3
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -5)
        SCNTransaction.commit()
    }
    
    // MARK: CUBE ROTATION ANIMATION
    var finalRotationAngle: Float = 0

    func animateRubiksCubeRotation(startAngle: Float, numberOfRotations: Int, duration: TimeInterval, isDecelerating: Bool, completion: @escaping () -> Void) {
        let endAngle = Float(numberOfRotations) * .pi * 2
        let angleDifference = endAngle - startAngle
        
        let rotateAction = SCNAction.rotate(by: CGFloat(angleDifference), around: SCNVector3(0, 1, 0), duration: duration)
        
        rotateAction.timingMode = isDecelerating ? .easeOut : .easeIn

        cube.runAction(rotateAction) {
            completion()
        }
    }
}
