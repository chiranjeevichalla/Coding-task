    //
    //  ViewController.swift
    //  CodingTask
    //
    //  Created by Chiranjeevi on 17/10/23.
    //

    import UIKit

    protocol MyDataSendingDelegateProtocol {
        func sendDataToFirstViewController(myData: String)
    }

    class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
        @IBOutlet weak var tblVideos: UITableView!
        var apiKey = "AIzaSyAei9PXLfg2Sz5X9G-wRurlQqouQza7KbI"
        var delegate: MyDataSendingDelegateProtocol? = nil
        
        var channelsDataArray: [[String: Any]] = []
        
        var videosArray: [[String: Any]] = []
        
        var selectedVideoIndex: Int!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.title = "Coding task"
            tblVideos.delegate = self
            tblVideos.dataSource = self
            getChannelDetails(useChannelIDParam: false)
        }
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return channelsDataArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell: UITableViewCell!
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath)
        
            let videoDetails = channelsDataArray[indexPath.row]
            cell.textLabel?.text = "Title: \(String(describing: videoDetails["title"] as? String))"
            var dateString  = videoDetails["publishTime"] as! String
            


                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "MMM dd yyyy h:mm a"  //"MMM d, h:mm a" for  Sep 12, 2:11 PM
                let datee = dateFormatterGet.date(from: dateString)
            dateString =  dateFormatterPrint.string(from: datee ?? Date())
            cell.detailTextLabel?.text =  "Date: \(dateString)"
            //let dateFr = date.toDate(.isoDateTime)
            let thumbnail = videoDetails["thumbnail"] as? [String: Any]
            let defaultImage = thumbnail?["default"] as?  [String: Any]
    //        DispatchQueue.main.async {
    //            cell.imageView?.image = UIImage(data: NSData(contentsOf: NSURL(string: defaultImage?["url"] as! String)! as URL)! as Data)
    //        }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedVideoIndex = indexPath.row
            performSegue(withIdentifier: "idSeguePlayer", sender: self)
            
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            if segue.destination is PlayerViewController {
                let vc = segue.destination as? PlayerViewController
                vc?.video = channelsDataArray[selectedVideoIndex]
            }
        }
        
        // MARK: Custom method implementation
        
        func performGetRequest(targetURL: URL!, completion:  @escaping (_ data: [String: Any]?, _ HTTPStatusCode: Int, _ error: Error?) -> ()) {
            var request = URLRequest(url: targetURL)
            request.httpMethod = "GET"
            
            let sessionConfiguration = URLSessionConfiguration.default
            
            let dataTask = URLSession.shared.dataTask(with: request) {
                    data,response,error in

                    guard let data = data else {
                        completion(nil,(response as! HTTPURLResponse).statusCode,NSError.init())
                        return
                    }
                    do {
                        let resultsDict = try JSONSerialization.jsonObject(with: data as Data, options: []) as! [String: Any]
                        DispatchQueue.main.async {
                            completion(resultsDict,(response as! HTTPURLResponse).statusCode,error)
                        }
                    } catch let error {
                        debugPrint(error.localizedDescription)
                    }

                }
                dataTask.resume()
        
        }
        
        
        
        func getChannelDetails(useChannelIDParam: Bool) {
            let targetURL = URL(string: "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&channelId=UC_A--fhX5gea0i4UtpD99Gg&part=snippet,id&order=date&maxResults=20")
            
            
            performGetRequest(targetURL: targetURL, completion: { data, statuscode, error in
                print(statuscode)
                
                if statuscode == 200  {
                    // Get the first dictionary item from the returned items (usually there's just one item).
                    let items = data?["items"] as! [[String: Any]]
                    for item in items {
                        
                        // Get the snippet dictionary that contains the desired data.
                        let snippetDict = item["snippet"] as? [String: Any]
                        let id = item["id"] as? [String: Any]
                        // Create a new dictionary to store only the values we care about.
                        var desiredValuesDict: [String:  Any] = [:]
                        desiredValuesDict["title"] = snippetDict?["title"]
                        desiredValuesDict["description"] = snippetDict?["description"]
                        desiredValuesDict["thumbnail"] = snippetDict?["thumbnails"]
                        desiredValuesDict["publishTime"] = snippetDict?["publishTime"]
                        if let vID  = id {
                            desiredValuesDict["videoId"] = vID["videoId"]
                        }
                        //desiredValuesDict["videoId"] = id?["videoId"]
                        self.channelsDataArray.append(desiredValuesDict)
                    }
                    self.tblVideos.reloadData()
                    
                    
                    
                } else {
                    print("HTTP Status Code = \(statuscode)")
                    //print("Error while loading channel details: \(error)")
                }
                
            })
            
            
        }
        
    }

