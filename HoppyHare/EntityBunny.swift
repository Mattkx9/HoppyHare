//
//  Hero.swift
//  HoppyHare
//
//  Created by Matthew Mehrtens on 1/10/17.
//  Copyright © 2017 Mattkx4 Apps. All rights reserved.
//

import GameplayKit

class EntityBunny: UIElement {
    var bunny: SKSpriteNode!
    
    /* Adds the bunny onto the screen */
    override func addElement() {
        super.addElement()
        bunny = referenceNode.childNode(withName: "//bunny") as! SKSpriteNode // Assigns the bunny sprite node to the bunny instance
        bunny.position = CGPoint(x: -88, y: 375) // Sets the position of the bunny within the referenceNode
    }
    
    /* Propels the hero into the air */
    func jump() {
        /* Reset velocity, helps improve response against cumulative falling velocity */
        bunny.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        /* Apply vertical impulse */
        bunny.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 180))
        
        /* Play SFX */
        if GameStats.getStat(statName: GameStats.soundEnabled) == 1 {
            Sounds.playSound(soundName: "jump", object: self.baseScene)
        }
        
        /* Apply subtle rotation */
        bunny.physicsBody?.applyAngularImpulse(CGFloat(0.1))
    }
    
    /* Rotate the hero after a jump */
    func rotateHero(sinceTouch: TimeInterval) {
        /* Apply falling rotation */
        if sinceTouch > 0.29 { // Make this number smaller to start the falling rotation sooner
            let impulse = -20000 * TimeInterval(1.0/60.0)
            bunny.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }
        
        /* Clamp rotation */
        bunny.zRotation = bunny.zRotation.clamped(CGFloat(-10).degreesToRadians(), CGFloat(15).degreesToRadians()) // Negative number is the most it is allowed to turn downwards. Positive number is the max rotation upwards.
        bunny.physicsBody!.angularVelocity = bunny.physicsBody!.angularVelocity.clamped(-1, 1) // This clamp makes it so that the velocity never gets to high or low. Adjust these numbers to make the rotation happen faster/slower.
    }
    
    /* Cap the bunny's vertical velocity */
    func capBunnyVelocityY() {
        /* Grab current velocity */
        let velocityY = bunny.physicsBody?.velocity.dy ?? 0
        
        /* Check and cap vertical velocity */
        if velocityY > 350 {
            bunny.physicsBody?.velocity.dy = 350
        }
    }
    
    /* Caps the bunny's y-coord to make sure you can't go above the screen. */
    func capBunnyY() {
        if (referenceNode.convert(bunny.position, to: baseScene)).y >= (baseScene.size.height / 2) - (bunny.size.height * (3/4)) {
            bunny.physicsBody?.velocity.dy = 0
        }
    }
    
    /* Kill the hero */
    func killHero() {
        /* Stop any new angular velocity being applied */
        bunny.physicsBody?.allowsRotation = false
        
        /* Reset angular velocity */
        bunny.physicsBody?.angularVelocity = 0
        
        /* Stop hero flapping animation */
        bunny.removeAllActions()
        
        /* Create our hero death sequence. After setting the bunny's zRotation and collisionBitMask, we wait 2 seconds then delete the node. */
        bunny.run(SKAction.sequence([SKAction.run {
            /* Put our hero face down in the dirt */
            self.bunny.zRotation = CGFloat(-90).degreesToRadians()
            
            /* Stop hero from colliding with anything else */
            self.bunny.physicsBody?.collisionBitMask = 0
            }, SKAction.wait(forDuration: TimeInterval(2.0)), SKAction.run { self.removeElement() }]))
    }
}