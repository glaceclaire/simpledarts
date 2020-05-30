//
//  CustomViews.swift
//  SimpleDarts
//
//  Created by Tyler on 30/05/2020.
//  Copyright © 2020 Tyler Flottorp. All rights reserved.
//

import UIKit

class StepperWithLabel: UIStepper {
    var associatedLabel: UILabel?
}

class RoundView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.separator.cgColor
        self.layer.borderWidth = 2.0
        
        self.layer.cornerRadius = min(20.0, self.bounds.height / 8.0)
        self.clipsToBounds = true
    }
}

class RoundScrollView: UIScrollView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.separator.cgColor
        self.layer.borderWidth = 2.0
        
        self.layer.cornerRadius = min(20.0, self.bounds.height / 8.0)
        self.clipsToBounds = true
    }
}

class RoundButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.separator.cgColor
        self.layer.borderWidth = 2.0
        
        self.layer.cornerRadius = min(20.0, self.bounds.height / 8.0)
        self.clipsToBounds = true
    }
}

class CircularButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.separator.cgColor
        self.layer.borderWidth = 2.0
        
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.clipsToBounds = true
    }
}

class NumericField: UITextField {
    private var value: Int? = nil
    
    @IBInspectable var hasMaxValue: Bool = false
    @IBInspectable var maxValue: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        isUserInteractionEnabled = false
    }
    
    func getValue() -> Int? {
        return value
    }
    
    func insertDigit(digit: Int) {
        if value == nil {
            value = digit
        } else {
            let newValue = value! * 10 + digit
            if hasMaxValue && newValue > maxValue {
                value = digit
            } else {
                value = newValue
            }
        }
        
        text = String(value!)
    }
    
    func backspace() {
        if value == nil {
            return
        } else if value! < 10 {
            value = nil
            text = nil
        } else {
            value! /= 10
            text = String(value!)
        }
    }
    
    func clear() {
        value = nil
        text = nil
    }
}

class DartView: RoundView {
    private var label: UILabel
    private var field: UITextField
    
    private var multiplier: Int?
    private var base: Int?
    
    override init(frame: CGRect) {
        label = UILabel()
        field = UITextField()
        
        super.init(frame: frame)
        
        addToSubviewAndApplyConstraints()
    }
    
    required init?(coder: NSCoder) {
        label = UILabel()
        field = UITextField()
        
        super.init(coder: coder)
        
        addToSubviewAndApplyConstraints()
    }
    
    private func addToSubviewAndApplyConstraints() {
        label.font = .systemFont(ofSize: 24.0)
        label.textAlignment = .center
        label.backgroundColor = .separator
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.widthAnchor.constraint(equalToConstant: 30.0),
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        field.font = .systemFont(ofSize: 24.0)
        field.textAlignment = .center
        field.isUserInteractionEnabled = false
        
        self.addSubview(field)
        field.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: label.trailingAnchor),
            field.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            field.topAnchor.constraint(equalTo: self.topAnchor),
            field.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func score() -> Dart? {
        if base != nil && multiplier != nil {
            return Dart(base: base!, multiplier: multiplier!)
        }
        
        return nil
    }
    
    func valid() -> Bool {
        return base == nil && multiplier == nil || (base != nil && multiplier != nil)
    }
    
    func getMultiplier() -> Int? {
        return multiplier
    }
    
    func setMultiplier(multiplier: Int) -> Bool {
        if base == nil || (base == 25 && multiplier == 3) {
            return false
        }
        
        self.multiplier = multiplier
        
        label.text = ["S", "D", "T"][multiplier - 1]
        
        return true
    }
    
    func clearMultiplier() {
        multiplier = nil
        label.text = nil
    }
    
    func insertDigit(digit: Int) {
        if base == nil {
            base = digit
        } else {
            let newValue = base! * 10 + digit
            
            // check for overflow
            if newValue > 20 && newValue != 25 {
                base = digit
            } else {
                base = newValue
            }
            
            // there is no triple bull
            if multiplier == 3 && base == 25 {
                clearMultiplier()
            }
        }
        field.text = String(base!)
    }
    
    func backspace() {
        if base == nil {
            return
        }
        
        if base! < 10 {
            base = nil
            field.text = nil
        } else {
            base! /= 10
            field.text = String(base!)
        }
    }
    
    func clearValue() {
        base = nil
        field.text = nil
    }
}

