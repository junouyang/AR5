//
//  ViewController.swift
//  AR5
//
//  Created by Jun Ouyang on 9/19/18.
//  Copyright © 2018 Jun Ouyang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planeNode: SCNShape!
    var planeY: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
        self.sceneView.autoenablesDefaultLighting = true
        addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin ]
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    fileprivate func renderCube(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.03)
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        node.position = SCNVector3(x, y + 0.05, z)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func add(_ sender: Any) {
        let x = randomNumbers(firstNumber: -0.3, secondNumber: 0.3)
        let y = randomNumbers(firstNumber: -0.3, secondNumber: 0.3)
        let z = randomNumbers(firstNumber: -0.3, secondNumber: 0.3)
        renderCube(x, y, z)
    }
    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.5)
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
        planeY = planeAnchor.center.y
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
//        node.enumerateChildNodes { (node, stop) in
//            node.removeFromParentNode()
//        }
//        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
//            node.removeFromParentNode() }

        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planeY = planeAnchor.center.y
    }

    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
//        guard let shipScene = SCNScene(named: "art.scnassets/ship.scn"),
//              let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
//        else { return }
//
//
//        shipNode.position = SCNVector3(x,y,z)
//        sceneView.scene.rootNode.addChildNode(shipNode)
//        renderCube(CGFloat(x), CGFloat(y), CGFloat(z))
//        drawLine(x, y, z)
//        drawPlane(x, planeY, z)
        drawPlane(x, y, z)
    }

    func drawPlane(_ x: Float, _ y: Float, _ z: Float) {
        let node = SCNNode()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(x), y: CGFloat(y - 0.3)))
        path.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y + 0.3)))
        let shape = SCNShape(path: path, extrusionDepth: 1)
        node.geometry = shape
        node.geometry?.firstMaterial?.specular.contents = UIColor.orange
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    
    func drawLine(_ x: Float, _ y: Float, _ z: Float) {
        let vector1 = SCNVector3(x, y, z)
        let vector2 = SCNVector3(x + 100, y, z)
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let lineNode = SCNNode(geometry: geometry)
        lineNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(lineNode)
    }

    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    func randomNumbers(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat {
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
}
