//
//  CollectionViewCell.swift
//  Categories
//
//  Created by Apple on 01/04/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.layer.cornerRadius = view.frame.size.width / 2
                view.clipsToBounds = true
    }

}
