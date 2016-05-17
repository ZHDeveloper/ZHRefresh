//
//  ZHRefresh.swift
//  RefreshView
//
//  Created by AdminZhiHua on 16/5/17.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

import UIKit

private var kZHRefreshHeaderKey: String = "kHeaderKey"
private var kZHRefreshFooterKey: String = "kFooterKey"

extension UIScrollView {
    
    var headerView:ZHHeaderView? {
        get{
            
            guard let view = (objc_getAssociatedObject(self, &kZHRefreshHeaderKey) as? ZHHeaderView) else {
                
                let frame = CGRect(x: 0, y: -headerViewH, width: screenW, height: headerViewH)
                
                let view = ZHHeaderView(frame: frame)
                self.headerView = view
                
                self.addSubview(view)
                
                return view;
            }
            
            return view
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kZHRefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    var footerView:ZHFooterView? {
        get{
            
            guard let view = (objc_getAssociatedObject(self, &kZHRefreshFooterKey) as? ZHFooterView) else {
                
                let frame = CGRect(x: 0, y: contentSize.height+contentInset.bottom, width: screenW, height: headerViewH)
                
                let view = ZHFooterView(frame: frame)
                self.footerView = view
                
                self.addSubview(view)
                
                return view
            }

            return view
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kZHRefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addHeaderWithCallback(headerCallback:CompleteHandler) {
        
        self.headerView?.headerCallback = headerCallback
        
    }
    
    func addFooterWithCallback(footerCallback:CompleteHandler) {
        
        self.footerView?.footerCallback = footerCallback
        
    }
    
    func headerBeginRefreshing() {
        
    }
    
    func headerEndRefreshing() {
        
    }
    
    func footerBeginRefreshing() {
        
    }
    
    func footerEndRefreshing() {
        
    }
    
}

class ZHHeaderView: UIView {
    
    var headerCallback:CompleteHandler?

}

class ZHFooterView: UIView {
    
    var footerCallback:CompleteHandler?

}


extension UIScrollView:UIScrollViewDelegate {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if headerView?.headerCallback != nil {
            headerView?.headerCallback!()
        }
        
    }
    
}

