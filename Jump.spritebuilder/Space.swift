//
//  Space.swift
//  Jump
//
//  Created by Boris Yue on 7/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Space: CCNode {
    static var canSpawn: Float = 0.0
    
//    func didLoadFromCCB() {
//        var planet1 = "planets/Planet-2@4x.png"
//        var planet2 = "planets/Planet-5@4x.png"
//        var planet3 = "planets/Planet-6@4x.png"
//        var planet4 = "planets/Planet-9@4x.png"
//        var planet5 = "planets/Planet-10@4x.png"
//        var planet6 = "planets/Planet-12@4x.png"
//        var planet: CCSprite
//        var spawn = CCRANDOM_0_1()
//        var rand = CCRANDOM_0_1()
//        if spawn < Space.canSpawn {
//            var randX = CCRANDOM_0_1() * 320
//            var randY = CCRANDOM_0_1() * 400 + 100
//            if rand < 0.17 {
//                planet = CCSprite(imageNamed: planet1)
//            }
//            else if rand < 0.34 {
//                planet = CCSprite(imageNamed: planet2)
//            }
//            else if rand < 0.51 {
//                planet = CCSprite(imageNamed: planet3)
//            }
//            else if rand < 0.68 {
//                planet = CCSprite(imageNamed: planet4)
//            }
//            else if rand < 0.85 {
//                planet = CCSprite(imageNamed: planet5)
//            }
//            else {
//                planet = CCSprite(imageNamed: planet6)
//            }
//            planet.scale = 0.5
//            self.addChild(planet)
//            planet.position = ccp(CGFloat(randX),CGFloat(randY))
//            planet.opacity = 0.75
//        }
//        Space.canSpawn += 0.018
//        if Space.canSpawn >= 0.35 {
//            Space.canSpawn = 0.35
//        }
//       
//   }
    
//    override func update(delta: CCTime) {
//        spawnPlanets()
//    }
//    func spawnPlanets() {
//        var planet = CCSprite(imageNamed: "planets/Planet-2@4x.png")
//        planet.scale = 0.5
//        contentNode.addChild(planet)
//        planet.position = ccp(200,1000)
//
//    }
}
