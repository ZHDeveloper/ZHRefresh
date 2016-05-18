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
    
//    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)
        
//        self.tableView.contentSize = CGSize(width: screenW, height: screenH+300)
        
        tableView.addHeaderWithCallback {
            self.performSelector(#selector(self.headerCallback))
        }
        tableView.addFooterWithCallback {
            self.performSelector(#selector(self.footerCallback))
        }
    }
    
    func headerCallback() {
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            print("正在玩命刷新中。。")
            
            self.tableView.headerEndRefreshing()
            
        }
    }
    
    func footerCallback() {
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            //结束刷新状态
            self.tableView.footerEndRefreshing()
            
        }
        
    }

}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        cell?.textLabel?.text = "ijk"
        
        return cell!
        
    }
    
}


