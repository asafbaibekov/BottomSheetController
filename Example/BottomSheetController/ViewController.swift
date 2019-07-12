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

	var bottomSheetController: BottomSheetController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		self.bottomSheetController = BottomSheetController(main: self, sheet: BottomViewController(nibName: "BottomViewController", bundle: nil))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: BottomSheetConfiguration {
	func initialY(_ bottomSheetController: BottomSheetController) -> CGFloat {
		return UIScreen.main.bounds.height / 2
	}
	func minYBound(_ bottomSheetController: BottomSheetController) -> CGFloat {
		return 0
	}
	func maxYBound(_ bottomSheetController: BottomSheetController) -> CGFloat {
		return UIScreen.main.bounds.height - 150
	}
	func scrollableView(_ bottomSheetController: BottomSheetController) -> UIScrollView? {
		return (bottomSheetController.sheetViewController as? BottomViewController)?.tableView
	}
	func disableBackground(_ bottomSheetController: BottomSheetController) -> Bool {
		return true
	}
	func maxAlphaBackground(_ bottomSheetController: BottomSheetController) -> CGFloat {
		return 0.5
	}
	func nextY(_ bottomSheetController: BottomSheetController, from currentY: CGFloat, panDirection direction: BottomSheetPanDirection) -> CGFloat {
		let screenMidY = UIScreen.main.bounds.height / 2
		switch direction {
		case .up: return currentY < screenMidY ? minYBound(bottomSheetController) : screenMidY
		case .down: return currentY > screenMidY ? maxYBound(bottomSheetController) : screenMidY
		}
	}
}
