//
//  ViewController.swift
//  CostPlanning
//
//  Created by Nikita on 18.10.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindSegueToMainScreen(segue: UIStoryboardSegue) {
            
        }

    @IBAction func addInfoButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goMainSegue", sender: nil)
    }
}

