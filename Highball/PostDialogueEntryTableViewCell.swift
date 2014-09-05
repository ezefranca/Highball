//
//  PostDialogueEntryTableViewCell.swift
//  Highball
//
//  Created by Ian Ynda-Hummel on 8/31/14.
//  Copyright (c) 2014 ianynda. All rights reserved.
//

import UIKit

class PostDialogueEntryTableViewCell: UITableViewCell {

    var contentLabel: UILabel!

    var dialogueEntry: PostDialogueEntry? {
        didSet {
            if let dialogueEntry = self.dialogueEntry {
                self.contentLabel.attributedText = dialogueEntry.formattedString()
            }
        }
    }

    override required init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpCell()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpCell()
    }

    func setUpCell() {
        self.contentLabel = UILabel()

        self.contentLabel.numberOfLines = 0

        self.contentView.addSubview(self.contentLabel)

        self.contentLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.contentView.snp_left).offset(20)
            make.right.equalTo(self.contentView.snp_right).offset(-20)
            make.top.equalTo(self.contentView.snp_top).offset(3)
        }
    }

    class func heightForPostDialogueEntry(post: PostDialogueEntry!, width: CGFloat!) -> CGFloat {
        let extraHeight: CGFloat = 3 + 3
        let modifiedWidth = width - 20 - 20
        let constrainedSize = CGSize(width: modifiedWidth, height: CGFloat.max)
        let content = post.formattedString()
        let contentRect = content.boundingRectWithSize(constrainedSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)

        return extraHeight + ceil(contentRect.size.height)
    }

}
