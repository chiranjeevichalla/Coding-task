    //
    //  PlayerViewController.swift
    //  CodingTask
    //
    //  Created by Chiranjeevi on 17/10/23.
    //

    import UIKit
    import youtube_ios_player_helper

    class PlayerViewController: UIViewController, YTPlayerViewDelegate {
        
        var video: [String: Any]!
        
        @IBOutlet weak var playerView: YTPlayerView!
        
        @IBOutlet weak var titleLbel: UILabel!
        
        @IBOutlet weak var descriptionLabel: UILabel!
        
        @IBOutlet weak var descritionLbl: UILabel!
        @IBOutlet weak var dateLabel: UILabel!
        override func viewDidLoad() {
            super.viewDidLoad()
        
            self.loadContent()
                
        }
        
        func loadContent() {
            playerView.load(withVideoId: video["videoId"] as! String, playerVars: ["playsinline": "1"])
            titleLbel.text = video["title"] as? String
            descritionLbl.text = video["description"] as? String
            var dateString  = video["publishTime"] as! String
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd yyyy h:mm a"  //"MMM d, h:mm a" for  Sep 12, 2:11 PM
            let datee = dateFormatterGet.date(from: dateString)
            dateString =  dateFormatterPrint.string(from: datee ?? Date())
            dateLabel.text = "Date: \(dateString)"
            
        }
        
        func sendDataToFirstViewController(myData: String) {
            
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

    }


    extension PlayerViewController {
        func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
            return UIColor.black
        }
        
    }
