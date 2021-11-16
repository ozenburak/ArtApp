//
//  ViewController.swift
//  ArtBookProject2
//
//  Created by burak ozen on 2.08.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selectedPaintId :UUID?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
//        TableView içerisinde üst tarafa add butonunu eklemye yarar
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        
        getData()
    }
    
//     DetailsVC içerisinde çağırılan notifications func da bunu viewwillappear içinde kontrol etmem gerek ki her uygulamamı açtığımda çağırılacak bir func olur. burda "newData" mesajı cagırılınca direk getdata uygulamasını çalıştırıcak.
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func getData() {
//        burada bunu yaparak duplike verileri yani TableV de tekar eden bilgilei engellemek amacıyla yapıyoruz.
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context  = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
//        bunu false yaparak coredatada arkada okuma işlemi yapılırken cache den okuma işlemi daha rahat yapılıyo daha hızlı okunuyo yani. cok buyuk dataların buludngu yelerde kullanmakta fayda var
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                        
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
    //                burada yeni bir veri geldi kendini guncelle diyorum tableview içerisinde
                    self.tableView.reloadData()
                    
                    
                }
                
            }
            
        } catch{
            print("error")
        }
       
        
        
    }
    
    
    
    
    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")

            
            let idString = idArray[indexPath.row].uuidString
            // predicate kullanmamızdaki neden sadece tek bir seyi silmek istemek istediğimizden dolayı
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
//                            ikinci kez burda id idArray içerisinde kesin var mı diye kosulu sorguluyoruz çünkü silme işlemi olacak geri dönüşü olmayan bi şey oldugu için garantilemek için tekrardan kontrol ediyoruz.
                            if id == idArray[indexPath.row] {
//                                coreDatadan siliyoruz burada
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
//                                reloadData yapmamzdaki neden silinecek satırlar var onlar silindikten sonra bi kendini yenile anlamında
                                self.tableView.reloadData()
//                                bununla da yapılan işlemden sonra son halini save et anlamında
                                
                                do {
                                    try context.save()
                                } catch  {
                                    print("error")
                                }
                                
//                                burada break dememizdeki amaç istenşlen şartlar for loop içerisinde sağlandıktan sonra bu foor loopu bitir. anlamında kullanılmaktadır.
                                break
                                
                                
                            }
                        }
                        
                    }
                }
            } catch{
                print("error")
            }
            
            
        }
    }


}

