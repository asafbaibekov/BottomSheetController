//
//  BottomSheetConfiguration.swift
//  Pods-BottomSheetController_Example
//
//  Created by Asaf Baibekov on 30/05/2019.
//

import UIKit

public protocol BottomSheetConfiguration: class {
	func initialY(bottomSheetController: BottomSheetController) -> CGFloat
	func minYBound(bottomSheetController: BottomSheetController) -> CGFloat
	func maxYBound(bottomSheetController: BottomSheetController) -> CGFloat
	func scrollableView(bottomSheetController: BottomSheetController) -> UIScrollView?
	func disableBackground(bottomSheetController: BottomSheetController) -> Bool
	func maxAlphaBackground(bottomSheetController: BottomSheetController) -> CGFloat
	func nextY(bottomSheetController: BottomSheetController, from currentY: CGFloat, panDirection direction: BottomSheetPanDirection) -> CGFloat
}
