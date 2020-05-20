//
//  CanadaViewController.swift
//  Canada
//
//  Created by Vignesh on 15/05/20.
//  Copyright © 2020 Vignesh. All rights reserved.
//

import UIKit
import SystemConfiguration

var myTableView: UITableView!
let cellId = "canadaTableViewCellId"
var canadaFacts : [CanadaItem]  = [CanadaItem]()
var activityView = UIActivityIndicatorView()
var navigationItem = UINavigationItem()
let imageCache = NSCache<AnyObject, UIImage>()

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
}

class CanadaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CanadaTableViewCell
        cell.setProductImage(image: UIImage(named:"FileMissing.png")!)
        cell.stopAnimating()
        let currentLastItem = canadaFacts[indexPath.row]
        cell.canadaItem = currentLastItem
        if let cacheImage = imageCache.object(forKey: currentLastItem.factName as AnyObject) {
            cell.setProductImage(image: cacheImage)
        } else {
            
            if let url:URL = URL(string: currentLastItem.factImage) {
                cell.startAnimating()
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    if let data = try? Data(contentsOf: url){
                        DispatchQueue.main.async(execute: { () -> Void in
                            let img:UIImage! = UIImage(data: data)
                            cell.setProductImage(image: img)
                            imageCache.setObject(img, forKey: currentLastItem.factName as AnyObject)
                            cell.stopAnimating()
                        })
                    } else {
                        cell.setProductImage(image: UIImage(named:"FileMissing.png")!)
                        cell.stopAnimating()
                    }
                }).resume()
            } else {
                cell.setProductImage(image: UIImage(named:"FileMissing.png")!)
                cell.stopAnimating()
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return canadaFacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadingIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView.center = self.view.center
        activityView.startAnimating()
        
        self.view.addSubview(activityView)
        self.view.bringSubviewToFront(activityView)
    }
    
    @objc func refreshClicked(_ sender: UIBarButtonItem) {
        if Reachability.isConnectedToNetwork(){
            self.loadingIndicator()
            self.requestForData()
        } else {
            let alertController = UIAlertController(title: "", message: "Internet Connection not Available! Try After sometime", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height:55))
        navigationBar.backgroundColor = UIColor.white
        let rightButton = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(CanadaViewController.refreshClicked(_:)))
        let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        navigationItem.rightBarButtonItem = rightButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.rowHeight = UITableView.automaticDimension
        myTableView.estimatedRowHeight = 100
        self.view.addSubview(myTableView)
        
        myTableView.register(CanadaTableViewCell.self, forCellReuseIdentifier: cellId)
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 55).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        if Reachability.isConnectedToNetwork() {
            self.loadingIndicator()
            self.requestForData()
        } else {
            let alertController = UIAlertController(title: "", message: "Internet Connection not Available! Try After sometime", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func requestForData () {
        let gitUrl = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json")
        var request = URLRequest(url: gitUrl!)
        
        request.httpMethod = "GET"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response
            , error) in
            
            let backToString = String(data: data!, encoding: .ascii) as String?
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = dir.appendingPathComponent("file.json")
                do {
                    try backToString!.write(to: fileURL, atomically: false, encoding: .utf8)
                } catch {}
                do {
                    let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                    let dict = self.convertToDictionary(text: text2)
                    if let person = dict {
                        
                        if let json = person as [String: Any]?, let results = json["rows"] as? [[String:Any]]  {
                            
                            DispatchQueue.main.async {
                                self.navigationItem.title = json["title"] as? String
                            }
                            if canadaFacts.count > 1 {
                                canadaFacts.removeAll()
                            }
                            for result in results {
                                if let title = result["title"],let title2 = result["description"],let title3 = result["imageHref"]
                                {
                                    if let tit = title as? String, tit.count >= 1 {
                                        canadaFacts.append(CanadaItem(factName: title as? String ?? "", factImage: title3 as? String ?? "" , factDesc: title2 as? String ?? ""))
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            myTableView.reloadData()
                        }
                    }
                } catch {/* error handling here */}
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                activityView.stopAnimating()
            }
        }.resume()
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
