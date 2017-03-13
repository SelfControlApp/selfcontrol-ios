//
//  BlockListViewController.swift
//  SelfControlIOS
//
//  Created by Charles Stigler on 12/24/16.
//  Copyright © 2016 SelfControl. All rights reserved.
//

import UIKit

class BlockListViewController: UITableViewController {

    var sites = ["http://www.apple.com", "http://www.gothamist.com"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockListCell", for: indexPath)
        
        cell.textLabel?.text = sites[indexPath.row]
        
        return cell
    }
    
    
}

