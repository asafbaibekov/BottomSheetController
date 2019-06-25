//
//  BottomSheetConfiguration.swift
//  Pods-BottomSheetController_Example
//
//  Created by Asaf Baibekov on 30/05/2019.
//

import UIKit

public protocol BottomSheetConfiguration: class {
	var initialY: CGFloat { get }
	var minYBound: CGFloat { get }
	var maxYBound: CGFloat { get }
	var scrollableView: UIScrollView? { get }
	// MARK: - Methods
	func nextY(from currentY: CGFloat,
			   panDirection direction: BottomSheetPanDirection) -> CGFloat
}
