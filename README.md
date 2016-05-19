

整个框架中包含三个文件ZHRefresh.swift、ZHRefreshView.swift、ZHRefreshConsts.swift，其中ZHRefresh包含一些公开的调用的API

#### ZHRefresh

ZHRefresh是UIScrollView的拓展，ZHRefresh中包含两个计算属性headerView、footerView，都是使用Runtime将属性关联。两个属性使用private来修饰，为了防止被外部调用。

	//添加下拉刷新的回调方法，如果不调用这个方法是不会生成下拉的头部view
    func addHeaderWithCallback(headerCallback:CompleteHandler) {
        
        self.headerView?.handler = headerCallback
                
    }
    
    //添加上拉刷新的回调方法，如果不调用这个方法是不会生成下拉的底部view
    func addFooterWithCallback(footerCallback:CompleteHandler) {
        
        self.footerView?.handler = footerCallback
        
    }
    
    //开始刷新
    func headerBeginRefreshing() {
        self.headerView?.headerBeginRefresh()
    }
    
    //结束刷新
    func headerEndRefreshing() {
        self.headerView?.headerEndRefresh()
    }
    
    //开始加载更多
    func footerBeginRefreshing() {
        self.footerView?.footerBeginLoadMore()
    }
    
    //结束加载更多
    func footerEndRefreshing() {
        self.footerView?.footerEndLoadMore()
    }


#### ZHRefreshComponent

ZHRefreshComponent定义了上拉、下拉view。

ZHRefreshComponent类是上拉、下拉view的父类，包含了上拉、下拉刷新view共有的属性和方法。子类通过继承获取父类的共有的属性和方法。

ZHRefreshComponent共有的属性：

1. handler:上拉或者下拉刷新的回调方法
2. isRefreshing:是否正在执行刷新中
3. oldStatus:上一次的刷新状态
4. status:当前的刷新状态
5. indicatorView：菊花view
6. titleLabel:标题Label

通过重写方法willMoveToSuperview，将父view(UIScrollView)作为ZHRefreshComponent的属性。并添加观察者，在销毁时取消观察者。


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
    
#### ZHHeaderView、ZHFooterView

ZHHeaderView上拉刷新的view，继承自ZHRefreshComponent。

通过重写父类scrollView属性，将ZHHeaderView设置为scrollview的观察者，并且设置属性insetTop（scrollview.contentInset.top）

ZHHeaderView类中添加多一个子view(arrowView)。

定义ZHHeaderView的拓展，观察属性的变化
	
    override func contentOffsetChange(object object: AnyObject?, change: [String : AnyObject]?) {
        
        //因为属性scrollView是可选类型，所以这里需要判断scrollView是否有值
        guard let scrollView = scrollView else {
            return
        }
        
        //下拉刷新
        let refreshOffset = -(scrollView.contentOffset.y+scrollView.contentInset.top)
        
        //判断刷新状态变化的临界点
        if refreshOffset > headerViewH {
            self.status = .releaseToRefresh
            
            if scrollView.dragging {
                releaseToRefresh()
            }
            else
            {
                scrollViewDidEndDragging(scrollView)
            }
        }
        else
        {
            self.status = .pullToRefresh
            pullToRefresh()
        }

    }

    
 ZHFooterView的实现和ZHHeaderView差不多。
 
#### ZHRefreshConsts
 
 ZHRefreshConsts定义一些常亮
 
	typealias CompleteHandler = ()->()
	
	let headerViewH: CGFloat = 60
	let footerViewH: CGFloat = 44
	
	let componentsMarin:CGFloat = 10
	
	let screenH = UIScreen.mainScreen().bounds.size.height
	let screenW = UIScreen.mainScreen().bounds.size.width
	
	//刷新的状态
	enum ZHRefreshStatus {
	    case loading,pullToRefresh,releaseToRefresh
	}

#### 分析

1、下拉刷新状态的变化。
		
		
        let refreshOffset = -(scrollView.contentOffset.y+scrollView.contentInset.top)
        
        //判断下拉的距离是否达到一定的距离
        if refreshOffset > headerViewH {
            self.status = .releaseToRefresh
            
            //判断是否结束刷新
            if scrollView.dragging {
                releaseToRefresh()
            }
            else
            {
                scrollViewDidEndDragging(scrollView)
            }
        }
        else
        {
            self.status = .pullToRefresh
            pullToRefresh()
        }

	//正在刷新的方法
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


2、上拉刷新的判断

	override func contentOffsetChange(object object: AnyObject?, change: [String : AnyObject]?) {
	        
	        //上拉刷新
	        guard let scrollView = scrollView else {
	            return
	        }
	        
	        guard isRefreshing == false else {
	            return
	        }
	        
	        //判断是上拉还是下拉，如果是下拉则隐藏
	        if scrollView.contentSize.height <= 0.0 || scrollView.contentOffset.y + scrollView.contentInset.top <= 0.0 {
	            self.alpha = 0.0
	            return
	        } else {
	            self.alpha = 1.0
	        }
	        
	        if scrollView.contentSize.height + scrollView.contentInset.top > scrollView.bounds.size.height {
	            // 内容超过一个屏幕 计算公式，判断是不是在拖在到了底部
	            if scrollView.contentSize.height - scrollView.contentOffset.y + scrollView.contentInset.bottom  <= scrollView.bounds.size.height {
	                footerBeginLoadMore()
	            }
	        } else {
	            //内容没有超过一个屏幕，这时拖拽高度大于1/2footer的高度就表示请求上拉
	            if scrollView.contentOffset.y + scrollView.contentInset.top >= footerViewH / 2.0 {
	                footerBeginLoadMore()
	            }
	        }
	        
	    }

    
    


