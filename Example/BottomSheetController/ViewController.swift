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
	var initialY: CGFloat {
		return UIScreen.main.bounds.height / 2
	}
	
	var minYBound: CGFloat {
		return 0
	}
	
	var maxYBound: CGFloat {
		return UIScreen.main.bounds.height - 150
	}
	
	var scrollableView: UIScrollView? {
		return self.bottomViewController!.tableView
	}

	var disableBackground: Bool {
		return true
	}

	func nextY(from currentY: CGFloat,
			   panDirection direction: BottomSheetPanDirection) -> CGFloat {
		let screenMidY = UIScreen.main.bounds.height / 2
		switch direction {
		case .up: return currentY < screenMidY ? minYBound : screenMidY
		case .down: return currentY > screenMidY ? maxYBound : screenMidY
		}
	}
}
