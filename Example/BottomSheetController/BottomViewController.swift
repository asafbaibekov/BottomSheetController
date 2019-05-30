//
//  BottomViewController.swift
//  BottomSheetController_Example
//
//  Created by Asaf Baibekov on 30/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class BottomViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!

	override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
		roundCorners(view, corners: [.topLeft, .topRight], radius: 12)
		self.tableView.register(DefualtCell.self, forCellReuseIdentifier: "cell")
		self.tableView.dataSource = self
    }


	func roundCorners(_ view: UIView, corners: UIRectCorner, radius: CGFloat? = nil) {
		view.layer.mask = {
			let mask = CAShapeLayer()
			mask.path = UIBezierPath(
				roundedRect: view.bounds,
				byRoundingCorners: corners,
				cornerRadii: CGSize(
					width: radius != nil ? radius! : min(view.bounds.width/2, view.bounds.height/2),
					height: radius != nil ? radius! : min(view.bounds.width/2, view.bounds.height/2)
				)
			).cgPath
			view.layer.mask?.removeFromSuperlayer()
			return mask
		}()
	}

}

extension BottomViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 50
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = "Cell \(indexPath.row + 1)"
		return cell
	}
}

class DefualtCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
