//
//  RubiksCube.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 04/02/25.
//

import SceneKit

class Cube: SCNNode {
    var cubeWidth: CGFloat = 1 // eachh piece size
    var cubeGeometry: SCNBox = SCNBox()
    
    override init() {
        super.init()
        buildCube()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildCube() {
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
        
        let reflectionMaterial = SCNMaterial()
        reflectionMaterial.reflective.contents = UIColor.white
        reflectionMaterial.reflective.intensity = 0.5
        reflectionMaterial.shininess = 1.0

        // initial positions
        let cubeOffsetDistance = self.offsetSpace()
        var xPos:Float = -cubeOffsetDistance
        var yPos:Float = -cubeOffsetDistance
        var zPos:Float = -cubeOffsetDistance
        
        // iterations to build the cube
        for x in 0..<2 {
            for y in 0..<2 {
                for z in 0..<2 {
                    self.cubeGeometry = SCNBox(width: cubeWidth,
                                               height: cubeWidth,
                                               length: cubeWidth,
                                               chamferRadius: 0.2)
                    
                    // applying materials
                    var materials: [SCNMaterial] = []
                    if x == 0 && y == 0 {
                        materials = (z % 2 == 0)
                        ? [blackMaterial, blackMaterial, yellowMaterial, orangeMaterial, blackMaterial, greenMaterial]
                        : [blackMaterial, redMaterial, yellowMaterial, blackMaterial, blackMaterial, greenMaterial]
                    }
                    if x == 0 && y == 1 {
                        materials = (z % 2 == 0)
                        ? [blackMaterial, blackMaterial, yellowMaterial, orangeMaterial, blueMaterial, blackMaterial]
                        : [blackMaterial, redMaterial, yellowMaterial, blackMaterial, blueMaterial, blackMaterial]
                    }
                    if x == 1 && y == 0 {
                        materials = (z % 2 == 0)
                        ? [whiteMaterial, blackMaterial, blackMaterial, orangeMaterial, blackMaterial, greenMaterial]
                        : [whiteMaterial, redMaterial, blackMaterial, blackMaterial, blackMaterial, greenMaterial]
                    }
                    if x == 1 && y == 1 {
                        materials = (z % 2 == 0)
                        ? [whiteMaterial, blackMaterial, blackMaterial, orangeMaterial, blueMaterial, blackMaterial]
                        : [whiteMaterial, redMaterial, blackMaterial, blackMaterial, blueMaterial, blackMaterial]
                    }
                    
                    cubeGeometry.materials = materials
                
                    let specularMaterial = SCNMaterial()
                    specularMaterial.specular.contents = UIColor.white
                    specularMaterial.shininess = 2

                    for material in materials {
                        material.specular.contents = specularMaterial.specular.contents
                        material.shininess = specularMaterial.shininess
                    }
                    
                    // building the cube
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
    
    func offsetSpace() -> Float {
        return Float(cubeWidth / 2)
    }
    
    /// returns the cubes on the correct face based on the HandAction made
    /// FACE //// RELATIVE REFERENCIAL POSITION
    /// up (U)        y == +offset
    /// down (D)    y == -offset
    /// right (R)      x == +offset
    /// left (L)         x == -offset
    /// face (F)      z == +offset
    /// back (B)      z == -offset
    func getWall(for action: HandAction) -> [SCNNode] {
        let axis = action.axis
        let layerPosition = action.layerPosition(for: self)
        return getWall(forAxis: axis, layerPosition: layerPosition)
    }

    private func getWall(forAxis axis: SCNVector3, layerPosition: Float) -> [SCNNode] {
        let nodes = self.childNodes { (child, _) -> Bool in
            let childPosition = getChildPosition(forAxis: axis, node: child)
            return abs(childPosition - layerPosition) < 0.01
        }
        return nodes
    }

    private func getChildPosition(forAxis axis: SCNVector3, node: SCNNode) -> Float {
        let position = node.position
        if axis == SCNVector3(1, 0, 0) { // X
            return position.x
        } else if axis == SCNVector3(0, 1, 0) { // Y
            return position.y
        } else { // Z
            return position.z
        }
    }
}
