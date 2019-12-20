//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit
import BottomSheet

final class DemoViewController: UIViewController {
    private lazy var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(
        contentHeights: [.bottomSheetAutomatic, UIScreen.main.bounds.size.height - 200]
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        view.backgroundColor = .white

        let buttonA = UIButton(type: .system)
        buttonA.setTitle("Navigation View Controller", for: .normal)
        buttonA.titleLabel?.font = .systemFont(ofSize: 18)
        buttonA.addTarget(self, action: #selector(presentNavigationViewController), for: .touchUpInside)

        let buttonB = UIButton(type: .system)
        buttonB.setTitle("View Controller", for: .normal)
        buttonB.titleLabel?.font = .systemFont(ofSize: 18)
        buttonB.addTarget(self, action: #selector(presentViewController), for: .touchUpInside)

        let buttonC = UIButton(type: .system)
        buttonC.setTitle("View", for: .normal)
        buttonC.titleLabel?.font = .systemFont(ofSize: 18)
        buttonC.addTarget(self, action: #selector(presentView), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [buttonA, buttonB, buttonC])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Presentation logic

    @objc private func presentNavigationViewController() {
        let viewController = ViewController(withNavigationButton: true, contentHeight: 400)
        viewController.title = "Step 1"

        let navigationController = BottomSheetNavigationController(rootViewController: viewController)
        navigationController.navigationBar.isTranslucent = false

        present(navigationController, animated: true)
    }

    // MARK: - Presentation logic

    @objc private func presentViewController() {
        let viewController = ViewController(withNavigationButton: false, text: "UIViewController", contentHeight: 400)
        viewController.transitioningDelegate = bottomSheetTransitioningDelegate
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true)
    }

    @objc private func presentView() {
        let bottomSheetView = BottomSheetView(
            contentView: UIView.makeView(withTitle: "UIView"),
            contentHeights: [100, 500]
        )
        bottomSheetView.present(in: view)
    }
}

// MARK: - Private extensions

private extension UIView {
    static func makeView(withTitle title: String? = nil) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hue: 0.5, saturation: 0.3, brightness: 0.6, alpha: 1.0)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        label.textColor = .white
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        return view
    }
}

private final class ViewController: UIViewController {
    private let withNavigationButton: Bool
    private let contentHeight: CGFloat
    private let text: String?

    init(withNavigationButton: Bool, text: String? = nil, contentHeight: CGFloat) {
        self.withNavigationButton = withNavigationButton
        self.text = text
        self.contentHeight = contentHeight
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let contentView = UIView.makeView(withTitle: text)
        view.backgroundColor = contentView.backgroundColor
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: contentHeight),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if withNavigationButton {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.setTitle("Next", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
            view.addSubview(button)

            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }

    @objc private func handleButtonTap() {
        let viewController = ViewController(withNavigationButton: false, contentHeight: contentHeight - 100)
        viewController.title = "Step 2"
        navigationController?.pushViewController(viewController, animated: true)
    }
}
