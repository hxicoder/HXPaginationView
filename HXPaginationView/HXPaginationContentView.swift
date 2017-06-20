//
//  HXPaginationContentView.swift
//  HXPaginationView
//
//  Created by xing on 2017/6/20.
//  Copyright © 2017年 xing. All rights reserved.
//

import UIKit

private let cellId = "cellId"

protocol HXPaginationContentViewDelegate: class {
    func contentView(_ contentView: HXPaginationContentView, targetIndex: Int)
    func contentView(_ contentView: HXPaginationContentView, targetIndex: Int, progress: CGFloat)
}

class HXPaginationContentView: UIView {
    weak var delegate: HXPaginationContentViewDelegate?
    
    fileprivate var childViewControllers: [UIViewController]
    fileprivate var parentViewController: UIViewController
    
    fileprivate var startOffsetX: CGFloat = 0
    fileprivate var isForbidScroll: Bool = false
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    init(frame: CGRect, childViewControllers: [UIViewController], parentViewController: UIViewController) {
        self.childViewControllers = childViewControllers
        self.parentViewController = parentViewController
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HXPaginationContentView {
    fileprivate func setupUI() {
        // 1.将所有子控制器添加到父控制器中
        for childVc in childViewControllers {
            parentViewController.addChildViewController(childVc)
        }
        
        // 2.添加UICollection用于展示内容
        addSubview(collectionView)
    }
}


extension HXPaginationContentView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childViewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        let childVc = childViewControllers[indexPath.item]
        childVc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVc.view)
        
        return cell
    }
}

// MARK:- UICollectionView的delegate
extension HXPaginationContentView : UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentEndScroll()
        scrollView.isScrollEnabled = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            contentEndScroll()
        } else {
            scrollView.isScrollEnabled = false
        }
    }
    
    private func contentEndScroll() {
        // 0.判断是否是禁止状态
        guard !isForbidScroll else { return }
        
        // 1.获取滚动到的位置
        let currentIndex = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        
        // 2.通知titleView进行调整
        delegate?.contentView(self, targetIndex: currentIndex)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        isForbidScroll = false
        
        startOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 0.判断和开始时的偏移量是否一致
        guard startOffsetX != scrollView.contentOffset.x, !isForbidScroll else {
            return
        }
        
        // 1.定义targetIndex/progress
        var targetIndex = 0
        var progress : CGFloat = 0.0
        
        // 2.给targetIndex/progress赋值
        let currentIndex = Int(startOffsetX / scrollView.bounds.width)
        if startOffsetX < scrollView.contentOffset.x { // 左滑动
            targetIndex = currentIndex + 1
            if targetIndex > childViewControllers.count - 1 {
                targetIndex = childViewControllers.count - 1
            }
            
            progress = (scrollView.contentOffset.x - startOffsetX) / scrollView.bounds.width
        } else { // 右滑动
            targetIndex = currentIndex - 1
            if targetIndex < 0 {
                targetIndex = 0
            }
            
            progress = (startOffsetX - scrollView.contentOffset.x) / scrollView.bounds.width
        }
        
        // 3.通知代理
        delegate?.contentView(self, targetIndex: targetIndex, progress: progress)
    }
}

// MARK:- 遵守HYTitleViewDelegate
extension HXPaginationContentView : HXPaginationTitleViewDelegate {
    func titleView(_ titleView: HXPaginationTitleView, targetIndex: Int) {
        isForbidScroll = true
        
        let indexPath = IndexPath(item: targetIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
}

