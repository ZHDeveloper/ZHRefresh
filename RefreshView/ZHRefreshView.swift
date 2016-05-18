//
//  ZHRefreshView.swift
//  RefreshView
//
//  Created by AdminZhiHua on 16/5/18.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

import UIKit

private var kContentSizeKey = "contentSize"
private var kContentOffsetKey = "contentOffset"

class ZHRefreshComponent: UIView {
    
    //回调方法
    internal var handler:CompleteHandler?
    
    //是否正在刷新
    var isRefreshing:Bool = false

    private var oldStatus:ZHRefreshStatus = .pullToRefresh
    
    private var status:ZHRefreshStatus {
        didSet {
            oldStatus = oldValue
        }
    }
    
    //菊花
    private let indicatorView: UIActivityIndicatorView = {
        
        let indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        indicatorView.startAnimating()
        indicatorView.hidesWhenStopped = false
        indicatorView.hidden = true
        
        return indicatorView
    }()
    
    private let titleLabel:UILabel = {
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor(white: 160.0 / 255.0, alpha: 1.0)
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.text = "下拉刷新..."
        
        return titleLabel
    }()
    
    weak var scrollView:UIScrollView?
    
    override init(frame: CGRect) {
        status = .pullToRefresh
        
        super.init(frame: frame)
        
        self.addSubview(indicatorView)
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        removeObserver()
        
        scrollView = newSuperview as? UIScrollView
        
        addObserver(scrollView!)
    }
    
    func addObserver(scrollView:UIScrollView) {
        
        scrollView.addObserver(self, forKeyPath: kContentOffsetKey, options: [.New,.Initial], context: nil)
        scrollView.addObserver(self, forKeyPath: kContentSizeKey, options: [.New,.Initial], context: nil)
    }
    
    func removeObserver() {
        
        scrollView?.removeObserver(self, forKeyPath: kContentOffsetKey)
        scrollView?.removeObserver(self, forKeyPath: kContentSizeKey)
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let size = self.bounds.size
        let width = size.width
        let height = size.height
        
        indicatorView.sizeToFit()
        titleLabel.sizeToFit()
        
        let indicatorViewSize = indicatorView.bounds.size
        let titleLabelSize = titleLabel.bounds.size
        
        let margin:CGFloat = componentsMarin
        
        let indicatorViewX = (width-(titleLabelSize.width+indicatorViewSize.width+margin))*0.5
        
        let indicatorViewY = (height - indicatorViewSize.height)*0.5
        
        indicatorView.frame = CGRect(x: indicatorViewX, y: indicatorViewY, width: indicatorViewSize.width, height: indicatorViewSize.height)
        
        let titlelableX = indicatorViewX+margin+indicatorViewSize.width
        
        titleLabel.frame = CGRect(x: titlelableX, y: 0.0, width: titleLabelSize.width, height: height)
    }
    
}

// MARK: - KVO
extension ZHRefreshComponent {
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
     
        if keyPath == kContentSizeKey  {
            contentSizeChange(object: object, change: change)
        }
        else if keyPath == kContentOffsetKey {
            contentOffsetChange(object: object, change: change)
        }
    }
    
    func contentSizeChange(object object: AnyObject?, change: [String : AnyObject]?) {
        
    }
    
    func contentOffsetChange(object object: AnyObject?, change: [String : AnyObject]?) {
        
    }
    
}

class ZHHeaderView: ZHRefreshComponent {
    
    private var insetTop:CGFloat = 0.0

    //重写父类的属性，设置代理方法
    override var scrollView:UIScrollView? {
        didSet {//设置代理属性
            insetTop = scrollView!.contentInset.top
        }
    }
    
    //图片箭头
    private let arrowView:UIImageView = {
        
        let image = UIImage(named: "refresh_arrow")
        
        let imageView = UIImageView(image: image)
        
        return imageView
        
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        indicatorView.hidden = true
        
        self.addSubview(arrowView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        arrowView.sizeToFit()
        
        let arrowViewSize = arrowView.bounds.size
        
        let arrowViewX = titleLabel.frame.origin.x-10-arrowViewSize.width
        let arrowViewY = (self.bounds.height-arrowViewSize.height)*0.5
        
        arrowView.frame = CGRectMake(arrowViewX, arrowViewY, arrowViewSize.width, arrowViewSize.height)
    }
}

extension ZHHeaderView {
    
    override func contentOffsetChange(object object: AnyObject?, change: [String : AnyObject]?) {
        
        guard let scrollView = scrollView else {
            return
        }
        
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
        
        guard isRefreshing == false,let refreshHandler = handler else {
            return
        }
        
        self.isRefreshing = true
        
        status = .loading
        
        refreshHeaderView(.loading)
        
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: .BeginFromCurrentState, animations: {
            // 把 contentInsetTop 设为刷新头高度加上初始状态时的值，露出刷新头，保持在那个位置等待刷新结束
            self.scrollView!.contentInset.top = headerViewH + self.insetTop
            // scrollIndicator，即旁边的滚动提示，看起来更好些，也可以不设置。
            self.scrollView!.scrollIndicatorInsets = self.scrollView!.contentInset
            
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
                
        }

    }
    
}

class ZHFooterView: ZHRefreshComponent {
    
    private var insetBottom:CGFloat = 0.0
    
    override var scrollView: UIScrollView? {
        didSet {
            insetBottom = scrollView!.contentInset.bottom
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.text = "加载更多..."
        
        indicatorView.hidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ZHFooterView {
    
    override func contentOffsetChange(object object: AnyObject?, change: [String : AnyObject]?) {
        
        //上拉刷新
        guard let scrollView = scrollView else {
            return
        }
        
        let loadMoreOffset = scrollView.contentSize.height - scrollView.contentOffset.y - (scrollView.frame.height - scrollView.contentInset.bottom)
        
        print(loadMoreOffset)
        
        if (loadMoreOffset < -footerViewH) {
            footerBeginLoadMore()
        }

    }
    
    override func contentSizeChange(object object: AnyObject?, change: [String : AnyObject]?) {
        
        guard let scrollView = scrollView else {return}
        
        let targetY = scrollView.contentSize.height + insetBottom
        if self.frame.origin.y != targetY {
            var rect = self.frame
            rect.origin.y = targetY
            self.frame = rect
        }

    }
    
    //开始加载更多
    func footerBeginLoadMore() {
        
        guard isRefreshing == false,let loadMoreHandler = handler else {
            return
        }
        
        isRefreshing = true
        
        UIView.animateWithDuration(0.5, animations: {
            
            var inset = self.scrollView!.contentInset
            inset.bottom = inset.bottom + footerViewH
            self.scrollView!.contentInset = inset

            }) { (finish) in
                //执行回调方法
                loadMoreHandler()
        }
        
    }
    
    func footerEndLoadMore() {
        
        isRefreshing = false
        
        UIView.animateWithDuration(0.5) {
            var inset = self.scrollView!.contentInset
            inset.bottom = self.insetBottom
            self.scrollView!.contentInset = inset
        }
    }
    
}
