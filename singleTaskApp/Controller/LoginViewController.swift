//
//  LoginViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/08.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var mailAdressText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func login(_ sender: Any) {
        
        if mailAdressText != nil, passwordText != nil{
            Auth.auth().signIn(withEmail: mailAdressText.text!, password: passwordText.text!) { (result, error) in
                
                if error != nil {
                    print(error.debugDescription)
                    return
                }
                
                self.performSegue(withIdentifier: "login", sender: nil)
                
            }
        }
        
    }
    
}
