//
//  UIProposalCell.swift
//  
//
//  Created by Gregor Anzer on 24.01.18.
//

import UIKit

class UIProposalCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var lableP: UILabel!
    @IBOutlet weak var textP: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
