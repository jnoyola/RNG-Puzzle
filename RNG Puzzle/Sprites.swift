// ---------------------------------------
// Sprite definitions for 'Sprites'
// Generated with TexturePacker 3.9.4
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

import SpriteKit


class Sprites {

    // sprite names
    let BALL          = "ball"
    let BLOCK         = "block"
    let CORNER1       = "corner1"
    let CORNER2       = "corner2"
    let CORNER3       = "corner3"
    let CORNER4       = "corner4"
    let FINGER        = "finger"
    let FINGER_SHADOW = "finger_shadow"
    let TARGET        = "target"
    let TELEPORT      = "teleport"

    // load texture atlas
    let textureAtlas = SKTextureAtlas(named: "Sprites")

    // individual texture objects
    func ball() -> SKTexture          { return textureAtlas.textureNamed(BALL) }
    func block() -> SKTexture         { return textureAtlas.textureNamed(BLOCK) }
    func corner1() -> SKTexture       { return textureAtlas.textureNamed(CORNER1) }
    func corner2() -> SKTexture       { return textureAtlas.textureNamed(CORNER2) }
    func corner3() -> SKTexture       { return textureAtlas.textureNamed(CORNER3) }
    func corner4() -> SKTexture       { return textureAtlas.textureNamed(CORNER4) }
    func finger() -> SKTexture        { return textureAtlas.textureNamed(FINGER) }
    func finger_shadow() -> SKTexture { return textureAtlas.textureNamed(FINGER_SHADOW) }
    func target() -> SKTexture        { return textureAtlas.textureNamed(TARGET) }
    func teleport() -> SKTexture      { return textureAtlas.textureNamed(TELEPORT) }
}
