import ARKit

class GameScene: SKScene {
  
  var sceneView: ARSKView {
    return view as! ARSKView
  }
  
  var isWorldSetUp = false
  
  override func update(_ currentTime: TimeInterval) {
    if !isWorldSetUp {
      setUpWorld()
    }
    
    
  }
  
  //MARK: Private
  
  private func setUpWorld() {
    guard let currentFrame = sceneView.session.currentFrame else {
      return
    }
    
    //Sets node/image 0.3m in front of you in a 4x4 matrix, in front of camera
    var translation = matrix_identity_float4x4
    translation.columns.3.z = -0.3
    
    let transform = currentFrame.camera.transform * translation
    let anchor = ARAnchor(transform: transform)
    sceneView.session.add(anchor: anchor)
    
    isWorldSetUp = true
  }
}
