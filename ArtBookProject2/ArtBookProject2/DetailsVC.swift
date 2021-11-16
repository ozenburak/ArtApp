//
//  DetailsVC.swift
//  ArtBookProject2
//
//  Created by burak ozen on 3.08.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
//            bu ozellik tableView üzerinde herhangi bir yeri seçince save buttonunu gizliyo.
            saveButton.isHidden = true
            
//            coreData dan çekilecek veriler burada olacak
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            
            fetchRequest.returnsObjectsAsFaults = false
            
//            predicate olayı ben bi koşul giricem ve bu koşulu sağlayıp bana getirecek butun kayıtları çkemeyip sadece isteneni yazıp getiriyo
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do {
                let results  = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
//                        burada image ı data olarak tanıttıgımız için tanımlama yaparken uiimage ı data olarak seçiyoruz.
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                }
            } catch{
                print("error")
            }
            
            
            
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            
        }

        
        
//        RECOGNAİZER
// kalvyeyi gizleme
        let gestureRecognaizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognaizer)
        
//        kullanıcı  select image görseline tıklayabiliyo mu
        imageView.isUserInteractionEnabled = true
        
        let imageTapRecognaizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognaizer)
        
        
    }
    
    @objc func selectImage(){
//        seçilen golumden galeriye gidebilmek için " picker " diye bi olayı kullanıyoruz.
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
//        burada kullanıcı seçtiği fotoda editing yapabilme yetkisi sveriyoruz.
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
//    resimi seçtikten sonra olacakları da yazmamız lazım burada o yazıyo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }

    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
//        Attributes
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
        newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
//        bu gorseli alıp bir dataya cevirecek
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch  {
            print("error")
        }
//        bu sınıf bana diğer VClara mesaj yolaamama yardımcı oluyo
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
//        geri tarafa bir once VC a nasıl gidilir. bir onceki ekrana gidilir.
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    
    
    
    

}
