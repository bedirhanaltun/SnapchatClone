//
//  FeedVC.swift
//  SnapchatClone
//
//  Created by Bedirhan Altun on 16.09.2022.
//

import UIKit
import Firebase
import SDWebImage

class FeedVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let fireStoreDatabase = Firestore.firestore()
    var snapArray = [Snap]()
    var chosenSnap : Snap?
    var timeLeft : Int?

    @IBOutlet weak var feedTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        getUserInfo()
        getSnapsFromFirebase()
        
    }
    
    func getSnapsFromFirebase(){
        
        fireStoreDatabase.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            if error != nil{
                self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }
            else{
                if snapshot?.isEmpty == false && snapshot != nil{
                    
                    self.snapArray.removeAll()
                    for document in snapshot!.documents{
                        
                        let documentId = document.documentID
                        
                        if let username = document.get("snapOwner") as? String{
                            if let imageUrlArray = document.get("imageUrlArray") as? [String]{
                                if let date = document.get("date") as? Timestamp{
                                    
                                    if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour{
                                        if difference >= 24{
                                            //Delete
                                            self.fireStoreDatabase.collection("Snaps").document(documentId).delete { error in
                                                if error != nil{
                                                    self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                                }
                                            }
                                        }
                                        
                                        //Time Left
                                        self.timeLeft = 24 - difference
                                        
                                    }
                                    
                                    let snap = Snap(username: username, imageUrlArray: imageUrlArray, date: date.dateValue())
                                    self.snapArray.append(snap)
                                }
                            }
                        }
                        
                    }
                    self.feedTableView.reloadData()
                }
            }
        }
    }
        
    func getUserInfo(){
        
        fireStoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { snapshot, error in
            if error != nil {
                self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }
            else{
                if snapshot?.isEmpty == false && snapshot != nil{
                    for document in snapshot!.documents{
                        if let username = document.get("username") as? String{
                            UserSingleton.sharedInstance.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedInstance.username = username
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! FeedCell
        cell.userNameLabel.text = snapArray[indexPath.row].username
        cell.feedImageView.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC"{
            let destinationVC = segue.destination as? SnapVC
            destinationVC?.selectedSnap = chosenSnap
            destinationVC?.selectedTime = timeLeft
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenSnap = snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }

}
