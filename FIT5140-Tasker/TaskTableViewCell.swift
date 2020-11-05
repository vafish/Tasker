//
//  TaskTableViewCell.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/4/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskNameTextField: UILabel!
    @IBOutlet weak var dueDateTextField: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
