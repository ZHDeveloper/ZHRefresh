//
//  ViewController.swift
//  RefreshView
//
//  Created by AdminZhiHua on 16/5/17.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentSize = CGSize(width: screenW+300, height: screenH+300)
        
        scrollView.addHeaderWithCallback { 
            self.performSelector(#selector(self.headerCallback))
        }
        scrollView.addFooterWithCallback { 
            self.performSelector(#selector(self.footerCallback))
        }
    }
    
    func headerCallback() {
        print("---")
    }
    
    func footerCallback() {
        print("+++")
    }

}

