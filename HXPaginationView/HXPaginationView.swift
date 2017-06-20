//
//  HXPaginationView.swift
//  HXPaginationView
//
//  Created by xing on 2017/6/20.
//  Copyright © 2017年 xing. All rights reserved.
//

import UIKit

class HXPaginationView: UIView {
    fileprivate var titles: [String]
    fileprivate var childViewControllers: [UIViewController]
    fileprivate var parentViewController: UIViewController
    fileprivate var style: HXPaginationStyle
    
    fileprivate var titleView: HXPaginationTitleView!
    fileprivate var contentView: HXPaginationContentView!
    
    init(frame: CGRect, titles: [String], childViewControllers: [UIViewController], parentViewController: UIViewController, style: HXPaginationStyle) {
        self.titles = titles
        self.childViewControllers = childViewControllers
        self.parentViewController = parentViewController
        self.style = style
        
        super.init(frame: frame)
        
        // 初始化UI
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HXPaginationView {
    fileprivate func setupSubViews() {
        setupTitleView()
        setupContentView()
    }
    
    // 初始化标题
    fileprivate func setupTitleView() {
        let frame = CGRect(x: 0, y: 0, width: bounds.width, height: style.titleHeight)
        
        titleView = HXPaginationTitleView(frame: frame, titles: titles, style: style)
        addSubview(titleView)
        
        titleView.backgroundColor = UIColor.randomColor()
    }
    
    // 初始化content
    fileprivate func setupContentView() {
        let frame = CGRect(x: 0, y: style.titleHeight, width: bounds.width, height: bounds.height - style.titleHeight)
        contentView = HXPaginationContentView(frame: frame, childViewControllers: childViewControllers, parentViewController: parentViewController)
        
        contentView.delegate = titleView
        titleView.delegate = contentView
        
        addSubview(contentView)
        
        contentView.backgroundColor = UIColor.randomColor()
    }
}
