//
//  ViewController.swift
//  AChaidez_CTA
//
//  Created by Arturo Chaidez on 4/24/21.
//

import UIKit


//works within do try loop
//https://stackoverflow.com/questions/46262942/printing-valid-json-with-a-swift-script
/*
if let JSONString = String(data: data, encoding: String.Encoding.utf8)
{
    print(JSONString); //also does not work
} */

//Use Arrivals API
/* let feed = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=e2914a1bff374380b597c72183beb83d&mapid=40380&outputType=JSON" */

// Follow Train API
/*let feed =
    "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&outputType=JSON" */

//Locations API
var feed =
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=red&outputType=JSON"

class ViewController: UIViewController
{
    @IBOutlet weak var trainTableView: UITableView!
    @IBOutlet weak var trainLines: UISegmentedControl!
    
    var trainArray: [Train] = [];
    var dataAvailable = false;
    
    enum SerializationError: Error
    {
        case missing(String);
        case invalid(String, Any) //never used
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        trainTableView.delegate = self;
        trainTableView.dataSource = self;
        loadInfo();
        self.trainTableView.addSubview(self.refreshControl);
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    // Note: Removed refresh button, swipe down on table to refresh data
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)),for: UIControl.Event.valueChanged);
        return refreshControl;
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl)
    {
        //print("refresh");
        loadInfo();
        //self.tableView.reloadData()
        refreshControl.endRefreshing();
    }
    
    @IBAction func selectTrainLine(_ sender: UISegmentedControl)
    {
        let name : String = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        switch name
        {
        case "Blue": feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=blue&outputType=JSON"
        case "Brn": feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=brn&outputType=JSON"
        case "G": feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=G&outputType=JSON"
        case "Org": feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=Org&outputType=JSON"
        case "P": feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=P&outputType=JSON"
        case "Pink": feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=Pink&outputType=JSON"
        case "Y": feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=Y&outputType=JSON"
        default: feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=red&outputType=JSON"
        }
        //print(feed);
        loadInfo();
    }
    /*
    func convertTimeTo12(arrivalTime: String) -> String
    {
        var time12:String = "";
        if let range = arrivalTime.range(of: "T") {
            let time24 = arrivalTime[range.upperBound...];
            //print(time24);

            let df = DateFormatter()
            df.dateFormat = "HH:mm:ss"

            let date = df.date(from: String(time24))
            df.dateFormat = "hh:mm a"

            time12 = df.string(from: date!)
            //print(time12)
        }
        return time12;
    }
    */
    func convertTimeString(arrivalTime: String) -> String
    {
        var time12:String = "";
        if let range = arrivalTime.range(of: "T") {
            let time24 = arrivalTime[range.upperBound...];
            //print(time24);
            
            if let date24 = Formatter.stringToDate.date(from: String(time24))
            {
                //print(date24);
                //print(Date());
                time12 = Formatter.toAMPM.string(from: date24);
                //print(time12);
            } else
            {
                print("There was an error decoding the string")
            }
        }
        return time12;
    }
    /*
    func convertDate(arrivalTime: String) -> String
    {
        var time12:String = "";
        if let range = arrivalTime.range(of: "T") {
            let time24 = String(arrivalTime[arrivalTime.startIndex..<range.lowerBound]  + " " + arrivalTime[range.upperBound...]);
            //print();
            //print(time24);
            time12 = time24;
        }
        return time12;
    }
    */
    @objc func loadInfo ()
    {
        trainArray = []; // empty tableView
        guard let feedURL = URL(string: feed) else { return }
        
        let request = URLRequest(url: feedURL);
        let session = URLSession.shared;
        session.dataTask(with: request)
        {
            data, response, error in
            guard error == nil else
            {
                print(error!.localizedDescription);
                return
            }
            guard let data = data else { return }
            
            do {
                if let json =
                    try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                {
                    // guard let on something that has = { following it
                    //print(json);
                    guard let ctatt = json["ctatt"] as? [String: Any] else
                    {
                        throw SerializationError.missing("ctatt");
                    }
                    //print(ctatt); //returns array
                    guard let route = ctatt["route"] as? [[String:Any]] else
                    {
                        throw SerializationError.missing("route");
                    }
                    //TODO: Change to not use exact index
                    let trainIndex = route[0];
                    guard let trains = trainIndex["train"] as? [[String: Any]] else
                    {
                        throw SerializationError.missing("train");
                    }

                    for train in trains
                    {
                        do {
                            let info = Train();
                            guard let arrTime = train["arrT"] as? String else
                            {
                                throw SerializationError.missing("arrT");
                            }
                            guard let dest = train["destNm"] as? String else
                            {
                                throw SerializationError.missing("destNm");
                            }
                            guard let nextStop = train["nextStaNm"] as? String else
                            {
                                throw SerializationError.missing("nextStaNm");
                            }
                            guard let appr = train["isApp"] as? String else
                            {
                                throw SerializationError.missing("isApp");
                            }
                            guard let delayed = train["isDly"] as? String else
                            {
                                throw SerializationError.missing("isDly");
                            }
                            //print(arrTime);
                            info.arrivalTime = arrTime;
                            info.destination = dest;
                            info.nextStop = nextStop;
                            info.approaching = appr;
                            info.delayed = delayed;
                            self.trainArray.append(info);
                            
                        } catch SerializationError.missing(let msg)
                        {
                            print("Missing \(msg)");
                        } catch let error as NSError {
                            print(error.localizedDescription);
                        }
                    }
                    self.dataAvailable = true;
                    DispatchQueue.main.async
                    {
                        self.trainTableView.reloadData();
                    }
                }
            } catch SerializationError.missing(let msg) {
                print("Missing \(msg)");
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }.resume()
    }
    
}

