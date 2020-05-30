//
//  AroundTheWorld.swift
//  SimpleDarts
//
//  Created by Tyler on 09/05/2020.
//  Copyright © 2020 Tyler Flottorp. All rights reserved.
//

import UIKit

class AroundTheWorld: UIViewController {
    @IBOutlet weak var restartBarButton: UIBarButtonItem!
    
    @IBOutlet weak var firstPlayerActiveConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondPlayerActiveConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstPlayerNameLabel: UILabel!
    @IBOutlet weak var secondPlayerNameLabel: UILabel!
    @IBOutlet weak var firstPlayerHistoryScroll: UIScrollView!
    @IBOutlet weak var secondPlayerHistoryScroll: UIScrollView!
    @IBOutlet weak var firstPlayerHistoryStack: UIStackView!
    @IBOutlet weak var secondPlayerHistoryStack: UIStackView!
    @IBOutlet weak var firstPlayerTargetLabel: UILabel!
    @IBOutlet weak var secondPlayerTargetLabel: UILabel!
    var activeThrowEntryLabel: UILabel?
    
    weak var firstPlayerCurrentThrowLabel: UILabel?
    weak var secondPlayerCurrentThrowLabel: UILabel?
    
    @IBOutlet var inputButtons: [RoundButton]!
    @IBOutlet weak var trebleButton: RoundButton!
    
    var match: _AroundTheWorldMatch!
    var beganLeg: PlayerReference = .firstPlayer
    var activePlayer:PlayerReference = .firstPlayer {
        didSet {
            if activePlayer != oldValue {
                trebleButton.isEnabled = !match.goingForBull(player: activePlayer)
                
                if activePlayer == .firstPlayer {
                    secondPlayerActiveConstraint.isActive = false
                    firstPlayerActiveConstraint.isActive = true
                } else {
                    firstPlayerActiveConstraint.isActive = false
                    secondPlayerActiveConstraint.isActive = true
                }
            }
        }
    }
    var dartsThrown: Int = 0
    var roundCount:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstPlayerNameLabel.text = match.nameOf(player: .firstPlayer)
        secondPlayerNameLabel.text = match.nameOf(player: .secondPlayer)
        
        for stack in [firstPlayerHistoryStack, secondPlayerHistoryStack] {
            stack?.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            stack?.isLayoutMarginsRelativeArrangement = true
        }
        
        firstPlayerTargetLabel.text = String(match.scoreOf(player: .firstPlayer))
        secondPlayerTargetLabel.text = String(match.scoreOf(player: .secondPlayer))
    }
    
    @IBAction func restartBarButtonTapped(_ sender: UIBarButtonItem) {
        let confirmAlert = UIAlertController(
            title: "Restart the match?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        confirmAlert.addAction(
            UIAlertAction(
                title: "\(match.nameOf(player: .firstPlayer)) throws first",
                style: .default,
                handler: { _ in self.restartMatch(firstDartThrownBy: .firstPlayer) }
            )
        )
        
        confirmAlert.addAction(
            UIAlertAction(
                title: "\(match.nameOf(player: .secondPlayer)) throws first",
                style: .default,
                handler: { _ in self.restartMatch(firstDartThrownBy: .secondPlayer) }
            )
        )
        
        confirmAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        self.present(
            confirmAlert,
            animated: true
        )
    }
    
    @IBAction func endThrowButtonTapped(_ sender: RoundButton) {
        appendScoreToLabel(multiplier: 0)
        endTurn()
    }
    
    @IBAction func multiplierButtonTapped(_ sender: RoundButton) {        
        if let label = activePlayer == .firstPlayer ? firstPlayerTargetLabel : secondPlayerTargetLabel {
            
            appendScoreToLabel(multiplier: sender.tag)
            match.awardScore(to: activePlayer, multiplier: sender.tag)
            
            if match.state() != .contested {
                let alert = UIAlertController(
                    title: nil,
                    message: "Game won by \(match.nameOf(player: activePlayer))!",
                    preferredStyle: .alert
                )
                
                alert.addAction(
                    UIAlertAction(title: "OK",
                        style: .default
                    )
                )
                
                self.present(
                    alert,
                    animated: true,
                    completion: {
                        self.restartBarButton.title = "Rematch"
                        
                        for button in self.inputButtons {
                            button.isEnabled = false
                        }
                    }
                )
                
                return
            }
            
            if match.goingForBull(player: activePlayer) {
                label.text = "Bull"
                trebleButton.isEnabled = false
            } else {
                label.text = String(match.scoreOf(player: activePlayer))
            }
        }
        
        dartsThrown += 1
        
        if dartsThrown == 3 {
            endTurn()
        }
    }
    
    func appendScoreToLabel(multiplier: Int) {
        var entryText: String = ["-", "S", "D", "T"][multiplier]
        if multiplier > 0 {
            entryText.append(String(match.scoreOf(player: activePlayer)) + " ")
        }
        
        if activeThrowEntryLabel == nil {
            activeThrowEntryLabel = UILabel(text: entryText, alignment: .center)
            
            if activePlayer == .firstPlayer {
                firstPlayerHistoryStack.addArrangedSubview(activeThrowEntryLabel!)
            } else {
                secondPlayerHistoryStack.addArrangedSubview(activeThrowEntryLabel!)
            }
        } else {
            activeThrowEntryLabel?.text?.append(entryText)
        }
        
        if activePlayer == .firstPlayer {
            firstPlayerHistoryScroll.scrollToBottom(animated: true)
        } else {
            secondPlayerHistoryScroll.scrollToBottom(animated: true)
        }
    }
    
    func endTurn() {
        dartsThrown = 0
        activeThrowEntryLabel = nil
        
        if activePlayer == .firstPlayer {
            activePlayer = .secondPlayer
        } else {
            activePlayer = .firstPlayer
        }
        
        if activePlayer == beganLeg {
            beginNextRound()
        }
    }
    
    func beginNextRound() {
        
        roundCount += 1
        
        let firstPlayerTarget = UILabel(
            text: "\(roundCount).",
            alignment: .left
        )
        
        firstPlayerHistoryStack.addArrangedSubview(firstPlayerTarget)
        firstPlayerHistoryScroll.scrollToBottom(animated: true)
        
        let secondPlayerTarget = UILabel(
            text: "\(roundCount).",
            alignment: .left
        )
        
        secondPlayerHistoryStack.addArrangedSubview(secondPlayerTarget)
        secondPlayerHistoryScroll.scrollToBottom(animated: true)
    }
    
    func activePlayerWon() {
        let alert = UIAlertController(
            title: nil,
            message: "Game won by \(match.nameOf(player: activePlayer))!",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "OK",
                style: .default
            )
        )
        
        self.present(
            alert,
            animated: true,
            completion: {
                self.restartBarButton.title = "Rematch"
                
                for button in self.inputButtons {
                    button.isEnabled = false
                }
            }
        )
    }
    
    func restartMatch(firstDartThrownBy: PlayerReference) {
        match.restart()
        
        restartBarButton.title = "Restart"
        
        activeThrowEntryLabel = nil
        
        firstPlayerHistoryStack.removeAllSubviewsExceptFirst()
        secondPlayerHistoryStack.removeAllSubviewsExceptFirst()
        
        firstPlayerTargetLabel.text = String(match.scoreOf(player: .firstPlayer))
        secondPlayerTargetLabel.text = String(match.scoreOf(player: .secondPlayer))
        
        beganLeg = firstDartThrownBy
        activePlayer = firstDartThrownBy
        dartsThrown = 0
        roundCount = 1
        
        for button in inputButtons {
            button.isEnabled = true
        }
    }
}
