//
//  PhotosetRowTableViewCell.swift
//  Highball
//
//  Created by Ian Ynda-Hummel on 8/27/14.
//  Copyright (c) 2014 ianynda. All rights reserved.
//

import UIKit
import Cartography

class PhotosetRowTableViewCell: UITableViewCell {

    var imageViews: Array<UIImageView>?
    var images: Array<PostPhoto>? {
        didSet {
            if let images = self.images {
                if let imageViews = self.imageViews {
                    for imageView in imageViews {
                        imageView.cancelImageRequestOperation()
                        imageView.image = nil
                        imageView.removeFromSuperview()
                    }
                }

                let widthRatio: Float = 1.0 / Float(images.count)
                var imageViews = Array<UIImageView>()
                var lastImageView: UIImageView?
                for image in images {
                    let imageView = UIImageView()
                    let imageURL = image.url()

                    self.contentView.addSubview(imageView)

                    if let leftImageView = lastImageView {
                        layout(imageView, leftImageView) { view, leftView in
                            view.left == leftView.right
                            view.height == leftView.height
                            view.centerY == leftView.centerY
                            view.width == leftView.width
                        }
                    } else {
                        layout(imageView, self.contentView) { view, contentView in
                            view.left == contentView.left
                            view.top == contentView.top
                            view.bottom == contentView.bottom
                            view.width == (contentView.width * widthRatio)
                        }
                    }

                    imageView.cancelImageRequestOperation()
                    imageView.setImageWithURL(imageURL, placeholderImage: UIImage(named: "Placeholder"))

                    lastImageView = imageView
                }

                self.imageViews = imageViews
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        if let imageViews = self.imageViews {
            for imageView in imageViews {
                imageView.cancelImageRequestOperation()
                imageView.image = nil
                imageView.removeFromSuperview()
            }
        }
    }
}