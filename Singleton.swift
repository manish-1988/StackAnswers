//
//  Singleton.swift
//  HealthNote
//
//  Created by MANISH_iOS on 27/07/16.
//  Copyright © 2016 iDev. All rights reserved.
//

import UIKit
import Foundation



class Singleton: NSObject
{
    static let sharedInstance = Singleton()
    
    override init()
    {
        super.init()
    }
    
    
    func placeBlockerView(target : UIViewController)
    {
        var loadView:UIView!
        loadView = UIView(frame: target.view.frame)
        loadView!.backgroundColor = UIColor.black
        loadView!.alpha = 1.0
        
        let actView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        actView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        actView.center = CGPoint(x: target.view.bounds.size.width / 2 , y: target.view.bounds.size.height / 2 )
        actView.startAnimating()
        
        loadView?.addSubview(actView)
        target.view.addSubview(loadView!)
    }
}
