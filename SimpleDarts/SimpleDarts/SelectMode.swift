//
//  SelectMode.swift
//  SimpleDarts
//
//  Created by Tyler on 30/05/2020.
//  Copyright © 2020 Tyler Flottorp. All rights reserved.
//

import UIKit

class SelectMode: UIViewController {

    var selectedTag: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if selectedTag != nil, let dest = segue.destination as? Settings {
            switch selectedTag {
            case 0:
                dest.selectedMode = .classic
                break
            case 1:
                dest.selectedMode = .aroundTheWorld
                break
            case 2:
                dest.selectedMode = .cricket
                break
            default:
                print("error, no mode selected")
            }
        }
    }
    
    @IBAction func modeButtonTapped(_ sender: RoundButton) {
        selectedTag = sender.tag
        self.performSegue(withIdentifier: "showSettingsSegue", sender: self)
    }
    
}
