//
//  Extensions.swift
//  SimpleDarts
//
//  Created by Tyler on 30/05/2020.
//  Copyright © 2020 Tyler Flottorp. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToBottom(animated:Bool) {
        self.layoutIfNeeded()
        let offset = self.contentSize.height - self.visibleSize.height
        if offset > self.contentOffset.y {
            self.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
        }
    }
}

extension UIStackView {
    func removeAllSubviews() {
        for child in self.subviews {
            child.removeFromSuperview()
        }
    }
    
    func removeAllSubviewsExceptFirst() {
        if self.subviews.count <= 1 {
            return
        }
        
        for i in (1 ... self.subviews.count - 1).reversed() {
            self.arrangedSubviews[i].removeFromSuperview()
        }
    }
}

extension UILabel {
    convenience init(text:String, alignment:NSTextAlignment) {
        self.init()
        
        self.text = text
        self.textAlignment = alignment
    }
}
