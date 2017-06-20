//
//  HXPaginationTitleView.swift
//  HXPaginationView
//
//  Created by xing on 2017/6/20.
//  Copyright © 2017年 xing. All rights reserved.
//

import UIKit

protocol HXPaginationTitleViewDelegate: class {
    func titleView(_ titleView: HXPaginationTitleView, targetIndex: Int);
}

class HXPaginationTitleView: UIView {
    weak var delegate: HXPaginationTitleViewDelegate?
    
    fileprivate var titles: [String]
    fileprivate var style: HXPaginationStyle
    
    fileprivate lazy var currentIndex: Int = 0
    
    fileprivate lazy var titleLabels: [UILabel] = [UILabel]()
    
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        return scrollView
    }()
    
    fileprivate lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.scrollLineColor
        bottomLine.frame.size.height = self.style.scrollLineHeight
        bottomLine.frame.origin.y = self.bounds.height - self.style.scrollLineHeight
        return bottomLine
    }()
    
    init(frame: CGRect, titles: [String], style: HXPaginationStyle) {
        self.titles = titles
        self.style = style
        
        super.init(frame: frame)
        
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HXPaginationTitleView {
    fileprivate func setupSubViews() {
        // 1.将UIScrollVIew添加到view中
        addSubview(scrollView)
        
        // 2.将titleLabel添加到UIScrollView中
        setupTitleLabels()
        
        // 3.设置titleLabel的frame
        setupTitleLabelsFrame()
        
        // 4.添加滚动条
        if style.isShowScrollLine {
            scrollView.addSubview(bottomLine)
        }
    }
    
    private func setupTitleLabels() {
        for (i, title) in titles.enumerated() {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: style.fontSize)
            titleLabel.tag = i
            titleLabel.textAlignment = .center
            titleLabel.textColor = i == 0 ? style.selectColor : style.normalColor
            
            scrollView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
            
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(titleLabelClick(_:)))
            titleLabel.addGestureRecognizer(tapGes)
            titleLabel.isUserInteractionEnabled = true
        }
    }
    
    private func setupTitleLabelsFrame() {
        let count = titles.count
        
        for (i, label) in titleLabels.enumerated() {
            var w: CGFloat = 0
            let h: CGFloat = bounds.height
            var x: CGFloat = 0
            let y: CGFloat = 0
            
            if style.isScrollEnable { // 可以滚动
                w = (titles[i] as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : label.font], context: nil).width
                if i == 0 {
                    x = style.itemMargin * 0.5
                    if style.isShowScrollLine {
                        bottomLine.frame.origin.x = x
                        bottomLine.frame.size.width = w
                    }
                } else {
                    let preLabel = titleLabels[i - 1]
                    x = preLabel.frame.maxX + style.itemMargin
                }
            } else { // 不能滚动
                w = bounds.width / CGFloat(count)
                x = w * CGFloat(i)
                
                if i == 0 && style.isShowScrollLine {
                    bottomLine.frame.origin.x = 0
                    bottomLine.frame.size.width = w
                }
            }
            
            label.frame = CGRect(x: x, y: y, width: w, height: h)
        }
        
        scrollView.contentSize = style.isScrollEnable ? CGSize(width: titleLabels.last!.frame.maxX + style.itemMargin * 0.5, height: 0) : CGSize.zero
    }

}

extension HXPaginationTitleView {
    @objc fileprivate func titleLabelClick(_ tapGes : UITapGestureRecognizer) {
        // 1.取出用户点击的View
        let targetLabel = tapGes.view as! UILabel
        
        // 2.调整title
        adjustTitleLabel(targetIndex: targetLabel.tag)
        
        // 3.调整bottomLine
        if style.isShowScrollLine {
            UIView.animate(withDuration: 0.25, animations: {
                self.bottomLine.frame.origin.x = targetLabel.frame.origin.x
                self.bottomLine.frame.size.width = targetLabel.frame.width
            })
        }
        
        // 3.通知代理
        delegate?.titleView(self, targetIndex: currentIndex)
    }
    
    fileprivate func adjustTitleLabel(targetIndex : Int) {
        if targetIndex == currentIndex { return }
        
        // 1.取出Label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        
        // 2.切换文字的颜色
        targetLabel.textColor = style.selectColor
        sourceLabel.textColor = style.normalColor
        
        // 3.记录下标值
        currentIndex = targetIndex
        
        // 4.调整位置
        if style.isScrollEnable {
            var offsetX = targetLabel.center.x - scrollView.bounds.width * 0.5
            if offsetX < 0 {
                offsetX = 0
            }
            if offsetX > (scrollView.contentSize.width - scrollView.bounds.width) {
                offsetX = scrollView.contentSize.width - scrollView.bounds.width
            }
            scrollView.setContentOffset(CGPoint(x: offsetX, y : 0), animated: true)
        }
    }
}

extension HXPaginationTitleView: HXPaginationContentViewDelegate {
    func contentView(_ contentView: HXPaginationContentView, targetIndex: Int) {
        adjustTitleLabel(targetIndex: targetIndex)
    }
    
    func contentView(_ contentView: HXPaginationContentView, targetIndex: Int, progress: CGFloat) {
        // 1.取出Label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        
        // 2.颜色渐变
        let deltaRGB = UIColor.getRGBDelta(style.selectColor, style.normalColor)
        let selectRGB = style.selectColor.getRGB()
        let normalRGB = style.normalColor.getRGB()
        targetLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress, g: normalRGB.1 + deltaRGB.1 * progress, b: normalRGB.2 + deltaRGB.2 * progress)
        sourceLabel.textColor = UIColor(r: selectRGB.0 - deltaRGB.0 * progress, g: selectRGB.1 - deltaRGB.1 * progress, b: selectRGB.2 - deltaRGB.2 * progress)
        
        // 3.bottomLine渐变过程
        if style.isShowScrollLine {
            let deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
            let deltaW = targetLabel.frame.width - sourceLabel.frame.width
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + deltaX * progress
            bottomLine.frame.size.width = sourceLabel.frame.width + deltaW * progress
        }
    }
}


