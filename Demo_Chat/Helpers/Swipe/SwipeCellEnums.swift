//
//  SwipeCellEnums.swift
//  Demo_Chat
//
//  Created by HungNV on 5/4/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

public enum SwipeCellDirection: UInt {
    case left = 0
    case center
    case right
}

public struct SwipeCellState: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let none = SwipeCellState(rawValue: 0)
    public static let state1 = SwipeCellState(rawValue: (1 << 0))
    public static let state2 = SwipeCellState(rawValue: (1 << 1))
    public static let state3 = SwipeCellState(rawValue: (1 << 2))
    public static let state4 = SwipeCellState(rawValue: (1 << 3))
}

public enum SwipeCellMode: UInt {
    case none = 0
    case exit
    case `switch`
}