//DateFormatter expensive to make, cache a single instance
//Was originally creating a Formatter every time in func convertTimeTo12
extension Formatter {
    
    static let stringToDate : DateFormatter = {
        let df = DateFormatter();
        df.dateFormat = "HH:mm:ss";
        return df;
    }()
    
    static let toAMPM : DateFormatter = {
        let df = DateFormatter();
        df.dateFormat = "hh:mm a";
        return df;
    }()
    // Note: Not used
    static let toDate : DateFormatter = {
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd hh:mm:ss";
        return df;
    }()
}

extension ViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let record = trainArray[indexPath.row];
        let title = "Next Stop: " + record.nextStop;
        //let time = convertTimeTo12(arrivalTime: record.arrivalTime);
        let time = convertTimeString(arrivalTime: record.arrivalTime);
        
        let message = "Heading towards " + record.destination + ". Estimated arrival: " + time;
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil);
        alertController.addAction(okayAction);
        present(alertController, animated: true, completion: nil);
        //self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITableViewDataSource
{
    //not needed but keep it
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataAvailable ? trainArray.count : 1;
    }
    
    //MARK: Cannot get Central Time only from Date, having issues comparing current time to arival time
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if (dataAvailable)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "trainCell", for: indexPath);
            let record = trainArray[indexPath.row]; //Note: error appeared here once
            
            if (record.approaching == "1")
            {
                cell.textLabel?.text = "Next Stop: " + record.nextStop + " APPROACHING";
                cell.backgroundColor = UIColor.systemGray6;
            } else if (record.delayed == "1")
            {
                cell.textLabel?.text = "Next Stop: " + record.nextStop + " DELAYED";
                cell.backgroundColor = UIColor.systemRed;
            } else
            {
                cell.textLabel?.text = "Next Stop: " + record.nextStop;
                cell.backgroundColor = UIColor.clear;
            }
            cell.detailTextLabel?.text = "Heading towards: " + record.destination;
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "trainCell", for: indexPath);
            cell.textLabel?.text = "Hello";
            cell.detailTextLabel?.text = "UM";
            return cell;
        }
    }
}
