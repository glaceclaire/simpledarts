//
//  MatchClasses.swift
//  SimpleDarts
//
//  Created by Tyler on 18/04/2020.
//  Copyright © 2020 Tyler. All rights reserved.
//

import Foundation

enum Mode {
    case classic, aroundTheWorld, cricket
}

enum PlayerReference {
    case firstPlayer, secondPlayer
}

enum InputMethod {
    case individualDarts, total
}

enum ThrowResult {
    case normal, checkOut, bust
}

enum WinType: String {
    case leg = "Leg"
    case set = "Set"
    case game = "Game"
}

enum ContestState {
    case contested, wonByFirstPlayer, wonBySecondPlayer
}

struct Dart {
    var base: Int
    var multiplier: Int
}

class Player {
    var name: String
    var score: Int = 0
    
    init(playerName: String, initialScore: Int = 0) {
        name = playerName
        score = initialScore
    }
}

class X01Player: Player {
    var doubledIn: Bool = false
    var legCount: Int = 0
    var setCount: Int = 0
    
    init(playerName: String, target: Int) {
        super.init(playerName: playerName)
        
        score = target
    }
}

class _AroundTheWorldPlayer: Player {
    var isGoingForBull: Bool = false
}

class _CricketPlayer: Player {
    var tallies: [Int] = Array(repeating: 0, count: 7)
}

class Contest {
    
    fileprivate var firstPlayer: Player
    fileprivate var secondPlayer: Player
    
    fileprivate var contestState: ContestState = .contested
    
    init(firstPlayerName: String, secondPlayerName: String) {
        firstPlayer = Player(playerName: firstPlayerName)
        secondPlayer = Player(playerName: secondPlayerName)
    }
    
    func nameOf(player: PlayerReference) -> String {
        if player == .firstPlayer {
            return firstPlayer.name
        } else {
            return secondPlayer.name
        }
    }
    
    func scoreOf(player: PlayerReference) -> Int {
        if player == .firstPlayer {
            return firstPlayer.score
        } else {
            return secondPlayer.score
        }
    }
    
    func state() -> ContestState {
        return contestState
    }
    
    func restart() {
        contestState = .contested
    }
}

class _AroundTheWorldMatch: Contest {
    fileprivate var _firstPlayer: _AroundTheWorldPlayer
    fileprivate var _secondPlayer: _AroundTheWorldPlayer
    
    fileprivate override var firstPlayer: Player {
        get { return _firstPlayer }
        set {
            if let cast = newValue as? _AroundTheWorldPlayer {
                _firstPlayer = cast
            }
        }
    }
    
    fileprivate override var secondPlayer: Player {
        get { return _secondPlayer }
        set {
            if let cast = newValue as? _AroundTheWorldPlayer {
                _secondPlayer = cast
            }
        }
    }
    
    private var countUp: Bool
    private var bullToWin: Bool
    private var targetOrder: [Int]
    
    init(firstPlayerName: String, secondPlayerName: String, countUp: Bool, bullToWin: Bool) {
        _firstPlayer = _AroundTheWorldPlayer(playerName: firstPlayerName)
        _secondPlayer = _AroundTheWorldPlayer(playerName: secondPlayerName)
        
        self.countUp = countUp
        self.bullToWin = bullToWin
        
        targetOrder = [Int](1 ... 20)
        if !countUp {
            targetOrder.reverse()
        }
        targetOrder.append(25)
        
        super.init(firstPlayerName: firstPlayerName, secondPlayerName: secondPlayerName)
    }
    
    override func scoreOf(player: PlayerReference) -> Int {
        let index = super.scoreOf(player: player)
        return targetOrder[index]
    }
    
    func goingForBull(player: PlayerReference) -> Bool {
        let player = player == .firstPlayer ? _firstPlayer : _secondPlayer
        return player.isGoingForBull
    }
    
    func awardScore(to player: PlayerReference, multiplier: Int) {
        let handle = player == .firstPlayer ? _firstPlayer : _secondPlayer
        var won = false
        
        if bullToWin && handle.isGoingForBull {
            won = true
        } else {
            handle.score = min(targetOrder.count - 1, handle.score + multiplier)
            
            if handle.score == targetOrder.count - 1 {
                if bullToWin {
                    handle.isGoingForBull = true
                } else {
                    won = true
                }
            }
        }
        
        if won {
            if player == .firstPlayer {
                contestState = .wonByFirstPlayer
            } else {
                contestState = .wonBySecondPlayer
            }
        }
    }
    
    override func restart() {
        _firstPlayer.score = 0
        _secondPlayer.score = 0
        
        _firstPlayer.isGoingForBull = false
        _secondPlayer.isGoingForBull = false
        super.restart()
    }
}

