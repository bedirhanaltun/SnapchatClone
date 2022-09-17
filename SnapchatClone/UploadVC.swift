//
//  UploadVC.swift
//  SnapchatClone
//
//  Created by Bedirhan Altun on 16.09.2022.
//

import UIKit
import Firebase

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        uploadImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func pickImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageView.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil{
                    self.showAlert(title: "Error", message: error?.localizedDescription ?? "")
                }
                else{
                    imageReference.downloadURL { url, error in
                        if error != nil{
                            self.showAlert(title: "Error", message: error?.localizedDescription ?? "")
                        }
                        else{
                            let imageUrl = url?.absoluteString
                            
                            
                            let firestore = Firestore.firestore()
                            firestore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedInstance.username).getDocuments { snapshot, error in
                                if error != nil{
                                    self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                }
                                else{
                                    if snapshot?.isEmpty == false && snapshot != nil{
                                        for document in snapshot!.documents{
                                            let documentId = document.documentID
                                            
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String]{
                                                imageUrlArray.append(imageUrl!)
                                                
                                                let imageAddDictionary = ["imageUrlArray": imageUrlArray] as [String: Any]
                                                
                                                firestore.collection("Snaps").document(documentId).setData(imageAddDictionary, merge: true) { error in
                                                    if error != nil{
                                                        self.showAlert(title: "Error", message: error?.localizedDescription ?? "")
                                                    }
                                                    else{
                                                        self.tabBarController?.selectedIndex = 0
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        let snapDictionary = ["imageUrlArray" : [imageUrl!], "snapOwner" : UserSingleton.sharedInstance.username, "date": FieldValue.serverTimestamp()] as [String: Any]
                                        
                                        firestore.collection("Snaps").addDocument(data: snapDictionary) { error in
                                            if error != nil{
                                                self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                            }
                                            else{
                                                self.tabBarController?.selectedIndex = 0
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                            
                            
                        }
                    }
                }
            }
        }
        
    }
}
