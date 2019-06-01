//
//  BottomSheetBehavior.swift
//  Pods-BottomSheetController_Example
//
//  Created by Asaf Baibekov on 30/05/2019.
//

import UIKit

internal class BottomSheetBehavior: UIDynamicBehavior {
	let item: UIDynamicItem
	let y: CGFloat
	let velocity: CGPoint

	lazy var itemBehavior: UIDynamicItemBehavior = {
		let itemBehavior = UIDynamicItemBehavior(items: [item])
		itemBehavior.density = 100
		itemBehavior.resistance = 10
		itemBehavior.addLinearVelocity(
			CGPoint(x: velocity.x - itemBehavior.linearVelocity(for: item).x,
					y: velocity.y - itemBehavior.linearVelocity(for: item).y),
			for: item
		)
		return itemBehavior
	}()

	lazy var attachmentBehavior: UIAttachmentBehavior = {
		let attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: .zero)
		attachmentBehavior.anchorPoint = CGPoint(
			x: item.center.x,
			y: y + (UIScreen.main.bounds.height - y) / 2
		)
		attachmentBehavior.frequency = 3.5
		attachmentBehavior.damping = 0.4
		attachmentBehavior.length = 0
		return attachmentBehavior
	}()

	init(item: UIDynamicItem, to y: CGFloat, with velocity: CGPoint) {
		self.item = item
		self.y = y
		self.velocity = velocity
		super.init()
		addChildBehavior(attachmentBehavior)
		addChildBehavior(itemBehavior)
	}
}
