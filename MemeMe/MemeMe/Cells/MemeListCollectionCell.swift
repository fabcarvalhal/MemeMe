//
//  MemeListCollectionCell.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 24/04/21.
//

import UIKit

class MemeListCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var memeImageView: UIImageView!
    
    func configure(with meme: Meme) {
        memeImageView.image = meme.memedImage
    }
    
    override func prepareForReuse() {
        memeImageView.image = nil
    }
}
