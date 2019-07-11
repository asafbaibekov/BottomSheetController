//
//  ViewController.swift
//  BottomSheetController
//
//  Created by asafbaibekov on 05/30/2019.
//  Copyright (c) 2019 asafbaibekov. All rights reserved.
//

import UIKit
import BottomSheetController

class ViewController: UIViewController {

	var bottomViewController: BottomViewController!
	var bottomSheetController: BottomSheetController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		self.bottomViewController = BottomViewController(
			nibName: "BottomViewController",
			bundle: nil
		)
		self.bottomSheetController = BottomSheetController(
			main: self,
			sheet: bottomViewController,
			configuration: self
		)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: BottomSheetConfiguration {
	func initialY(bottomSheetController: BottomSheetController) -> CGFloat {
		return UIScreen.main.bounds.height / 2
	}
	func minYBound(bottomSheetController: BottomSheetController) -> CGFloat {
		return 0
	}
	func maxYBound(bottomSheetController: BottomSheetController) -> CGFloat {
		return UIScreen.main.bounds.height - 150
	}
	func scrollableView(bottomSheetController: BottomSheetController) -> UIScrollView? {
		return self.bottomViewController!.tableView
	}
	func disableBackground(bottomSheetController: BottomSheetController) -> Bool {
		return true
	}
	func maxAlphaBackground(bottomSheetController: BottomSheetController) -> CGFloat {
		return 0.5
	}
	func nextY(bottomSheetController: BottomSheetController, from currentY: CGFloat, panDirection direction: BottomSheetPanDirection) -> CGFloat {
		let screenMidY = UIScreen.main.bounds.height / 2
		switch direction {
		case .up: return currentY < screenMidY ? minYBound(bottomSheetController: bottomSheetController) : screenMidY
		case .down: return currentY > screenMidY ? maxYBound(bottomSheetController: bottomSheetController) : screenMidY
		}
	}
}
