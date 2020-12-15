//
//  TaskCellTableViewCell.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/08.
//

import UIKit

class TaskCellTableViewCell: UITableViewCell {

    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() { //viewDidLoadと同じ
        super.awakeFromNib()
        checkImageView.layer.cornerRadius = 22.5
        backView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
