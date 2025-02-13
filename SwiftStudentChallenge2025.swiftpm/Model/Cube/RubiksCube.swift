//
//  RubiksCube.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 04/02/25.
//

import SceneKit

class RubiksCube: SCNNode {
    var cubeWidth: CGFloat = 1 // pieces size
    var cubeGeometry: SCNBox = SCNBox()
    
    override init() {
        super.init()
        createCube()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createCube() {
        // materials
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.green
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blue
        
        let yellowMaterial = SCNMaterial()
        yellowMaterial.diffuse.contents = UIColor.yellow
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        
        let orangeMaterial = SCNMaterial()
        orangeMaterial.diffuse.contents = UIColor.orange
        
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        
        // initial positions
        let cubeOffsetDistance = self.cubeOffsetDistance()
        var xPos:Float = -cubeOffsetDistance
        var yPos:Float = -cubeOffsetDistance
        var zPos:Float = -cubeOffsetDistance
        
        // iterations for each cube
        for i in 0..<2 {
            for j in 0..<2 {
                for k in 0..<2 {
                    self.cubeGeometry = SCNBox(width: cubeWidth,
                                               height: cubeWidth,
                                               length: cubeWidth,
                                               chamferRadius: 0.2)
                    
                    // applying materials
                    var materials: [SCNMaterial] = []
                    if i == 0 && j == 0 {
                        materials = (k % 2 == 0)
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, blackMaterial, yellowMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, blackMaterial, yellowMaterial]
                    }
                    if i == 0 && j == 1 {
                        materials = (k % 2 == 0)
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, whiteMaterial, blackMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, whiteMaterial, blackMaterial]
                    }
                    if i == 1 && j == 0 {
                        materials = (k % 2 == 0)
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, blackMaterial, yellowMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, blackMaterial, yellowMaterial]
                    }
                    if i == 1 && j == 1 {
                        materials = (k % 2 == 0)
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, whiteMaterial, blackMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, whiteMaterial, blackMaterial]
                    }
                    
                    cubeGeometry.materials = materials
                    
                    // creating cube
                    let cube = SCNNode(geometry: cubeGeometry)
                    cube.position = SCNVector3(x: xPos, y: yPos, z: zPos)
                    
                    xPos += Float(cubeWidth)
                    
                    self.addChildNode(cube)
                }
                xPos = -cubeOffsetDistance
                yPos += Float(cubeWidth)
            }
            xPos = -cubeOffsetDistance
            yPos = -cubeOffsetDistance
            zPos += Float(cubeWidth)
        }
    }
    
    func cubeOffsetDistance() -> Float {
        return Float(cubeWidth / 2)
    }
    
    /// returns the cubes on the correct face based on the `HandAction` made
    /// FACE //// RELATIVE REFERENCIAL POSITION
    /// Up (U)        y == +offset
    /// Down (D)    y == -offset
    /// Right (R)      x == +offset
    /// Left (L)         x == -offset
    /// Face (F)      z == +offset
    /// Back (B)      z == -offset
    func getWall(for action: HandAction) -> [SCNNode] {
        let axis = action.axis
        let layerPosition = action.layerPosition(for: self)
        return getWall(forAxis: axis, layerPosition: layerPosition)
    }

    /// Retorna os cubos da face correta com base no eixo e posição da camada
    private func getWall(forAxis axis: SCNVector3, layerPosition: Float) -> [SCNNode] {
        let nodes = self.childNodes { (child, _) -> Bool in
            let childPosition = getChildPosition(forAxis: axis, node: child)
            return abs(childPosition - layerPosition) < 0.01
        }
        return nodes
    }

    /// Obtém a posição do nó no eixo correto
    private func getChildPosition(forAxis axis: SCNVector3, node: SCNNode) -> Float {
        let position = node.position
        if axis == SCNVector3(1, 0, 0) { // Eixo X (Direita/Esquerda)
            return position.x
        } else if axis == SCNVector3(0, 1, 0) { // Eixo Y (Cima/Baixo)
            return position.y
        } else { // Eixo Z (Frente/Trás)
            return position.z
        }
    }
}


//class RubiksCube: SCNNode {
//    let cubeWidth: CGFloat = 1.0
//    let cubeOffset: Float
//    
//    override init() {
//        self.cubeOffset = Float(cubeWidth / 2)
//        super.init()
//        createCube()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func createCube() {
//        let materials = [
//            UIColor.green, UIColor.red, UIColor.blue,
//            UIColor.yellow, UIColor.white, UIColor.orange
//        ].map { color -> SCNMaterial in
//            let material = SCNMaterial()
//            material.diffuse.contents = color
//            return material
//        }
//        
//        for i in 0..<2 {
//            for j in 0..<2 {
//                for k in 0..<2 {
//                    let cube = SCNNode(geometry: SCNBox(width: cubeWidth, height: cubeWidth, length: cubeWidth, chamferRadius: 0.15))
//                    cube.geometry?.materials = materials
//                    cube.position = SCNVector3(
//                        x: Float(i) * Float(cubeWidth) - cubeOffset,
//                        y: Float(j) * Float(cubeWidth) - cubeOffset,
//                        z: Float(k) * Float(cubeWidth) - cubeOffset
//                    )
//                    self.addChildNode(cube)
//                }
//            }
//        }
//    }
//    
//    private func getPositionForAxis(_ axis: SCNVector3, node: SCNNode) -> Float {
//        if axis.x == 1 { return node.position.x }
//        if axis.y == 1 { return node.position.y }
//        if axis.z == 1 { return node.position.z }
//        fatalError("Invalid axis")
//    }
//    
//    func getWall(for axis: SCNVector3, negative: Bool) -> [SCNNode] {
//        let reference = negative ? -cubeOffset : cubeOffset
//        return self.childNodes { node, _ in
//            getPositionForAxis(axis, node: node).isClose(to: reference, tolerance: 0.01)
//        }
//    }
//}
//
//extension Float {
//    func isClose(to value: Float, tolerance: Float) -> Bool {
//        return abs(self - value) < tolerance
//    }
//}
