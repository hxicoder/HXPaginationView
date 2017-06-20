//
//  HXPaginationStyle.swift
//  HXPaginationView
//
//  Created by xing on 2017/6/20.
//  Copyright © 2017年 xing. All rights reserved.
//

import UIKit

class HXPaginationStyle {
    var titleHeight: CGFloat = 44
    
    var normalColor: UIColor = UIColor(r: 0, g: 0, b: 0)
    var selectColor: UIColor = UIColor(r: 255, g: 127, b: 0)
    var fontSize: CGFloat = 15.0
    
    /// 标题栏滚动标识 false: 不能滚动 true: 支持滚动
    var isScrollEnable: Bool = false
    
    /// 底部线显示标识 false: 不显示 true: 显示
    var isShowScrollLine : Bool = false
    
    var scrollLineHeight : CGFloat = 2
    var scrollLineColor : UIColor = .orange
    
    var itemMargin: CGFloat = 30
}
