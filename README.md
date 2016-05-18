# ZHRefresh

---
title: ZHRefresh(Swift上下拉刷新)
date: 2016-05-18 16:38:36
categories: [Swift进阶]
tags:
---

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

通过重写方法willMoveToSuperview，将父view(UIScrollView)作为ZHRefreshComponent的属性。


    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        scrollView = newSuperview as? UIScrollView
    }
    
#### ZHHeaderView、ZHFooterView

ZHHeaderView上拉刷新的view，继承自ZHRefreshComponent。

通过重写父类scrollView属性，将ZHHeaderView设置为scrollview的代理，并且设置属性insetTop（scrollview.contentInset.top）

ZHHeaderView类中添加多一个子view(arrowView)。

定义ZHHeaderView的拓展，实现UIScrollViewDelegate
	
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //下拉刷新，refreshOffset判断刷新状态。
        let refreshOffset = -(scrollView.contentOffset.y+scrollView.contentInset.top)
        
        //触发条件
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
    
        func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let refreshOffset = -(scrollView.contentOffset.y+scrollView.contentInset.top)
        
        //当用户结束拖拽时，判断offset是否大于头部试图的高度，如果是的执行刷新的方法
        if refreshOffset > headerViewH {
            headerBeginRefresh()
        }
        
        //scroll的代理对象只有一个，所以下拉刷新的判断也放在这里进行
        let loadMoreOffset = scrollView.contentSize.height - scrollView.contentOffset.y - (scrollView.frame.height - scrollView.contentInset.bottom)
        
        if (loadMoreOffset < -footerViewH) {
            scrollView.footerBeginRefreshing()
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


    
    


