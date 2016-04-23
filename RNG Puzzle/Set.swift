//
//  Set.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/31/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

extension Set {

    func duplicate() -> Set<Element> {
        var newSet = Set<Element>()
        for element in self {
            newSet.insert(element)
        }
        return newSet
    }
}
