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
    
    //Light estimate from current session's frame
    // calculate blend factor 0(brightest) - 1
    guard
      let currentFrame = sceneView.session.currentFrame,
      let lightEstimate = currentFrame.lightEstimate else {
        return
    }
    
    let neutralIntensity: CGFloat = 1000
    let ambientIntensity = min(lightEstimate.ambientIntensity, neutralIntensity)
    let blendFactor = 1 - ambientIntensity / neutralIntensity
    
    for node in children {
      if let bug = node as? SKSpriteNode {
        bug.color = .black
        bug.colorBlendFactor = blendFactor
      }
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
