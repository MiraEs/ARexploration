import ARKit

class GameScene: SKScene {
  
  //MARK: CONSTANTS
  private let neuralIntensity: CGFloat = 1000
  private var blendFactor: CGFloat?

  //MARK: GAMEPLAY
  private var sight: SKSpriteNode!
  
  //MARK: SETUP PROPERTIES
  private var isWorldSetUp = false
  
  private var sceneView: ARSKView {
    return view as! ARSKView
  }
  
  override func update(_ currentTime: TimeInterval) {
    if !isWorldSetUp {
      setUpWorld()
    }
    
    lightEstimate()
    setShadow()
  }
  
  //MARK: SETUP FUNCTIONS
  
  private func lightEstimate() {
    guard let currentFrame = sceneView.session.currentFrame,
          let lightEstimate = currentFrame.lightEstimate else {
        return
    }
    
    let ambientIntensity = min(lightEstimate.ambientIntensity, neuralIntensity)
    blendFactor = 1 - ambientIntensity / neuralIntensity
  }
  
  private func setShadow() {
    guard let blendFactor = blendFactor else {
      return
    }
    
    for node in children {
      if let bug = node as? SKSpriteNode {
        bug.color = .black
        bug.colorBlendFactor = blendFactor
      }
    }
  }
  
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
  
  //MARK: GAMEPLAY SETUP
  override func didMove(to view: SKView) {
    sight = SKSpriteNode(imageNamed: "sight")
    addChild(sight)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let location = sight.position
    let hitNodes = nodes(at: location)
    var hitBug: SKNode?
    
    //Set up "hit behavior" of nodes that are of type "bug"
    for node in hitNodes {
      if node.name == "bug" {
        hitBug = node
        break
      }
    }
    
    run(Sounds.fire)
    if let hitBug = hitBug,
      let anchor = sceneView.anchor(for: hitBug) {
      let action = SKAction.run {
        self.sceneView.session.remove(anchor: anchor)
      }
      let group = SKAction.group([Sounds.hit, action])
      let sequence = [SKAction.wait(forDuration: 0.3), group]
      hitBug.run(SKAction.sequence(sequence))
    }
    
  }
}
