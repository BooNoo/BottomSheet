//
//  Copyright © FINN.no AS. All rights reserved.
//

import UIKit

protocol HandleViewDelegate: AnyObject {
    func didPerformAccessibilityActivate(_ view: HandleView) -> Bool
}

class HandleView: UIView {
    
    private lazy var handle: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .handle
        view.layer.cornerRadius = 2
        return view
    }()
    
    weak var delegate: HandleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(handle)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "handle_view_accessibility_label".localized()
        NSLayoutConstraint.activate([
            handle.centerXAnchor.constraint(equalTo: centerXAnchor),
            handle.widthAnchor.constraint(equalToConstant: 25),
            handle.heightAnchor.constraint(equalToConstant: 4)
        ])
        
    }
    
    override func accessibilityActivate() -> Bool {
        delegate?.didPerformAccessibilityActivate(self) ?? false
    }
}
