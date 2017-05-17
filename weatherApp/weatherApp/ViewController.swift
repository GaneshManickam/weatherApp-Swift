//
//  ViewController.swift
//  weatherApp
//
//  Created by Ganesh Manickam on 5/13/17.
//  Copyright © 2017 mobileappexpert. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var theSuggestionTableView: UITableView!
    @IBOutlet var theSearchBar: UISearchBar!
    @IBOutlet var theSuggestionView: UIView!
    @IBOutlet var cityTableView: UITableView!
    var suggestionArray = NSMutableArray()
    var cityArray = NSMutableArray()
    var mySearchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.theSuggestionView.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height-64)
        self.view.addSubview(self.theSuggestionView)
        self.theSuggestionView.isHidden =  true
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        fetchCoreDateValue()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func fetchCoreDateValue()
    {
        print("Core Fetch Calling...")
        //Fetch the value from Core Data
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let managedcontext = appdelegate.managedObjectContext
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Cities", in: managedcontext)
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        do {
            let result = try managedcontext.fetch(fetchRequest)
            if (result.count > 0) {
                self.cityArray = NSMutableArray()
                let dataItems = result as! [NSManagedObject]
                for i in 0  ..< dataItems.count
                {
                    var sampDict = NSMutableDictionary()
                    sampDict.setValue((dataItems[i] as AnyObject).value(forKey: "id") as! String, forKey: "id")
                    sampDict.setValue((dataItems[i] as AnyObject).value(forKey: "name") as! String, forKey: "name")
                self.cityArray.add(sampDict)
                }
                DispatchQueue.main.async {
                self.cityTableView.reloadData()
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
      return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == cityTableView
        {
            return cityArray.count
        }
        else
        {
            return suggestionArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       if tableView == cityTableView
       {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! cityCell
        cell.cityNameLbl.text = (self.cityArray[indexPath.row] as AnyObject).value(forKey: "name") as! String
        return cell
        
       }
       else
       {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popCell") as! suggestionCell
        cell.suggestionLbl.text = (self.suggestionArray[indexPath.row] as AnyObject).value(forKey: "name") as! String
        return cell
       }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == cityTableView
        {
            UserDefaults.standard.set("\((self.cityArray[indexPath.row] as AnyObject).value(forKey: "name") as! String)", forKey: "cityName")
            self.performSegue(withIdentifier: "nextVC", sender: self)
        }
        else
        {
           self.theSearchBar.resignFirstResponder()
            self.addButton.tintColor = UIColor.white
            self.addButton.isEnabled = true
            //Store the City into Core Data
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let strDate = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "HH:mm:ss"
            let time = dateFormatter.string(from: date)
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let managedcontext = appdelegate.managedObjectContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Cities", in: managedcontext)
            
            let item = NSManagedObject(entity: entity!, insertInto: managedcontext)
            item.setValue("\(strDate)\(time)", forKey: "id")
            item.setValue("\((self.suggestionArray[indexPath.row] as AnyObject).value(forKey: "name") as! String)", forKey: "name")
            do{
                try managedcontext.save()
                fetchCoreDateValue()
             }
             catch
             {
                print("error")
             }
          self.theSuggestionView.isHidden =  true
            
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // to limit network activity, reload half a second after last key press.
        print(searchText)
        mySearchText = searchText
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.serachBarreload), object: nil)
        self.perform(#selector(ViewController.serachBarreload), with: nil, afterDelay: 0.3)
    }
    func serachBarreload()
    {
        if Reachability.isConnectedToNetwork() == true {
            if mySearchText == ""
            {
                if self.suggestionArray.count > 0
                {
                    self.suggestionArray.removeAllObjects()
                    self.theSuggestionTableView.reloadData()
                }
                else{
                    self.theSuggestionTableView.reloadData()
                }
            }
            else{
                let Url = "http://autocomplete.wunderground.com/aq?query="
                
                let body = "\(mySearchText)"
                WebService().sendAPIRequestGET(Url as NSString, body: body as NSString) { (result, error) -> Void in
                    if result.object(forKey: "RESULTS") as? NSMutableArray != nil
                    {
                      self.suggestionArray = result.object(forKey: "RESULTS") as! NSMutableArray
                        DispatchQueue.main.async {
                             self.theSuggestionTableView.reloadData()
                        }
                    }
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "Please Check your Internet Connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.theSuggestionView.isHidden =  false
            self.addButton.tintColor = UIColor.clear
            self.addButton.isEnabled = false
        }
    }
    @IBAction func cancelClicked(_ sender: Any) {
         DispatchQueue.main.async {
        self.theSearchBar.resignFirstResponder()
        self.theSuggestionView.isHidden =  true
        self.addButton.tintColor = UIColor.white
        self.addButton.isEnabled = true

        }
    }

}

