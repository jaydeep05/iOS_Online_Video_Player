//
//  ViewController.swift
//  video player
//
//  Created by Jaydeep on 18/10/1941 Saka.
//  Copyright © 1941 Jaydeep. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
   
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var Customurl: UILabel!
    @IBOutlet weak var urltext: UITextField!
    @IBOutlet weak var segmentValue: UISegmentedControl!

    
    
    @IBAction func play(_ sender: AnyObject) {
        if urltext.text?.isEmpty == false{
            player(url: urltext.text!)
        }
    }
   
    
    func player(url: String){
        guard let url = URL(string: url) else {
             return
        }
        let video = AVPlayer(url: url)
        let videoplayer = AVPlayerViewController()
        videoplayer.player = video
        
        present(videoplayer, animated: true){
            video.play()
        }
    }
    @IBAction func clear(_ sender: Any) {
        urltext.text = nil
    }
    @IBAction func segmentAction(_ sender: Any) {
        switch segmentValue.selectedSegmentIndex
        {
        case 0:
            view1.isHidden = false
            view2.isHidden = true
            view3.isHidden = true
        case 1:
            view1.isHidden = true
            view2.isHidden = false
            view3.isHidden = true
        case 2:
            view1.isHidden = true
            view2.isHidden = true
            view3.isHidden = false
        default:
            break
        }
        
    }
    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: NSURL, indexPath: IndexPath) {
        // 1 save file at track index(get from original download URL) and do your other app changes
        //... save
        dispatch_async(dispatch_get_main_queue(), {
        // 2 Reload row of trackIndex
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        })
    }
    @IBOutlet weak var tableview: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hero.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell ( style: .default, reuseIdentifier: nil )
        
        cell.textLabel?.text = hero[indexPath.row].url
        return cell
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var urlSession:URLSession!;
        var urlConfiguration:URLSessionConfiguration!;
        var downloadTask:URLSessionDownloadTask!;
        var _:NSData!;
        let domain = "https://www.cinemaworldtheaters.com/trailers/"
        let nm = hero[indexPath.row].url
        print(nm)
        let urls = domain + nm
        print(urls)
        urlConfiguration = URLSessionConfiguration.default;
        let queue:OperationQueue = OperationQueue.main;
        urlSession = URLSession.init(configuration: urlConfiguration, delegate: (self as! URLSessionDelegate), delegateQueue: queue);
        let url:NSURL = NSURL(string: urls)!;
        downloadTask = urlSession.downloadTask(with: url as URL);
        downloadTask.resume();
    }
    
//    @IBOutlet weak var check: UILabel!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let domain = "https://www.cinemaworldtheaters.com/trailers/"
        let nm = hero[tableView.indexPathForSelectedRow!.row].url
        let uls = domain + nm
//        check.text = uls
        player(url: uls)
    }
    
    @IBAction func swipeMade(_ sender: UISwipeGestureRecognizer) {
       if sender.direction == .left {
        if segmentValue.selectedSegmentIndex == 1 {
            segmentValue.selectedSegmentIndex = 2
            view1.isHidden = true
            view2.isHidden = true
            view3.isHidden = false
        }else if segmentValue.selectedSegmentIndex == 0 {
            segmentValue.selectedSegmentIndex = 1
            view1.isHidden = true
            view2.isHidden = false
            view3.isHidden = true
        }
            
       }
       if sender.direction == .right {
            if segmentValue.selectedSegmentIndex == 2 {
                segmentValue.selectedSegmentIndex = 1
                view1.isHidden = true
                view2.isHidden = false
                view3.isHidden = true
            }else if segmentValue.selectedSegmentIndex == 1 {
                segmentValue.selectedSegmentIndex = 0
                view1.isHidden = false
                view2.isHidden = true
                view3.isHidden = true
            }
       }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action:
        #selector(swipeMade(_:)))
           leftRecognizer.direction = .left
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action:
        #selector(swipeMade(_:)))
           rightRecognizer.direction = .right
           self.view.addGestureRecognizer(leftRecognizer)
           self.view.addGestureRecognizer(rightRecognizer)
        
        dj {
               self.tableview.reloadData()
           }
           tableview.delegate = self
           tableview.dataSource = self
    
    }
    var hero = [herostats]()

    func dj(completed : @escaping () -> ())
    {
        //let url = URL(string: "https://jsonview.000webhostapp.com/jsonfile.json")
        let url = Bundle.main.url(forResource: "jsonfile", withExtension: "json")
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error == nil{
                do{
                    self.hero = try JSONDecoder().decode([herostats].self, from: data!)
                    DispatchQueue.main.async{
                        completed()
                    }
                }catch
                {
                    print("json error")
                }
            }
        }.resume()
    }
    
    
    
    @IBAction func downloadClick(_ sender: UIButton) {
         segmentValue.selectedSegmentIndex = 2
         view1.isHidden = true
         view2.isHidden = true
         view3.isHidden = false
         
         let appDel = UIApplication.shared.delegate as! AppDelegate
         let managedContext = appDel.persistentContainer.viewContext
         var downloadsArr = [NSManagedObject]()
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Downloads")
         
         do {
             
             downloadsArr = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
             print("---Count-----")
             print(downloadsArr.count)
             print("----------")
             
             for i in 0...downloadsArr.count-1 {
                 print(downloadsArr[i].value(forKey: "name")!)
             }
             
         } catch let error as NSError {
             print("Could not fetch \(error), \(error.userInfo)")
         }
    }
    
    
}

