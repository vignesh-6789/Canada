//
//  ServiceCall.swift
//  Canada
//
//  Created by Vignesh on 27/05/20.
//  Copyright © 2020 Vignesh. All rights reserved.
//

import Foundation

class ServiceCall: NSObject {
    
    // Array of facts
    var canadaFacts : [CanadaItem]  = [CanadaItem]()
    
    // Screen Title
    var title:NSString = ""
    
    // Retrive the Data through Service Call
    func fetchContents (completion: @escaping(_ contents: [CanadaItem], _ title: NSString, _ error: NSError?) -> Void) {
        
        // Dropbox URL
        let gitUrl = URL(string: Constants.RequestUrl)
        var request = URLRequest(url: gitUrl!)
        
        request.httpMethod = "GET"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        // Trigger the Service Call
        URLSession.shared.dataTask(with: request) { (data, response
            , error) in
            
            if let backToString = String(data: data!, encoding: .ascii) as String? {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let fileURL = dir.appendingPathComponent("file.json") // Saved file path
                    do {
                        try backToString.write(to: fileURL, atomically: false, encoding: .utf8)
                    } catch {}
                    do {
                        let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                        
                        // Convert the String into Dictionary
                        let dict = self.convertToDictionary(text: text2)
                        if let person = dict {
                            
                            if let json = person as [String: Any]?, let results = json["rows"] as? [[String:Any]]  {
                                
                                // UI Updates on main thread always
                                DispatchQueue.main.async {
                                    self.title = json["title"] as! NSString
                                }
                                
                                // Clean The Array before set values else this make issue while refreshing screen
                                if self.canadaFacts.count > 1 {
                                    self.canadaFacts.removeAll()
                                }
                                for result in results {
                                    if let title = result["title"],let title2 = result["description"],let title3 = result["imageHref"]
                                    {
                                        if let tit = title as? String, tit.count >= 1 {
                                            // Add the values to the arraay
                                            self.canadaFacts.append(CanadaItem(factName: title as? String ?? "", factImage: title3 as? String ?? "" , factDesc: title2 as? String ?? ""))
                                        }
                                    }
                                }
                                completion(self.canadaFacts, self.title, error as NSError?)
                            } else {
                                completion(self.canadaFacts, self.title, nil)
                            }
                        } else {
                            completion(self.canadaFacts, self.title, nil)
                        }
                    } catch {/* error handling here */
                        completion(self.canadaFacts, self.title, error as NSError?)
                    }
                }
            } else {
                completion(self.canadaFacts, self.title, nil)
            }
        }.resume()
    }
    
    // Convert the String into Dictionary
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
