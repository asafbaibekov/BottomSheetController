//
//  BottomSheetConfiguration.swift
//  Pods-BottomSheetController_Example
//
//  Created by Asaf Baibekov on 30/05/2019.
//

import UIKit

public protocol BottomSheetConfiguration: class {
	func initialY(_ bottomSheetController: BottomSheetController) -> CGFloat
	func minYBound(_ bottomSheetController: BottomSheetController) -> CGFloat
	func maxYBound(_ bottomSheetController: BottomSheetController) -> CGFloat
	func scrollableView(_ bottomSheetController: BottomSheetController) -> UIScrollView?
	func disableBackground(_ bottomSheetController: BottomSheetController) -> Bool
	func maxAlphaBackground(_ bottomSheetController: BottomSheetController) -> CGFloat
	func nextY(_ bottomSheetController: BottomSheetController, from currentY: CGFloat, panDirection direction: BottomSheetPanDirection) -> CGFloat
}
