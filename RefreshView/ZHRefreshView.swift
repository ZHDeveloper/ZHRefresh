//
//  ZHRefreshView.swift
//  RefreshView
//
//  Created by AdminZhiHua on 16/5/18.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

import UIKit

class ZHHeaderView: UIView {
    
    //是否正在刷新
    var isRefreshing:Bool = false
    
    private var oldStatus:ZHRefreshStatus = .pullToRefresh
    
    private var insetTop:CGFloat = 0.0
    
    private var status:ZHRefreshStatus {
        didSet {
            oldStatus = oldValue
        }
    }
    
    weak var scrollView:UIScrollView? {
        didSet {//设置代理属性
            scrollView!.delegate = self
            insetTop = scrollView!.contentInset.top
        }
    }
    
    //菊花
    private let indicatorView: UIActivityIndicatorView = {
        
        let indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        indicatorView.startAnimating()
        indicatorView.hidesWhenStopped = true
        indicatorView.hidden = true
        
        return indicatorView
    }()
    
    //图片箭头
    private let arrowView:UIImageView = {
        
        let image = UIImage(named: "refresh_arrow")
        
        let imageView = UIImageView(image: image)
        
        return imageView
        
    }()
    
    private let titleLabel:UILabel = {
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.init(white: 160.0 / 255.0, alpha: 1.0)
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.text = "下拉刷新..."

        return titleLabel
    }()
    
    internal var headerCallback:CompleteHandler?
    
    override init(frame: CGRect) {
        self.status = .pullToRefresh
        
        super.init(frame: frame)
        autoresizingMask = [.FlexibleLeftMargin,.FlexibleWidth,.FlexibleRightMargin]
        
        
        self.addSubview(indicatorView)
        self.addSubview(arrowView)
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        scrollView = newSuperview as? UIScrollView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let s = self.bounds.size
        let w = s.width
        let h = s.height
        
        titleLabel.frame = CGRect.init(x: w / 2.0 - 36.0, y: 0.0, width: w - (w / 2.0 - 36.0), height: h)
        indicatorView.center = CGPoint.init(x: titleLabel.frame.origin.x - 16.0, y: h / 2.0)
        arrowView.frame = CGRect.init(x: titleLabel.frame.origin.x - 28.0, y: (h - 18.0) / 2.0, width: 18.0, height: 18.0)
    }
}

extension ZHHeaderView:UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //下拉刷新
        let refreshOffset = -(scrollView.contentOffset.y+scrollView.contentInset.top)
        
        if refreshOffset > headerViewH {
            self.status = .releaseToRefresh
            releaseToRefresh()
        }
        else
        {
            self.status = .pullToRefresh
            pullToRefresh()
        }
        
    }
    
    //结束拖拽
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let refreshOffset = -(scrollView.contentOffset.y+scrollView.contentInset.top)
        
        if refreshOffset > headerViewH {
            headerBeginRefresh()
        }
        
    }
    
    //下拉刷新
    func pullToRefresh() {
        
        guard (oldStatus != status)&&(isRefreshing == false) else {
            return
        }
        
        refreshHeaderView(.pullToRefresh)
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.arrowView.transform = CGAffineTransformIdentity
            
        })
    }
    
    //松手更新
    func releaseToRefresh() {
        
        guard (oldStatus != status)&&(isRefreshing == false) else {
            return
        }
        
        refreshHeaderView(.releaseToRefresh)
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.arrowView.transform = CGAffineTransformRotate(self.arrowView.transform, CGFloat(M_PI))
            
        })
        
    }
    
    func headerBeginRefresh() {
        
        guard isRefreshing == false,let refreshHandler = headerCallback,viewOfScroll = scrollView else {
            return
        }
        
        self.isRefreshing = true
        
        status = .loading
        
        refreshHeaderView(.loading)
        
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: .BeginFromCurrentState, animations: {
            // 把 contentInsetTop 设为刷新头高度加上初始状态时的值，露出刷新头，保持在那个位置等待刷新结束
            viewOfScroll.contentInset.top = headerViewH + self.insetTop
            // scrollIndicator，即旁边的滚动提示，看起来更好些，也可以不设置。
            viewOfScroll.scrollIndicatorInsets = viewOfScroll.contentInset
            
        }) { (finished: Bool) in
            //执行block
            refreshHandler()
        }
    }
    
    func headerEndRefresh() {
        
        guard let viewOfScroll = scrollView else {
            return
        }
        
        self.isRefreshing = false
        
        UIView.animateWithDuration(0.5, animations: { 
            
            viewOfScroll.contentInset.top = self.insetTop
            viewOfScroll.scrollIndicatorInsets = viewOfScroll.contentInset
            
            }) { (finish) in
                //重新设置状态
                self.status = .releaseToRefresh
        }
        
    }
    
    func refreshHeaderView(status:ZHRefreshStatus) {
        
        switch status {
            case .pullToRefresh:
                arrowView.hidden = false
                indicatorView.hidden = true
                titleLabel.text = "下拉刷新..."
                break
                
            case .releaseToRefresh:
                arrowView.hidden = false
                indicatorView.hidden = true
                titleLabel.text = "松手刷新..."
                break
                
            case .loading:
                
                arrowView.hidden = true
                indicatorView.hidden = false
                titleLabel.text = "正在刷新..."
                break
                
            case .noMoreData:
                titleLabel.text = "下拉刷新..."
                break
        }

    }
    
}

class ZHFooterView: UIView {
    
    var footerCallback:CompleteHandler?
    
    
    
}
