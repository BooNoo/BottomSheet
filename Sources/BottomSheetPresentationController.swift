//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension BottomSheetPresentationController {
    enum TransitionState {
        case presenting
        case dismissing
    }
}

final class BottomSheetPresentationController: UIPresentationController {

    // MARK: - Internal properties

    var transitionState: TransitionState?

    // MARK: - Private properties

    private var contentHeights: [CGFloat]
    private let startTargetIndex: Int
    private let useSafeAreaInsets: Bool
    private var dismissVelocity: CGPoint = .zero
    private var bottomSheetView: BottomSheetView?
    private weak var transitionContext: UIViewControllerContextTransitioning?

    // MARK: - Init

    init(
        presentedViewController: UIViewController,
        presenting: UIViewController?,
        contentHeights: [CGFloat],
        startTargetIndex: Int,
        useSafeAreaInsets: Bool
    ) {
        self.contentHeights = contentHeights
        self.startTargetIndex = startTargetIndex
        self.useSafeAreaInsets = useSafeAreaInsets
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    // MARK: - Internal

    public func reset() {
        bottomSheetView?.reset()
    }

    public func reload(with contentHeights: [CGFloat]) {
        self.contentHeights = contentHeights
        bottomSheetView?.reload(with: contentHeights)
    }

    // MARK: - Transition life cycle

    override func presentationTransitionWillBegin() {
        guard transitionState == .presenting else { return }
        createBottomSheetView()
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        guard transitionState == nil else { return }
        guard let containerView = containerView else { return }

        createBottomSheetView()

        bottomSheetView?.present(
            in: containerView,
            targetIndex: startTargetIndex,
            animated: false
        )
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let presentedView = presentedView else { return .zero }
        guard let containerView = containerView else { return .zero }

        let contentHeight = BottomSheetCalculator.contentHeight(
            for: presentedView,
            in: containerView,
            height: contentHeights[startTargetIndex],
            useSafeAreaInsets: useSafeAreaInsets
        )

        let size = CGSize(
            width: containerView.frame.width,
            height: contentHeight
        )

        return CGRect(
            origin: .zero,
            size: size
        )
    }

    private func createBottomSheetView() {
        guard let presentedView = presentedView else { return }

        bottomSheetView = BottomSheetView(
            contentView: presentedView,
            contentHeights: contentHeights,
            useSafeAreaInsets: useSafeAreaInsets,
            isDismissible: true
        )

        bottomSheetView?.delegate = self
        bottomSheetView?.isDimViewHidden = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.bottomSheetView?.reset() }, completion: nil)
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension BottomSheetPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        let completion = { [weak self] (didComplete: Bool) in
            self?.transitionContext?.completeTransition(didComplete)
            self?.transitionState = nil
        }

        switch transitionState {
        case .presenting:
            bottomSheetView?.present(
                in: transitionContext.containerView,
                targetIndex: startTargetIndex,
                completion: completion
            )
        case .dismissing:
            bottomSheetView?.dismiss(
                velocity: dismissVelocity,
                completion: completion
            )

        case .none:
            return
        }
    }
}

// MARK: - UIViewControllerInteractiveTransitioning

extension BottomSheetPresentationController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        animateTransition(using: transitionContext)
    }
}

// MARK: - BottomSheetViewPresenterDelegate

extension BottomSheetPresentationController: BottomSheetViewDelegate {
    func bottomSheetViewDidTapDimView(_ view: BottomSheetView) {
        dismiss(with: .zero)
    }

    func bottomSheetViewDidReachDismissArea(_ view: BottomSheetView, with velocity: CGPoint) {
        dismiss(with: velocity)
    }

    private func dismiss(with velocity: CGPoint) {
        switch transitionState {
        case .presenting:
            bottomSheetView?.dismiss(velocity: velocity, completion: { _ in
                self.transitionContext?.completeTransition(false)
            })
        case .dismissing:
            return
        case .none:
            dismissVelocity = velocity
            presentedViewController.dismiss(animated: true)
        }
    }
}
