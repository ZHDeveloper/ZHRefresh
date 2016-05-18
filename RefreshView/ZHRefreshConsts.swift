//
//  ZHRefreshConsts.swift
//  RefreshView
//
//  Created by AdminZhiHua on 16/5/17.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

import UIKit

typealias CompleteHandler = ()->()

let headerViewH: CGFloat = 60
let footerViewH: CGFloat = 44

let componentsMarin:CGFloat = 10

let screenH = UIScreen.mainScreen().bounds.size.height
let screenW = UIScreen.mainScreen().bounds.size.width

//刷新的状态
enum ZHRefreshStatus {
    case loading,pullToRefresh,releaseToRefresh,noMoreData
}