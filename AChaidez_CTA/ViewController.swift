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

// TODO: Configure a way to switch between lines
//Locations API
var feed =
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=e2914a1bff374380b597c72183beb83d&rt=red&outputType=JSON"

class ViewController: UIViewController
{
    class Train
    {
        var arrivalTime: String = ""; //arrT
        var destination: String = ""; //destNm
        //var line: String = ""; //rt
        var nextStop: String = ""; //nextStaNm"
        var approaching:String = ""; //isApp
        var delayed:String = ""; //isDly
    }
    
    @IBOutlet weak var trainTableView: UITableView!
    @IBOutlet weak var trainLines: UISegmentedControl!
    
    var trainArray: [Train] = []
    var dataAvailable = false;
    
    enum SerializationError: Error
    {
        case missing(String)
        case invalid(String, Any)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
 
        trainTableView.delegate = self;
        trainTableView.dataSource = self;
        loadInfo();
        /*
        // Do any additional setup after loading the view.
        guard let feedURL = URL(string: feed) else { return }
        
        let request = URLRequest(url: feedURL)
        let session = URLSession.shared
        session.dataTask(with: request)
        {
            data, response, error in
            guard error == nil else
            {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            //not sure what this does
            //print(data);
            //print("Hello Art");
            
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
                    // For locations API
                    //use ctatt, not json to get info
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
                    /*
                    let route = ctatt["route"] as! [[String: Any]];
                    //print(route); //see output below
                    let trainIndex = route[0];
                    //print(train)
                    let trains = trainIndex["train"] as! [[String: Any]];
                    //print(trains)
                    print(trains.count) */
                                        
                    //let eta = ctatt["eta"] as! [[String:Any]];
                    for e in trains
                    {
                        do {
                            let info = Train();
                            guard let arrTime = e["arrT"] as? String else
                            {
                                throw SerializationError.missing("arrT");
                            }
                            guard let dest = e["destNm"] as? String else
                            {
                                throw SerializationError.missing("destNm");
                            }
                            guard let nextStop = e["nextStaNm"] as? String else
                            {
                                throw SerializationError.missing("nextStaNm");
                            }
                            guard let appr = e["isApp"] as? String else
                            {
                                throw SerializationError.missing("isApp");
                            }
                            guard let delayed = e["isDly"] as? String else
                            {
                                throw SerializationError.missing("isDly");
                            }
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
                    //print(self.trainArray.count);
                    DispatchQueue.main.async
                    {
                        self.trainTableView.reloadData();
                    }
                    //let destNm = eta.compactMap { $0["destNm"] as? String}
                    //print(eta.count);
                    //print(destNm);
                }
            } catch SerializationError.missing(let msg) {
                print("Missing \(msg)");
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }.resume() */
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectTrainLine(_ sender: UISegmentedControl)
    {
        let name : String = sender.titleForSegment(at: sender.selectedSegmentIndex)!

        // TODO: switchs work, but returns error code 500: "Invalid parameter: 'rt'
        switch name
        {
        case "blue": feed = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&rt=blue&outputType=JSON"
        case "brn": feed = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&rt=brn&outputType=JSON"
        case "G": feed = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&rt=G&outputType=JSON"
        case "Org": feed = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&rt=Org&outputType=JSON"
        case "P": feed = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&rt=P&outputType=JSON"
        case "Pink": feed = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&rt=Pink&outputType=JSON"
        case "Y": feed = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&rt=Y&outputType=JSON"
        default: feed = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=e2914a1bff374380b597c72183beb83d&rt=red&outputType=JSON"
        }
        print(feed);
        
        loadInfo();
        
    }
    
    func loadInfo ()
    {
        guard let feedURL = URL(string: feed) else { return }
        
        let request = URLRequest(url: feedURL)
        let session = URLSession.shared
        session.dataTask(with: request)
        {
            data, response, error in
            guard error == nil else
            {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            
            do {
                if let json =
                    try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                {
                    // guard let on something that has = { following it
                    print(json);
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

                    for e in trains
                    {
                        do {
                            let info = Train();
                            guard let arrTime = e["arrT"] as? String else
                            {
                                throw SerializationError.missing("arrT");
                            }
                            guard let dest = e["destNm"] as? String else
                            {
                                throw SerializationError.missing("destNm");
                            }
                            guard let nextStop = e["nextStaNm"] as? String else
                            {
                                throw SerializationError.missing("nextStaNm");
                            }
                            guard let appr = e["isApp"] as? String else
                            {
                                throw SerializationError.missing("isApp");
                            }
                            guard let delayed = e["isDly"] as? String else
                            {
                                throw SerializationError.missing("isDly");
                            }
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
    
    


extension ViewController: UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //TODO: Format Time right
        //print("Clicked on cell");
        
        let record = trainArray[indexPath.row];
        let title = record.nextStop;
        let dateformatter = DateFormatter();
        dateformatter.dateFormat = "HH:mm";
        // string format = "2015-04-30T20:23:32
        let time = record.arrivalTime;
        print(time.split(separator: "T", maxSplits: 1, omittingEmptySubsequences: false));
        //let newClock = dateformatter.string(from: record.arrivalTime);
        
        let message = record.destination + " " + record.arrivalTime; //format this time
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (dataAvailable)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "trainCell", for: indexPath);
            let record = trainArray[indexPath.row];

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