class ClassicPlayer {
    var name: String
    var target: Int
    var doubledIn: Bool = false
    var legs: Int = 0
    var sets: Int = 0
    
    init(playerName: String, targetScore: Int) {
        self.name = playerName
        self.target = targetScore
    }
}

class ClassicMatch {
    private var firstPlayer: ClassicPlayer
    private var secondPlayer: ClassicPlayer
    
    private var target: Int
    private var doubleIn: Bool
    private var doubleOut: Bool
    private var northernBust: Bool
    private var legsPerSet: Int
    private var setsToWin: Int
    private var firstPlayerBeginsLeg: Bool = true
    private var state: ContestState = .contested
    
    init(firstPlayerName: String, secondPlayerName: String, targetScore: Int, doubleInRequired: Bool, doubleOutRequired: Bool, northernBustEnabled: Bool, legsPerSet: Int, setsToWin: Int) {
        self.firstPlayer = ClassicPlayer(playerName: firstPlayerName, targetScore: targetScore)
        self.secondPlayer = ClassicPlayer(playerName: secondPlayerName, targetScore: targetScore)
        
        target = targetScore
        doubleIn = doubleInRequired
        doubleOut = doubleOutRequired
        northernBust = northernBustEnabled
        self.legsPerSet = legsPerSet
        self.setsToWin = setsToWin
    }
    
    func nameOf(player: PlayerReference) -> String {
        if player == .firstPlayer {
            return firstPlayer.name
        } else {
            return secondPlayer.name
        }
    }
    
    func scoreOf(player: PlayerReference) -> Int {
        if player == .firstPlayer {
            return firstPlayer.target
        } else {
            return secondPlayer.target
        }
    }
    
    func recordStringOf(player: PlayerReference) -> String {
        let player = (player == .firstPlayer ? firstPlayer : secondPlayer)
        
        return "\(String(player.sets)):\(String(player.legs))"
    }
    
    func scoreDarts(player: PlayerReference, darts: [Dart]) -> ThrowResult {
        let player = (player == .firstPlayer ? firstPlayer : secondPlayer)
        
        for dart in darts {
            let newTarget = player.target - dart.multiplier * dart.base
            
            if newTarget == 0 && doubleOut && dart.multiplier != 2 {
                return .bust
            } else if newTarget < 0 || (newTarget == 1 && self.doubleOut) {
                return .bust
            } else {
                player.target = newTarget
                
                if player.target == 0 {
                    return .checkOut
                }
            }
        }
        
        return .normal
    }
    
    func scoreThrow(player: PlayerReference, throwTotal: Int) -> ThrowResult {
        let player = (player == .firstPlayer ? firstPlayer : secondPlayer)
        
        let newTarget = player.target - throwTotal
        
        if newTarget < 0 || (newTarget == 1 && self.doubleOut) {
            return .bust
        } else {
            player.target = newTarget
            
            if player.target == 0 {
                return .checkOut
            }
            
            return .normal
        }
    }
    
    func awardLeg(player: PlayerReference) -> WinType {
        let ref = player
        let player = player == .firstPlayer ? firstPlayer : secondPlayer
        
        var type = WinType.leg
        
        player.legs += 1
        if player.legs == legsPerSet {
            type = .set
            
            firstPlayer.legs = 0
            secondPlayer.legs = 0
            
            player.sets += 1
            if player.sets == setsToWin {
                type = .game
                state = (ref == .firstPlayer ? .wonByFirstPlayer : .wonBySecondPlayer)
            }
        }
        
        firstPlayer.target = target
        secondPlayer.target = target
        
        if doubleIn {
            firstPlayer.doubledIn = false
            secondPlayer.doubledIn = false
        }
        
        firstPlayerBeginsLeg = !firstPlayerBeginsLeg
        
        return type
    }
    
    func firstDart() -> PlayerReference {
        if firstPlayerBeginsLeg {
            return .firstPlayer
        } else {
            return .secondPlayer
        }
    }
    
    func matchState() -> ContestState {
        return state
    }
    
    func restart() {
        firstPlayer.target = target
        secondPlayer.target = target
        
        firstPlayer.doubledIn = false
        secondPlayer.doubledIn = false
        
        firstPlayer.legs = 0
        secondPlayer.legs = 0
        
        firstPlayer.sets = 0
        secondPlayer.sets = 0
        
        firstPlayerBeginsLeg = true
    }
}

class AroundTheWorldPlayer {
    var name: String
    var targetIndex: Int = 0
    var isGoingForBull: Bool = false
    
    init(playerName: String) {
        name = playerName
    }
}

class AroundTheWorldMatch {
    private var firstPlayer: AroundTheWorldPlayer
    private var secondPlayer: AroundTheWorldPlayer
    
