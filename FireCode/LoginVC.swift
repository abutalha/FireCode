//
//  LoginVC.swift
//  FireCode
//
//  Created by AbuTalha on 08/12/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    
    let dbStore = Firestore.firestore()
    
    // MARK: Actions
    @IBAction func signUp(_ sender: UIButton) {
        
        // Create new User
        Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { result, error in
            
            // Check the result and let them in
            if (error == nil) {
                print (result?.user.email ?? "no email")
            } else {
                print (error?.localizedDescription ?? "")
            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        try! Auth.auth().signOut()
        
        // Login with Email and Pass
        Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { result, error in
            
            let data = ["uid": result!.user.uid,
                        "admin": false] as [String : Any]
            
            self.dbStore.collection("users").document(result!.user.uid).setData(data)
            
            self.checkRole()
//            result?.user.getIDTokenResult(completion: { authToken, err in
//                for (claim, value) in authToken!.claims.enumerated() {
//                    print (claim, value)
//                }
//            })
                

            
            // if there is no error, then let him go in
            if (error == nil) {
                print (result?.user.email ?? "")
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func checkRole() {
        
         dbStore.collection("users").document(Auth.auth().currentUser!.uid).getDocument(completion: { document, err in

//            let x = document?.get("uid") as! String
            let y = document?.get("admin") as! Bool
            print (y)
        })
            
        
        
    }

}
