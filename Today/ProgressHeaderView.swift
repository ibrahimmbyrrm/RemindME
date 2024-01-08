//
//  ProgressHeaderView.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

class ProgressHeaderView : UICollectionReusableView {
    
    static var elementKind : String { UICollectionView.elementKindSectionHeader }
    
    var progress : CGFloat = 0 {
        didSet {
            setNeedsLayout()
            heightConstraints?.constant = progress * bounds.height
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    private let upperView = UIView(frame: .zero)
    private let lowerView = UIView(frame: .zero)
    private let containerView = UIView(frame: .zero)
    private var heightConstraints : NSLayoutConstraint?
    private var valueFormat : String {
        NSLocalizedString("%d percent", comment: "progress percentage value format")
    }
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        prepareSubviews()
        isAccessibilityElement = true
        accessibilityLabel = NSLocalizedString("Progress", comment: "Progress view accesibility label")
        accessibilityTraits.update(with: .updatesFrequently)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        accessibilityValue = String(format: valueFormat, Int(progress * 100))
        heightConstraints?.constant = progress * bounds.height
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.5 * containerView.bounds.width
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    private func prepareSubviews() {
        containerView.addSubview(upperView)
        containerView.addSubview(lowerView)
        addSubview(containerView)
        
        [upperView,lowerView,containerView].forEach({$0.translatesAutoresizingMaskIntoConstraints = false})
        heightConstraints = lowerView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraints?.isActive = true
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            
            containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            
            
            upperView.topAnchor.constraint(equalTo: topAnchor),
            upperView.bottomAnchor.constraint(equalTo: lowerView.topAnchor),
            lowerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            
            upperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            upperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lowerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lowerView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        upperView.backgroundColor = .todayProgressUpperBackground
        lowerView.backgroundColor = .todayProgressLowerBackground
    }
}
