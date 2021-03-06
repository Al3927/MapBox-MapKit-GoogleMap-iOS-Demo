//
//  TableViewController.swift
//  mapApp
//
//  Created by user on 5/18/20.
//  Copyright © 2020 Vinova.Train.mapApp. All rights reserved.
//

import UIKit



class TableViewController: UITableViewController {
    
    let maps = ["Google", "MapBox", "MapKit"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
       
        setupTableView()
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear

    
        //let a = UITableView()
        
        //self.tableView.setContentOffset(CGPoint(x: 0, y: 60), animated: false)
        
        
    }
    
    private func setupTableView() {
        tableView.register(CellTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
        //tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
       // tableView.separatorColor = .mainTextBlue
        //tableView.backgroundColor = UIColor.rgb(r: 12, g: 47, b: 57)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.tableFooterView = UIView()
    }
    
    var delegate: GoToTheMap? = nil

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return maps.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let myCell = cell as? CellTableViewCell {
            myCell.textLabel?.text = maps[indexPath.row]
            myCell.textLabel?.textAlignment = .center
            myCell.contentView.backgroundColor = .clear
            myCell.backgroundColor = .clear
            return myCell
            
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //self.delegate?.show(whatMap: maps[indexPath.row])

        if maps[indexPath.row] == "Google" {
            self.navigationController?.pushViewController(GoogleMapViewController(), animated: true)
        } else if maps[indexPath.row] == "MapBox" {
            self.navigationController?.pushViewController(NewMapBoxViewController(), animated: true)
        }
        else if maps[indexPath.row] == "MapKit" {
            self.navigationController?.pushViewController(AppleMapsViewController(), animated: true)
        }
        
        dismiss(animated: true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}


