//
//  BottomSheetBehavior.swift
//  Pods-BottomSheetController_Example
//
//  Created by Asaf Baibekov on 30/05/2019.
//

import UIKit

internal class BottomSheetBehavior: UIDynamicBehavior {
	let item: UIDynamicItem
	let itemBehavior: UIDynamicItemBehavior
	let attachmentBehavior: UIAttachmentBehavior
	
	init(item dynamicItem: UIDynamicItem,
		 targetPoint: CGPoint,
		 velocity: CGPoint,
		 onAnimationStep: ((_ minY: CGFloat) -> Void)? = nil) {
		item = dynamicItem
		itemBehavior = UIDynamicItemBehavior(items: [item])
		attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: .zero)
		super.init()
		action = {
			guard let view = self.item as? UIView else { return }
			view.frame.size = CGSize(
				width: UIScreen.main.bounds.width,
				height: UIScreen.main.bounds.height - view.frame.minY
			)
			view.layoutIfNeeded()
			onAnimationStep?(view.frame.minY)
		}
		attachmentBehavior.frequency = 3.5
		attachmentBehavior.damping = 0.4
		attachmentBehavior.length = 0
		itemBehavior.density = 100
		itemBehavior.resistance = 10
		attachmentBehavior.anchorPoint = targetPoint
		itemBehavior.addLinearVelocity(
			CGPoint(
				x: velocity.x - itemBehavior.linearVelocity(for: item).x,
				y: velocity.y - itemBehavior.linearVelocity(for: item).y
			),
			for: item
		)
		addChildBehavior(attachmentBehavior)
		addChildBehavior(itemBehavior)
	}
}
