//
//  Settings.swift
//  SimpleDarts
//
//  Created by Tyler on 30/05/2020.
//  Copyright © 2020 Tyler Flottorp. All rights reserved.
//

import UIKit

class Settings: UIViewController {
    
    @IBOutlet weak var x01SettingsStack: UIStackView!
    @IBOutlet weak var aroundTheWorldSettingsStack: UIStackView!
    
    @IBOutlet weak var firstPlayerNameField: UITextField!
    @IBOutlet weak var secondPlayerNameField: UITextField!
    
    @IBOutlet weak var legTargetSegmentedControl: UISegmentedControl!
    @IBOutlet weak var doubleInSwitch: UISwitch!
    @IBOutlet weak var doubleOutSwitch: UISwitch!
    @IBOutlet weak var northernBustSwitch: UISwitch!
    @IBOutlet weak var legCountToWinSetLabel: UILabel!
    @IBOutlet weak var legCountToWinSetStepper: StepperWithLabel!
    @IBOutlet weak var setCountToWinMatchLabel: UILabel!
    @IBOutlet weak var setCountToWinMatchStepper: StepperWithLabel!
    
    @IBOutlet weak var countUpSwitch: UISwitch!
    @IBOutlet weak var bullToWinSwitch: UISwitch!
    
    var selectedMode: Mode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mode = selectedMode {
            if mode == .classic {
                legCountToWinSetStepper.associatedLabel = legCountToWinSetLabel
                setCountToWinMatchStepper.associatedLabel = setCountToWinMatchLabel
                
                x01SettingsStack.isHidden = false
            } else if mode == .aroundTheWorld {
                aroundTheWorldSettingsStack.isHidden = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startX01MatchSegue" {
            if let dest = segue.destination as? Classic {
                dest.match = ClassicMatch(
                    firstPlayerName: firstPlayerNameField.text ?? "Player1",
                    secondPlayerName: secondPlayerNameField.text ?? "Player2",
                    targetScore: [301, 501][legTargetSegmentedControl.selectedSegmentIndex],
                    doubleInRequired: doubleInSwitch.isOn,
                    doubleOutRequired: doubleOutSwitch.isOn,
                    northernBustEnabled: northernBustSwitch.isOn,
                    legsPerSet: Int(legCountToWinSetStepper.value),
                    setsToWin: Int(setCountToWinMatchStepper.value)
                )
            }
        } else if segue.identifier == "startAroundTheWorldMatchSegue" {
            if let dest = segue.destination as? AroundTheWorld {
                dest.match = _AroundTheWorldMatch(
                    firstPlayerName: firstPlayerNameField.text ?? "Player1",
                    secondPlayerName: secondPlayerNameField.text ?? "Player2",
                    countUp: countUpSwitch.isOn,
                    bullToWin: bullToWinSwitch.isOn
                )
            }
        } else if segue.identifier == "startCricketMatchSegue" {
            if let dest = segue.destination as? Cricket {
                dest.match = CricketMatch(
                    firstPlayerName: firstPlayerNameField.text ?? "Player1",
                    secondPlayerName: secondPlayerNameField.text ?? "Player2"
                )
            }
        }
    }
    
    @IBAction func startBarButtonTapped(_ sender: UIBarButtonItem) {
        if let mode = selectedMode {
            if mode == .classic {
                self.performSegue(withIdentifier: "startX01MatchSegue", sender: self)
            } else if mode == .aroundTheWorld {
                self.performSegue(withIdentifier: "startAroundTheWorldMatchSegue", sender: self)
            } else if mode == .cricket {
                self.performSegue(withIdentifier: "startCricketMatchSegue", sender: self)
            }
        }
    }
    
    @IBAction func stepperValueChanged(_ sender: StepperWithLabel) {
        sender.associatedLabel?.text = String(Int(sender.value))
    }
}
