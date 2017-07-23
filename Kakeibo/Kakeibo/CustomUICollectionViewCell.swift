//
//  CustomUICollectionViewCell.swift
//  Kakeibo
//
//  Created by 関澤春香 on 2017/07/20.
//  Copyright © 2017年 Wittgenstein. All rights reserved.
//

import UIKit

class CustomUICollectionViewCell: UICollectionViewCell {
    var textLabel : UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
        
        //UILabelを生成
        textLabel = UILabel(frame: CGRect(x:0, y:0, width:self.frame.width,  height: self.frame.height))
        textLabel.font = UIFont(name: "HiraKakuProN-W3", size: 12)
        textLabel.textAlignment = NSTextAlignment.center
        //無制限行表示
        textLabel.numberOfLines = 0
        
        // Cellに追加
        self.addSubview(textLabel!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
}
