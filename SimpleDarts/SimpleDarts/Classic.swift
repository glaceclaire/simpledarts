//
//  Classic.swift
//  SimpleDarts
//
//  Created by Tyler on 19/04/2020.
//  Copyright © 2020 Tyler. All rights reserved.
//

import UIKit

class Classic: UIViewController {
    @IBOutlet weak var restartBarButton: UIBarButtonItem!
    
    @IBOutlet weak var firstPlayerActiveConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondPlayerActiveConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstPlayerNameLabel: UILabel!
    @IBOutlet weak var secondPlayerNameLabel: UILabel!
    @IBOutlet weak var firstPlayerScoreLabel: UILabel!
    @IBOutlet weak var secondPlayerScoreLabel: UILabel!
    @IBOutlet weak var firstPlayerHistoryScroll: UIScrollView!
    @IBOutlet weak var secondPlayerHistoryScroll: UIScrollView!
    @IBOutlet weak var firstPlayerHistoryStack: UIStackView!
    @IBOutlet weak var secondPlayerHistoryStack: UIStackView!
    @IBOutlet weak var firstPlayerInitialTargetLabel: UILabel!
    @IBOutlet weak var secondPlayerInitialTargetLabel: UILabel!
    
    @IBOutlet weak var inputMethodSegment: UISegmentedControl!
    
    @IBOutlet weak var totalInputField: NumericField!
    @IBOutlet weak var individualInputStack: UIStackView!
    
    @IBOutlet weak var firstDartView: DartView!
    @IBOutlet weak var secondDartView: DartView!
    @IBOutlet weak var thirdDartView: DartView!
    private lazy var dartViews: [DartView] = [firstDartView, secondDartView, thirdDartView]
    
    @IBOutlet weak var multiplierButtonsStack: UIStackView!
    @IBOutlet var multiplierButtons: [UIButton]!
    
    @IBOutlet var inputButtons: [UIButton]!
    
    var match: ClassicMatch!
    
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
    
    var inputMethod:InputMethod = .total {
        didSet {
            if inputMethod == .total {
                individualInputStack.isHidden = true
                if match.matchState() == .contested {
                    setButtonsEnabled(group: multiplierButtons, enabled: false)
                }
                totalInputField.isHidden = false
            } else {
                totalInputField.isHidden = true
                individualInputStack.isHidden = false
                if match.matchState() == .contested {
                    setButtonsEnabled(group: multiplierButtons, enabled: true)
                }
                selectedField = 0
            }
        }
    }
    
    var selectedField:Int = 0 {
        didSet {
            dartViews[oldValue].layer.borderColor = UIColor.separator.cgColor
            dartViews[selectedField].layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstPlayerNameLabel.text = match.nameOf(player: .firstPlayer)
        secondPlayerNameLabel.text = match.nameOf(player: .secondPlayer)
        
        for stack in [firstPlayerHistoryStack, secondPlayerHistoryStack] {
            stack?.layoutMargins = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            stack?.isLayoutMarginsRelativeArrangement = true
        }
        
        firstPlayerInitialTargetLabel.text = String(match.scoreOf(player: .firstPlayer))
        secondPlayerInitialTargetLabel.text = String(match.scoreOf(player: .secondPlayer))
        
        inputMethodSegment.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "inputMethod")
        scoringInputMethodChanged(self.inputMethodSegment)
        
        updateLegsAndSets()
    }
    
    @IBAction func restartBarButtonPressed(_ sender: UIBarButtonItem) {
        restartBarButton.title = "Restart"
        
        match.restart()
        
        activePlayer = .firstPlayer
        
        prepareInterface()
        
        clearInputFields()
        
        if inputMethod == .individualDarts {
            setButtonsEnabled(group: multiplierButtons, enabled: true)
        }
        
        setButtonsEnabled(group: inputButtons, enabled: true)
    }
    
