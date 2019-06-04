//
//  BottomSheetController.swift
//  Pods-BottomSheetController_Example
//
//  Created by Asaf Baibekov on 30/05/2019.
//

import UIKit

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

public class BottomSheetController: NSObject {
	// MARK: Properties
	public weak var delegate: BottomSheetControllerDelegate?
	
	private var mainViewController: UIViewController!
	public var sheetViewController: UIViewController! {
		didSet {
			animator.removeAllBehaviors()
			UIView.animate(
				withDuration: 0.25,
				animations: {
					oldValue.view.frame.origin.y = UIScreen.main.bounds.height
				},
				completion: { completed in
					guard completed else { return }
					oldValue.willMove(toParent: nil)
					oldValue.view.removeFromSuperview()
					oldValue.removeFromParent()
					self.prepareSheetForPresentation()
					self.sheetViewController.view.frame.origin.y = UIScreen.main.bounds.height
					UIView.animate(
						withDuration: 0.25,
						animations: {
							self.sheetViewController.view.frame.origin.y = self.config.initialY
						}
					)
				}
			)
		}
	}
	private var config: BottomSheetConfiguration!
	
	private lazy var animator: UIDynamicAnimator = {
		let animator = UIDynamicAnimator(referenceView: mainViewController.view)
		animator.delegate = self
		return animator
	}()
	private lazy var panGesture: UIPanGestureRecognizer = {
		let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
		pan.delegate = self
		return pan
	}()
	private var allowsContentScrolling: Bool!
	
	public init(main mainViewController: UIViewController,
				sheet sheetViewController: UIViewController,
				configuration config: BottomSheetConfiguration) {
		super.init()
		self.mainViewController = mainViewController
		self.sheetViewController = sheetViewController
		self.config = config
		self.prepareSheetForPresentation()
	}
}

// MARK: Public Methods
public extension BottomSheetController {
	func expand() {
		moveSheet(to: config.minYBound)
	}
	func collapse() {
		moveSheet(to: config.maxYBound)
	}
}

// MARK: - Private Methods
private extension BottomSheetController {
	func prepareSheetForPresentation() {
		mainViewController.addChild(sheetViewController)
		mainViewController.view.addSubview(sheetViewController.view)
		sheetViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		sheetViewController.didMove(toParent: mainViewController)
		config.scrollableView?.panGestureRecognizer.require(toFail: panGesture)
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
		animator.removeAllBehaviors()
		var topPadding: CGFloat = 0
		if #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow {
			topPadding = window.safeAreaInsets.top
		}
		self.allowsContentScrolling = y == config.minYBound
		let currentY = sheetViewController.view.frame.minY
		let direction: BottomSheetPanDirection = y >= currentY ? .down : .up
		let finalY = 0...topPadding ~= y ? y + topPadding : y
		let behavior = BottomSheetBehavior(item: sheetViewController.view, to: finalY, with: velocity)
		behavior.action = {
			let view = self.sheetViewController.view!
			view.frame.size = CGSize(width: UIScreen.main.bounds.width,
									 height: UIScreen.main.bounds.height - ceil(view.frame.minY))
			view.layoutIfNeeded()
			self.delegate?.bottomSheet?(
				bottomSheetController: self,
				viewController: self.sheetViewController,
				didMoveTo: view.frame.minY,
				direction: direction
			)
		}
		delegate?.bottomSheet?(
			bottomSheetController: self,
			viewController: sheetViewController,
			animationWillStart: y,
			direction: direction
		)
		animator.addBehavior(behavior)
	}
}

// MARK: - Pan Gestures
private extension BottomSheetController {
	@objc func panGestureHandler(_ recognizer: UIPanGestureRecognizer) {
		var translation = recognizer.translation(in: mainViewController.view)
		var velocity = recognizer.velocity(in: mainViewController.view)
		velocity.x = 0
		let direction: BottomSheetPanDirection = velocity.y < 0 ? .up : .down
		let newY = sheetViewController.view.frame.minY + translation.y
		if newY >= config.minYBound && newY <= config.maxYBound {
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
		case .began: animator.removeAllBehaviors()
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
