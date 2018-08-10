//
//  ChatUserListTableViewCell.swift
//  Amistos
//
//  Created by Amit on 03/07/18.
//  Copyright © 2018 chawtech solutions. All rights reserved.
//

import UIKit

class ChatUserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var MemberImageView: UIImageView!
    @IBOutlet weak var MemberNameLbl: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedImageView.isUserInteractionEnabled = false  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
