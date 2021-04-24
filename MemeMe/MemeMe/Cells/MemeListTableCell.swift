//
//  MemeListTableCell.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 24/04/21.
//

import UIKit

class MemeListTableCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var memImageView: UIImageView!
    
    func configure(with meme: Meme) {
        titleLabel.text = "\(meme.topText ?? "")...\(meme.bottomText ?? "")"
        imageView?.image = meme.memedImage
    }
    
    override func prepareForReuse() {
        memImageView.image = nil
    }
}
