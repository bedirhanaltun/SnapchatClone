//
//  ViewController.swift
//  SnapchatClone
//
//  Created by Bedirhan Altun on 16.09.2022.
//

import UIKit
import Firebase

class LoginScreen: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        
        if userNameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" {
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { data, error in
                if error != nil{
                    self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }
                else{
                    
                    let fireStore = Firestore.firestore()
                    let userDictionary = ["email": self.emailTextField.text!, "username": self.userNameTextField.text!] as [String : Any]
                    
                    fireStore.collection("UserInfo").addDocument(data: userDictionary) { error in
                        if error != nil{
                            self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                        }
                        else{
                            
                        }
                    }
                    
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }
        else{
            showAlert(title: "Error", message: "Username or email or password is empty. Please login again...")
        }
        
    }
    @IBAction func signInButtonClicked(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { result, error in
                if error != nil {
                    self.showAlert(title: "Error", message: error?.localizedDescription ?? "")
                }
                else{
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }
        else{
            showAlert(title: "Error", message: "???")
        }
        
        
    }
    
    
}

extension UIViewController {
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}

