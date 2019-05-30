//
//  BottomSheetController.swift
//  Pods-BottomSheetController_Example
//
//  Created by Asaf Baibekov on 30/05/2019.
//

import UIKit

public extension UIViewController {
	func addBottomSheet(_ bottomSheetController: BottomSheetController) {
		self.addChild(bottomSheetController)
		self.view.addSubview(bottomSheetController.view)
		bottomSheetController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		bottomSheetController.didMove(toParent: self)
	}
}

@objc
public enum BottomSheetPanDirection: Int {
	case up, down
}

@objc
public protocol BottomSheetControllerDelegate {
	@objc optional func bottomSheet(bottomSheetController: BottomSheetController, viewController: UIViewController, willMoveTo minY: CGFloat, direction: BottomSheetPanDirection)
	
	@objc optional func bottomSheet(bottomSheetController: BottomSheetController, viewController: UIViewController, didMoveTo minY: CGFloat, direction: BottomSheetPanDirection)
	
	@objc optional func bottomSheet(bottomSheetController: BottomSheetController, viewController: UIViewController, animationWillStart targetY: CGFloat, direction: BottomSheetPanDirection)
	
	@objc optional func bottomSheetAnimationDidStart(bottomSheetController: BottomSheetController, viewController: UIViewController)
	
	@objc optional func bottomSheetAnimationDidEnd(bottomSheetController: BottomSheetController, viewController: UIViewController)
}

public class BottomSheetController: UIViewController {
	// MARK: Properties
	public weak var delegate: BottomSheetControllerDelegate?
	
	private var sheetViewController: UIViewController!
	private var config: BottomSheetConfiguration!
	
	private var sheetAnimator: UIDynamicAnimator!
	private var panGesture: UIPanGestureRecognizer!
	private var allowsContentScrolling: Bool!
	// MARK: Initializers
	private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
		sheetAnimator = UIDynamicAnimator(referenceView: view)
		panGesture.delegate = self
		sheetAnimator.delegate = self
	}
	internal required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: Initializers
public extension BottomSheetController {
	convenience init(sheet sheetViewController: UIViewController,
					 configuration config: BottomSheetConfiguration) {
		self.init()
		self.sheetViewController = sheetViewController
		self.config = config
		self.prepareSheetForPresentation()
	}
	convenience init(main mainViewController: UIViewController,
					 sheet sheetViewController: UIViewController,
					 configuration config: BottomSheetConfiguration) {
		self.init(sheet: sheetViewController, configuration: config)
		mainViewController.addChild(self)
		mainViewController.view.addSubview(self.view)
		self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.didMove(toParent: mainViewController)
	}
}

// MARK: Public Methods
public extension BottomSheetController {
	override func addChild(_ childController: UIViewController) {
		super.addChild(childController)
		view.addSubview(childController.view)
		childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		childController.didMove(toParent: self)
		config?.scrollableView?.panGestureRecognizer.require(toFail: panGesture)
	}
	func expand() {
		sheetAnimator.removeAllBehaviors()
		moveSheet(to: config.minYBound)
	}
	func collapse() {
		sheetAnimator.removeAllBehaviors()
		moveSheet(to: config.maxYBound)
	}
}

// MARK: - Private Methods
private extension BottomSheetController {
	func prepareSheetForPresentation() {
		addChild(sheetViewController)
		sheetViewController.view.frame.origin = CGPoint(x: 0, y: config.initialY)
		sheetViewController.view.frame.size = CGSize(
			width: UIScreen.main.bounds.width,
			height: UIScreen.main.bounds.height - sheetViewController.view.frame.minY
		)
		sheetViewController.view.addGestureRecognizer(panGesture)
		self.allowsContentScrolling = config.initialY == config.minYBound
	}
	func translateSheetView(with translation: CGPoint) {
		sheetViewController.view.frame.origin = CGPoint(
			x: sheetViewController.view.frame.origin.x + translation.x,
			y: sheetViewController.view.frame.origin.y + translation.y
		)
		sheetViewController.view.frame.size = CGSize(
			width: UIScreen.main.bounds.width,
			height: UIScreen.main.bounds.height - sheetViewController.view.frame.minY
		)
		sheetViewController.view.layoutIfNeeded()
	}
	func moveSheet(to y: CGFloat, velocity: CGPoint = .zero) {
		self.allowsContentScrolling = y == config.minYBound
		let currentY = sheetViewController.view.frame.minY
		let direction: BottomSheetPanDirection = y >= currentY ? .down : .up
		let finalHeight = UIScreen.main.bounds.height - y
		let anchorY = y + finalHeight/2
		let targetPoint = CGPoint(x: view.center.x, y: anchorY)
		let behavior = BottomSheetBehavior(
			item: sheetViewController.view,
			targetPoint: targetPoint,
			velocity: velocity,
			onAnimationStep: { newY in
				self.delegate?.bottomSheet?(
					bottomSheetController: self,
					viewController: self.sheetViewController,
					didMoveTo: newY,
					direction: direction
				)
			}
		)
		delegate?.bottomSheet?(
			bottomSheetController: self,
			viewController: sheetViewController,
			animationWillStart: y,
			direction: direction
		)
		sheetAnimator.addBehavior(behavior)
	}
}

// MARK: - Pan Gestures
private extension BottomSheetController {
	@objc func panGestureHandler(_ recognizer: UIPanGestureRecognizer) {
		var translation = recognizer.translation(in: view)
		var velocity = recognizer.velocity(in: view)
		velocity.x = 0
		let direction: BottomSheetPanDirection = velocity.y < 0 ? .up : .down
		let newY = sheetViewController.view.frame.minY + translation.y
		if config.canMoveTo(newY) {
			delegate?.bottomSheet?(
				bottomSheetController: self,
				viewController: sheetViewController,
				willMoveTo: newY,
				direction: direction
			)
			translation.x = 0
			translateSheetView(with: translation)
			delegate?.bottomSheet?(
				bottomSheetController: self,
				viewController: sheetViewController,
				didMoveTo: newY,
				direction: direction
			)
		}
		recognizer.setTranslation(.zero, in: sheetViewController.view)
		switch recognizer.state {
		case .began: sheetAnimator.removeAllBehaviors()
		case .ended:
			let targetY = config.nextY(from: sheetViewController.view.frame.minY, panDirection: direction)
			moveSheet(to: targetY, velocity: velocity)
		default: break
		}
	}
}

extension BottomSheetController: UIGestureRecognizerDelegate {
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return false
	}
	public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard
			let scrollableView = config.scrollableView,
			let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
			scrollableView.frame.contains(panGesture.location(in: panGesture.view)) else { return true }
		let offsetY = scrollableView.contentOffset.y
		let isBouncing = offsetY < 0
		let isDragingDown = panGesture.velocity(in: panGesture.view).y >= 0
		return (isBouncing && isDragingDown) || (offsetY == 0 && isDragingDown) || !self.allowsContentScrolling
	}
}

extension BottomSheetController: UIDynamicAnimatorDelegate {
	public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
		delegate?.bottomSheetAnimationDidEnd?(
			bottomSheetController: self,
			viewController: sheetViewController!
		)
	}
	public func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
		delegate?.bottomSheetAnimationDidStart?(
			bottomSheetController: self,
			viewController: sheetViewController!
		)
	}
}
