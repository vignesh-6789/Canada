//
//  CanadaTableViewCell.swift
//  Canada
//
//  Created by Vignesh on 15/05/20.
//  Copyright © 2020 Vignesh. All rights reserved.
//

import UIKit

class CanadaTableViewCell : UITableViewCell {
    
    var canadaItem : CanadaItem? {
        didSet {
            rowNameLabel.text = canadaItem?.factName
            rowDescriptionLabel.text = canadaItem?.factDesc
        }
    }
    
    //Fact Name
    private let rowNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    //Fact Description
    private let rowDescriptionLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    //Fact Image
    private let rowImage : UIImageView = {
        let imgView = UIImageView(image: UIImage(named:Constants.DefaultImageName))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    func setRowImage(image:UIImage) {
        DispatchQueue.main.async {
            self.rowImage.image = image
        }
    }
    
    
    // Indicator to show the fact image download inprogress 
    private let rowImageIndicator : UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .medium)
        return activityView
    }()
    
    func startAnimating() {
        DispatchQueue.main.async {
            self.rowImageIndicator.startAnimating()
        }
    }
    
    func stopAnimating() {
        DispatchQueue.main.async {
            self.rowImageIndicator.stopAnimating()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add all the UI Component as a cell subview
        addSubview(rowImage)
        addSubview(rowNameLabel)
        addSubview(rowDescriptionLabel)
        addSubview(rowImageIndicator)
        
        rowImage.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 45, height: 45, enableInsets: false)
        rowNameLabel.anchor(top: topAnchor, left: rowImage.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        rowDescriptionLabel.anchor(top: rowNameLabel.bottomAnchor, left: rowImage.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        rowDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 25).isActive = true
        rowImageIndicator.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 45, height: 45, enableInsets: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
