//
//  Cricket.swift
//  SimpleDarts
//
//  Created by Tyler on 18/05/2020.
//  Copyright © 2020 Tyler Flottorp. All rights reserved.
//

import UIKit

class Cricket: UIViewController {

    @IBOutlet weak var firstPlayerActiveConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondPlayerActiveConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstPlayerNameLabel: UILabel!
    @IBOutlet weak var secondPlayerNameLabel: UILabel!
    @IBOutlet weak var firstPlayerScoreLabel: UILabel!
    @IBOutlet weak var secondPlayerScoreLabel: UILabel!
    
    
    @IBOutlet weak var firstPlayerTalliesTwentyLabel: UILabel!
    @IBOutlet weak var firstPlayerTalliesNineteenLabel: UILabel!
    @IBOutlet weak var firstPlayerTalliesEighteenLabel: UILabel!
    @IBOutlet weak var firstPlayerTalliesSeventeenLabel: UILabel!
    @IBOutlet weak var firstPlayerTalliesSixteenLabel: UILabel!
    @IBOutlet weak var firstPlayerTalliesFifteenLabel: UILabel!
    @IBOutlet weak var firstPlayerTalliesBullLabel: UILabel!
    private lazy var firstPlayerTallyLabels: [UILabel] = [
        firstPlayerTalliesTwentyLabel,
        firstPlayerTalliesNineteenLabel,
        firstPlayerTalliesEighteenLabel,
        firstPlayerTalliesSeventeenLabel,
        firstPlayerTalliesSixteenLabel,
        firstPlayerTalliesFifteenLabel,
        firstPlayerTalliesBullLabel
    ]
    
    @IBOutlet weak var twentyButton: UIButton!
    @IBOutlet weak var nineteenButton: UIButton!
    @IBOutlet weak var eighteenButton: UIButton!
    @IBOutlet weak var seventeenButton: UIButton!
    @IBOutlet weak var sixteenButton: UIButton!
    @IBOutlet weak var fifteenButton: UIButton!
    @IBOutlet weak var bullButton: UIButton!
    
    @IBOutlet weak var secondPlayerTalliesTwentyLabel: UILabel!
    @IBOutlet weak var secondPlayerTalliesNineteenLabel: UILabel!
    @IBOutlet weak var secondPlayerTalliesEighteenLabel: UILabel!
    @IBOutlet weak var secondPlayerTalliesSeventeenLabel: UILabel!
    @IBOutlet weak var secondPlayerTalliesSixteenLabel: UILabel!
    @IBOutlet weak var secondPlayerTalliesFifteenLabel: UILabel!
    @IBOutlet weak var secondPlayerTalliesBullLabel: UILabel!
    private lazy var secondPlayerTallyLabels: [UILabel] = [
        secondPlayerTalliesTwentyLabel,
        secondPlayerTalliesNineteenLabel,
        secondPlayerTalliesEighteenLabel,
        secondPlayerTalliesSeventeenLabel,
        secondPlayerTalliesSixteenLabel,
        secondPlayerTalliesFifteenLabel,
        secondPlayerTalliesBullLabel
    ]
    
    @IBOutlet weak var singleButton: RoundButton!
    @IBOutlet weak var doubleButton: RoundButton!
    @IBOutlet weak var trebleButton: RoundButton!
    
    var match: CricketMatch!
    var activePlayer: PlayerReference = .firstPlayer {
        didSet {
            if activePlayer == oldValue {
                return
            }
            
            if activePlayer == .firstPlayer {
                secondPlayerActiveConstraint.isActive = false
                firstPlayerActiveConstraint.isActive = true
            } else {
                firstPlayerActiveConstraint.isActive = false
                secondPlayerActiveConstraint.isActive = true
            }
        }
    }
    var dartsThrown: Int = 0
    var selectedTarget: Int = 0 {
        didSet {
            if oldValue != 0 {
                if let button = self.view.viewWithTag(oldValue) as? UIButton {
                    button.setTitleColor(.none, for: .normal)
                }
            }
            if selectedTarget != 0 {
                if let button = self.view.viewWithTag(selectedTarget) as? UIButton {
                    button.setTitleColor(.systemOrange, for: .normal)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstPlayerNameLabel.text = match.firstPlayer.name
        secondPlayerNameLabel.text = match.secondPlayer.name
        
        firstPlayerScoreLabel.text = String(match.firstPlayer.score)
        secondPlayerScoreLabel.text = String(match.secondPlayer.score)
    }
    
    @IBAction func targetButtonTapped(_ sender: UIButton) {
        let previousTarget = selectedTarget
        
        self.selectedTarget = sender.tag
        
        if previousTarget == 0 {
            singleButton.isEnabled = true
            doubleButton.isEnabled = true
        }
        
        trebleButton.isEnabled = sender.tag != 25
    }
    
    @IBAction func endThrowButtonTapped(_ sender: UIButton) {
        endTurn()
    }
    
    @IBAction func multiplierButtonTapped(_ sender: UIButton) {
        let tallies = match.awardTallies(
            player: activePlayer,
            target: selectedTarget,
            multiplier: sender.tag
        )
        
        let labels = activePlayer == .firstPlayer ? firstPlayerTallyLabels : secondPlayerTallyLabels
        labels[translateToIndex(target: selectedTarget)].text = String(tallies)
        
        let scoreLabel = activePlayer == .firstPlayer ? firstPlayerScoreLabel : secondPlayerScoreLabel
        scoreLabel?.text = String(match.scoreOf(player: activePlayer))
        
        dartsThrown += 1
        
        if dartsThrown == 3 {
            endTurn()
        }
    }
    
    func translateToIndex(target: Int) -> Int {
        if target == 25 {
            return 6
        }
        return 20 - target
    }
    
    func endTurn() {
        dartsThrown = 0
        selectedTarget = 0
        
        for button in [singleButton, doubleButton, trebleButton] {
            button?.isEnabled = false
        }
        
        if activePlayer == .firstPlayer {
            activePlayer = .secondPlayer
        } else {
            activePlayer = .firstPlayer
        }
    }
}