    @IBAction func scoringInputMethodChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "inputMethod")
        
        if sender.selectedSegmentIndex == 0 {
            inputMethod = .individualDarts
        } else {
            inputMethod = .total
        }
        
        clearInputFields()
    }
    
    @IBAction func dartInputFieldTapped(_ sender: UITapGestureRecognizer) {
        if match.matchState() == .contested {
            selectedField = sender.view?.tag ?? 0
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: RoundButton) {
        if inputMethod == .total {
            if totalInputField.getValue() != nil {
                evaluateTotalThrow()
            }
        } else {
            evaluateIndividualThrow()
        }
    }

    @IBAction func multiplierButtonPressed(_ sender: RoundButton) {
        if dartViews[selectedField].setMultiplier(multiplier: sender.tag) && selectedField < 2 {
            selectedField += 1
        }
    }
    
    @IBAction func valueButtonPressed(_ sender: RoundButton) {
        if inputMethod == .individualDarts {
            dartViews[selectedField].insertDigit(digit: sender.tag)
        } else {
            totalInputField.insertDigit(digit: sender.tag)
        }
    }
    
    @IBAction func endThrowButtonTapped(_ sender: RoundButton) {
        createScoreEntryForActivePlayer(totalThrow: 0, throwResult: .normal)
        changeActivePlayer()
        clearInputFields()
    }
    
    @IBAction func backspaceButtonTapped(_ sender: RoundButton) {
        if inputMethod == .individualDarts {
            dartViews[selectedField].backspace()
        } else {
            totalInputField.backspace()
        }
    }
    
    func prepareInterface() {
        updateLegsAndSets()
        
        firstPlayerHistoryStack.removeAllSubviewsExceptFirst()
        secondPlayerHistoryStack.removeAllSubviewsExceptFirst()
    }
    
    func updateLegsAndSets() {
        firstPlayerScoreLabel.text = match.recordStringOf(player: .firstPlayer)
        secondPlayerScoreLabel.text = match.recordStringOf(player: .secondPlayer)
    }
    
    func evaluateTotalThrow() {
        if let total = totalInputField.getValue() {
            let result = match.scoreThrow(player: activePlayer, throwTotal: total)
            createScoreEntryForActivePlayer(totalThrow: total, throwResult: result)
            
            clearInputFields()
        
            if result == .checkOut {
                currentPlayerWonLeg()
            } else {
                changeActivePlayer()
            }
        }
    }
    
    func evaluateIndividualThrow() {
        var scoringDarts: [Dart] = [Dart]()
        var total: Int = 0
        
        for view in dartViews {
            if !view.valid() {
                //self.performSegue(withIdentifier: "multiplierTooltipSegue", sender: view)
                return
            }
            
            if let dart = view.score() {
                scoringDarts.append(dart)
                total += dart.multiplier * dart.base
            }
        }
        
        let result = match.scoreDarts(player: activePlayer, darts: scoringDarts)
        createScoreEntryForActivePlayer(totalThrow: total, throwResult: result)
            
        clearInputFields()
    
        if result == .checkOut {
            currentPlayerWonLeg()
        } else {
            changeActivePlayer()
        }
    }
    
    func createScoreEntryForActivePlayer(totalThrow: Int, throwResult: ThrowResult) {
        let throwEntryLabel = UILabel(
            text: "\(match.scoreOf(player: activePlayer)) (\(totalThrow))",
            alignment: .center
        )
        
        if throwResult == .checkOut {
            throwEntryLabel.textColor = .systemGreen
        } else if throwResult == .bust {
            throwEntryLabel.textColor = .systemRed
        }
        
        if activePlayer == .firstPlayer {
            firstPlayerHistoryStack.addArrangedSubview(throwEntryLabel)
            firstPlayerHistoryScroll.layoutIfNeeded()
            firstPlayerHistoryScroll.scrollToBottom(animated: true)
        } else {
            secondPlayerHistoryStack.addArrangedSubview(throwEntryLabel)
            secondPlayerHistoryScroll.layoutIfNeeded()
            secondPlayerHistoryScroll.scrollToBottom(animated: true)
        }
    }
    
    func changeActivePlayer() {
        if activePlayer == .firstPlayer {
            activePlayer = .secondPlayer
        } else {
            activePlayer = .firstPlayer
        }
    }
    
    func currentPlayerWonLeg() {
        let result = match.awardLeg(player: activePlayer)
        let alert = UIAlertController(
            title: nil,
            message: "\(result.rawValue) won by \(match.nameOf(player: activePlayer))",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "OK",
                style: .default
            )
        )
        
        self.present(alert, animated: true, completion: self.beginNextLeg)
    }
    
    func beginNextLeg() {
        if match.matchState() != .contested {
             updateLegsAndSets()
             
             restartBarButton.title = "Rematch"
             
             setButtonsEnabled(group: multiplierButtons + inputButtons, enabled: false)
             
             return
         }
         
         activePlayer = match.firstDart()
         
         prepareInterface()
    }
        
    func clearInputFields() {
        if inputMethod == .individualDarts {
            for field in dartViews {
                field.clearMultiplier()
                field.clearValue()
            }
            
            selectedField = 0
        } else {
            totalInputField.clear()
        }
    }
    
    func setButtonsEnabled(group: [UIButton], enabled: Bool) {
        for button in group {
            button.isEnabled = enabled
        }
    }
}
