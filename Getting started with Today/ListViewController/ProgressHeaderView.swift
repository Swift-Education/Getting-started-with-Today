//
//  ProgressHeaderView.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/16/24.
//

import UIKit

class ProgressHeaderView: UICollectionReusableView {
    static let elementKind: String = UICollectionView.elementKindSectionHeader
    
    var progress: CGFloat = 0 {
        didSet {
            // setNeedsLayout()를 호출하면 현재 레이아웃이 무효화되고 업데이트가 트리거됩니다.
            setNeedsLayout()
            heightConstraint?.constant = progress * bounds.height
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    private let upperView = UIView(frame: .zero)
    private let lowerView = UIView(frame: .zero)
    private let containerView = UIView(frame: .zero)
    private var heightConstraint: NSLayoutConstraint?
    // 버튼에 접근성 값을 추가할 것입니다. 각 알림의 완료 상태에 대한 현지화된 문자열을 계산하는 것으로 시작하십시오.
    var valueFormat: String {
        NSLocalizedString("%d precent", comment: "progress precentage value format")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareSubviews()
        
        // 투데이앱 접근성 검토에서 그 요소가 보조 기술이 접근할 수 있는 접근성 요소인지 여부를 나타냅니다. 표준 UIKit 컨트롤은 기본적으로 이 값을 활성화합니다.
        isAccessibilityElement = true
        accessibilityLabel = NSLocalizedString("Progress", comment: "Progress view accessibility")
        // UIAccessibilityTraits를 사용하여 접근성 요소가 어떻게 작동하는지 설명할 수 있습니다.
        // VoiceOver는 progress 뷰가 사용자에게 이 보기로 돌아가고 싶어할 수도 있다는 신호를 보내기 위해 자주 업데이트된다는 것을 읽습니다.
        accessibilityTraits.update(with: .updatesFrequently)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        accessibilityValue = String(format: valueFormat, Int(progress * 100.0))
        heightConstraint?.constant = progress * bounds.height
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.5 * containerView.bounds.width
    }
    
    private func prepareSubviews() {
        containerView.addSubview(upperView)
        containerView.addSubview(lowerView)
        addSubview(containerView)
        
        upperView.translatesAutoresizingMaskIntoConstraints = false
        lowerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85).isActive = true
        
        upperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        upperView.bottomAnchor.constraint(equalTo: lowerView.topAnchor).isActive = true
        lowerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        upperView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        upperView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lowerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lowerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        heightConstraint = lowerView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        upperView.backgroundColor = .todayProgressUpperBackground
        lowerView.backgroundColor = .todayProgressLowerBackground
    }
}
