// ---------------------------------------
// Sprite definitions for 'pieces'
// Generated with TexturePacker 4.2.2
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

import SpriteKit


class PieceSprites {

    // sprite names
    let BLOCK         = "block"
    let CORNER1       = "corner1"
    let CORNER2       = "corner2"
    let CORNER3       = "corner3"
    let CORNER4       = "corner4"
    let FINGER        = "finger"
    let FINGER_SHADOW = "finger_shadow"
    let TARGET        = "target"
    let TELEPORTER    = "teleporter"


    // load texture atlas
    let textureAtlas = SKTextureAtlas(named: "pieces")


    // individual texture objects
    func block() -> SKTexture         { return textureAtlas.textureNamed(BLOCK) }
    func corner1() -> SKTexture       { return textureAtlas.textureNamed(CORNER1) }
    func corner2() -> SKTexture       { return textureAtlas.textureNamed(CORNER2) }
    func corner3() -> SKTexture       { return textureAtlas.textureNamed(CORNER3) }
    func corner4() -> SKTexture       { return textureAtlas.textureNamed(CORNER4) }
    func finger() -> SKTexture        { return textureAtlas.textureNamed(FINGER) }
    func finger_shadow() -> SKTexture { return textureAtlas.textureNamed(FINGER_SHADOW) }
    func target() -> SKTexture        { return textureAtlas.textureNamed(TARGET) }
    func teleporter() -> SKTexture    { return textureAtlas.textureNamed(TELEPORTER) }


    // texture arrays for animations
    func corner() -> [SKTexture] {
        return [
            corner1(),
            corner2(),
            corner3(),
            corner4()
        ]
    }


}