    private var state: ContestState = .contested
    private var countUp: Bool
    private var bullToWin: Bool
    private var targetOrder: [Int]
    
    init(firstPlayerName: String, secondPlayerName: String, countUp: Bool, bullToWin: Bool) {
        firstPlayer = AroundTheWorldPlayer(playerName: firstPlayerName)
        secondPlayer = AroundTheWorldPlayer(playerName: secondPlayerName)
        
        self.countUp = countUp
        self.bullToWin = bullToWin
        
        targetOrder = [Int](1 ... 20)
        if !self.countUp {
            targetOrder.reverse()
        }
        targetOrder.append(25)
    }
    
    func nameOf(player: PlayerReference) -> String {
        let player = player == .firstPlayer ? firstPlayer : secondPlayer
        
        return player.name
    }
    
    func scoreOf(player: PlayerReference) -> Int {
        let player = player == .firstPlayer ? firstPlayer : secondPlayer
        
        return self.targetOrder[player.targetIndex]
    }
    
    func goingForBull(player: PlayerReference) -> Bool {
        let player = player == .firstPlayer ? firstPlayer : secondPlayer
        
        return player.isGoingForBull
    }
    
    func awardScore(toPlayer: PlayerReference, multiplier: Int) {
        let player = toPlayer == .firstPlayer ? firstPlayer : secondPlayer
        var won = false
        
        if bullToWin && player.isGoingForBull {
            won = true
        } else {
            player.targetIndex = min(targetOrder.count - 1, player.targetIndex + multiplier)
            
            if player.targetIndex == targetOrder.count - 1 {
                if bullToWin {
                    player.isGoingForBull = true
                } else {
                    won = true
                }
            }
        }
        
        if won {
            if toPlayer == .firstPlayer {
                state = .wonByFirstPlayer
            } else {
                state = .wonBySecondPlayer
            }
        }
    }
    
    func gameState() -> ContestState {
        return state
    }
    
    func restart() {
        firstPlayer.targetIndex = 0
        firstPlayer.isGoingForBull = false
        
        secondPlayer.targetIndex = 0
        secondPlayer.isGoingForBull = false
        
        state = .contested
    }
}

class CricketPlayer {
    var name: String
    var score: Int
    var tallies: [Int] = Array(repeating: 0, count: 7)
    
    init(playerName: String) {
        self.name = playerName
        self.score = 0
    }
}

class CricketMatch {
    var firstPlayer: CricketPlayer
    var secondPlayer: CricketPlayer
    
    init(firstPlayerName: String, secondPlayerName: String) {
        firstPlayer = CricketPlayer(playerName: firstPlayerName)
        secondPlayer = CricketPlayer(playerName: secondPlayerName)
    }
    
    func checkForWin(player: PlayerReference) -> Bool {
        let scoreToBeat = scoreOfOpponent(opponentOf: player)
        let player = player == .firstPlayer ? self.firstPlayer : self.secondPlayer
        
        if player.score < scoreToBeat {
            return false
        }
        
        for target in player.tallies {
            if target < 3 {
                return false
            }
        }
        
        return true
    }
    
    func awardTallies(player: PlayerReference, target: Int, multiplier: Int) -> Int {
        let countOfOpponent = talliesOfOpponent(opponentOf: player, target: target),
            player = player == .firstPlayer ? self.firstPlayer : self.secondPlayer,
            index = self.getTargetIndex(target: target)
        
        if countOfOpponent >= 3 {
            if player.tallies[index] < 3 {
                player.tallies[index] = min(3, player.tallies[index] + multiplier)
            }
        } else {
            let count = player.tallies[index]
            let newCount = count + multiplier
            
            if count >= 3 {
                player.score += target * multiplier
            } else if newCount > 3 {
                player.score += target * (newCount - count)
            }
            player.tallies[index] = newCount
        }
        
        return player.tallies[index]
    }
    
    func talliesOfOpponent(opponentOf: PlayerReference, target: Int) -> Int {
        let index = self.getTargetIndex(target: target)
        
        if opponentOf == .firstPlayer {
            return self.secondPlayer.tallies[index]
        } else {
            return self.firstPlayer.tallies[index]
        }
    }
    
    func scoreOf(player: PlayerReference) -> Int {
        if player == .firstPlayer {
            return self.firstPlayer.score
        } else {
            return self.secondPlayer.score
        }
    }
    
    func scoreOfOpponent(opponentOf: PlayerReference) -> Int {
        if opponentOf == .firstPlayer {
            return self.secondPlayer.score
        } else {
            return self.firstPlayer.score
        }
    }
    
    private func getTargetIndex(target: Int) -> Int {
        if target == 25 {
            return 6
        } else {
            return 20 - target
        }
    }
}
