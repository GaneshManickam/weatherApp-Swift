//
//  weatherVC.swift
//  weatherApp
//
//  Created by Ganesh Manickam on 5/13/17.
//  Copyright © 2017 mobileappexpert. All rights reserved.
//

import UIKit
import SDWebImage

class weatherVC: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var theTableView: UITableView!
    var cityName = UserDefaults.standard.value(forKey: "cityName") as! String
    var reportArray = NSMutableArray()
    var dateArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
         self.title = "\(cityName)"
         self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: date)

        self.dateArray.add("\(strDate)")
        self.dateArray.add("\(strDate)")

        for i in 1...5
        {
            var interval = TimeInterval(60 * 60 * 24 * i)
            var newDate = date.addingTimeInterval(interval)
             let newDateStr = dateFormatter.string(from: newDate)
            self.dateArray.add("\(newDateStr)")
            self.dateArray.add("\(newDateStr)")
        }
        
        self.theTableView.estimatedRowHeight = 300
        self.theTableView.rowHeight = UITableViewAutomaticDimension
        
        if Reachability.isConnectedToNetwork() == true {
            if cityName == ""
            {
                let alert = UIAlertController(title: "Alert", message: "Selected City name blank", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

            }
            else{
                let Url = "http://api.wunderground.com/api/cfb2bdd59e92d5ac/forecast10day/q/CA/"
                let strArr = cityName.components(separatedBy: ",")
                let body = "\(strArr[0]).json"
                WebService().sendAPIRequestGET(Url as NSString, body: body as NSString) { (result, error) -> Void in
                    print(result)
                    if result.object(forKey: "forecast") as? NSMutableDictionary != nil
                    {
                        let forecast = result.object(forKey: "forecast") as! NSMutableDictionary
                        if forecast.object(forKey: "txt_forecast") as? NSMutableDictionary != nil
                        {
                            let txt_forecast = forecast.object(forKey: "txt_forecast") as! NSMutableDictionary
                            if txt_forecast.object(forKey: "forecastday") as? NSMutableArray != nil
                            {
                                self.reportArray = txt_forecast.object(forKey: "forecastday") as! NSMutableArray
                                DispatchQueue.main.async {
                                    self.theTableView.reloadData()
                                }
                            }
                            else{
                                self.forecastNotAvailable()
                            }
                        }
                        else
                        {
                            self.forecastNotAvailable()
                        }
                    }
                    else{
                        self.forecastNotAvailable()
                    }
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "Please Check your Internet Connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func forecastNotAvailable()
    {
        let alert = UIAlertController(title: "Alert", message: "Report not available for \(cityName)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
     return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if reportArray.count > 12
        {
            return 12
        }
        else{
            return reportArray.count
        }
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
     {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! weatherCell
        
        cell.dateLbl.text =  self.dateArray[indexPath.row] as! String
        cell.dayLbl.text =  (self.reportArray[indexPath.row] as AnyObject).value(forKey: "title") as! String
        cell.reportLbl.text = (self.reportArray[indexPath.row] as AnyObject).value(forKey: "fcttext_metric") as! String
        if (self.reportArray[indexPath.row] as AnyObject).value(forKey: "icon_url") as! String != ""
        {
            let imgURL = "\((self.reportArray[indexPath.row] as AnyObject).value(forKey: "icon_url") as! String)"
            
            print(imgURL)
            let imageUrll = URL(string: imgURL)
            cell.theImgview.sd_setImage(with: imageUrll) { (image, error, imageCacheType, imageUrl) in
                if (image != nil) {
                    cell.theImgview.image = image
                }
                else
                {
                    cell.theImgview.image = UIImage(named: "weatherIcon.png")
                }
            }
        }
        else
        {
            cell.theImgview.image = UIImage(named: "weatherIcon.png")
        }
        

        return cell
     }
    
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
