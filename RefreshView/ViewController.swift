//
//  ViewController.swift
//  RefreshView
//
//  Created by AdminZhiHua on 16/5/17.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

import UIKit

private var identifier = "cellIdenti"

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var count:Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)

        tableView.addHeaderWithCallback {
            self.performSelector(#selector(self.headerCallback))
        }
        tableView.addFooterWithCallback {
            self.performSelector(#selector(self.footerCallback))
        }
    }
    
    func headerCallback() {
        
        print("正在玩命刷新中。。。")
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            self.tableView.headerEndRefreshing()
            
        }
    }
    
    func footerCallback() {
        
        print("正在加载更多。。。")
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            //结束刷新状态
            self.tableView.footerEndRefreshing()
            
            self.count += 5
            self.tableView.reloadData()
        }
        
    }

}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        cell!.textLabel!.text = "ijk"
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.headerBeginRefreshing()
        
    }
    
    
}


