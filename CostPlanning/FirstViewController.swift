//
//  FirstViewController.swift
//  CostPlanning
//
//  Created by Nikita on 19.10.2021.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindSegueToMainScreen(segue: UIStoryboardSegue) {
            
        }

    @IBAction func addInfoButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goMainSegue", sender: nil)
    }
    //update interface
}
