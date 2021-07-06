//
//  ComprasTableViewCell.swift
//  traz-ae
//
//  Created by Abner Thiago da Silva Guimarães on 04/07/21.
//

import UIKit

protocol OptionButtonsDelegate{
    func btnTapped(at index: IndexPath)
}

class ComprasTableViewCell: UITableViewCell {

    @IBOutlet weak var lblItem:    UILabel!
    @IBOutlet weak var btnCheck:   UIButton!
    @IBOutlet weak var btnChecked: UIButton!
    
    var delegate:  OptionButtonsDelegate!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

    @IBAction func desChecar(_ sender: Any) {
        btnChecked.isHidden = true;
        btnCheck.isHidden   = false;
        lblItem.isEnabled   = true;
        self.delegate?.btnTapped(at : indexPath);
    }
    
    @IBAction func checar(_ sender: Any) {
        btnChecked.isHidden = false;
        btnCheck.isHidden   = true;
        lblItem.isEnabled   = false;
        self.delegate?.btnTapped(at: indexPath);
    }
    
}
