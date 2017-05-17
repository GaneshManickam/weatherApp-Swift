//
//  WebService.swift
//  weatherApp
//
//  Created by Ganesh Manickam on 5/13/17.
//  Copyright © 2017 mobileappexpert. All rights reserved.
//

import UIKit

class WebService: NSObject {
    func sendAPIRequest(_ urlpath:NSString,body: NSString , completion: @escaping (_ result: NSMutableDictionary, _ error: AnyObject?)-> Void ) -> Void
    {
        let stringURl = (urlpath as String)
        print(stringURl)
        let url:URL = URL(string: stringURl as String)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodydata = body.data(using: String.Encoding.utf8.rawValue)
        request.httpBody = bodydata
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do
            {
                if data != nil
                {
                    
                    let resultdic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)  as? NSMutableDictionary
                    
                    completion(resultdic!,nil)
                    
                }
                else{
                    print("NO data retrieve from webservice")
                }
            }
            catch
            {
                print("error")
                print(error)
            }
        }
        task.resume()
    }
    func sendAPIRequestGET(_ urlpath:NSString,body: NSString , completion: @escaping (_ result: NSMutableDictionary, _ error: AnyObject?)-> Void ) -> Void
    {
        let stringURl = (urlpath as String) + (body as String)
        print(stringURl)
        let url:URL = URL(string: stringURl as String)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        let bodydata = body.data(using: String.Encoding.utf8.rawValue)
//        request.httpBody = bodydata
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do
            {
                if data != nil
                {
                    let resultdic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSMutableDictionary
                    completion(resultdic!,nil)
                }
                else{
                    print("NO data retrieve from webservice")
                }
            }
            catch
            {
                print("error")
                print(error)
            }
        }
        task.resume()
    }

}
