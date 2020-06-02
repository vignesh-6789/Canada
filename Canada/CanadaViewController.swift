//
//  CanadaViewController.swift
//  Canada
//
//  Created by Vignesh on 15/05/20.
//  Copyright © 2020 Vignesh. All rights reserved.
//

import UIKit
import MBProgressHUD

//Variable Declarations
var myTableView: UITableView!
var activityView = MBProgressHUD()
var navigationItem = UINavigationItem()
let imageCache = NSCache<AnyObject, UIImage>()
var serviceCallRequest = ServiceCall()

class CanadaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Status Bar Hide/Show
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        //Get the status Bar Height
        let statusBarHeight: CGFloat = {
            var heightToReturn: CGFloat = 0.0
            for window in UIApplication.shared.windows {
                if #available(iOS 13.0, *) {
                    if let height = window.windowScene?.statusBarManager?.statusBarFrame.height, height > heightToReturn {
                        heightToReturn = height
                    }
                } else {
                    // Fallback on earlier versions
                    heightToReturn = 44.0
                }
            }
            return heightToReturn
        }()
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height:44))
        navigationBar.backgroundColor = UIColor.white
        let rightButton = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(CanadaViewController.refreshClicked(_:)))
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        navigationItem.rightBarButtonItem = rightButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.topAnchor.constraint(equalTo: view.topAnchor, constant: statusBarHeight).isActive = true
        navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        //Create  Main TableView for the UI
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.rowHeight = UITableView.automaticDimension
        myTableView.estimatedRowHeight = 100
        self.view.addSubview(myTableView)
        myTableView.register(CanadaTableViewCell.self, forCellReuseIdentifier: Constants.CellId)
        
        // Progaramatic Constraints for the tableview
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // Check Internet Availablity before making the service call
        if Reachability.isConnectedToNetwork() {
            self.showIndicator()
            self.requestForData()
        } else {
            let alertController = UIAlertController(title: "", message: Constants.NoInternetAlert, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Method to call the API service call
    func requestForData () {
        serviceCallRequest.fetchContents { (contents, title, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // reload the table on main thread always
                self.navigationItem.title = serviceCallRequest.title as String
                myTableView.reloadData()
                self.hideIndicator()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellId, for: indexPath) as! CanadaTableViewCell
        
        // Set default image because few image are not avaible in the given URL path
        cell.setRowImage(image: UIImage(named:Constants.DefaultImageName)!)
        cell.stopAnimating()
        let currentLastItem = serviceCallRequest.canadaFacts[indexPath.row]
        cell.canadaItem = currentLastItem
        
        // check for the image if not availble fetch the image using image URL through URLSession
        if let cacheImage = imageCache.object(forKey: currentLastItem.factName as AnyObject) {
            cell.setRowImage(image: cacheImage)
        } else {
            if let url:URL = URL(string: currentLastItem.factImage) {
                cell.startAnimating()
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    if let data = try? Data(contentsOf: url){
                        DispatchQueue.main.async(execute: { () -> Void in
                            let img:UIImage! = UIImage(data: data)
                            // Set the downloaded image
                            cell.setRowImage(image: img)
                            imageCache.setObject(img, forKey: currentLastItem.factName as AnyObject)
                            cell.stopAnimating()
                        })
                    } else {
                        // Set default image until get the real image
                        cell.setRowImage(image: UIImage(named:Constants.DefaultImageName)!)
                        cell.stopAnimating()
                    }
                }).resume()
            } else {
                // Set default image until get the real image
                cell.setRowImage(image: UIImage(named:Constants.DefaultImageName)!)
                cell.stopAnimating()
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceCallRequest.canadaFacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Show the Indicator for better user experience while fetching data through service call
    func showIndicator() {
        activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = Constants.IndicatorLableText
        activityView.detailsLabel.text = Constants.IndicatorDetailText
        activityView.show(animated: true)

        self.view.addSubview(activityView)
        self.view.bringSubviewToFront(activityView)
        self.view.isUserInteractionEnabled = false
    }
    
    // Hide the Indicator after finishing the service call  
    func hideIndicator() {
        MBProgressHUD.hide(for: self.view, animated: true)
        self.view.isUserInteractionEnabled = true
    }
    
    // Screen Referesh 
    @objc func refreshClicked(_ sender: UIBarButtonItem) {
        if Reachability.isConnectedToNetwork(){
            self.showIndicator()
            self.requestForData()
        } else {
            let alertController = UIAlertController(title: "", message: "Internet Connection not Available! Try After sometime", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

