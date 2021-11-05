//
//  Loader.swift
//  iOS_Practical_Test_Anamul
//
//  Created by Anamul Habib on 10/30/21.
//

import Foundation
import CoreGraphics
import QuartzCore
import UIKit

class Loader: UIView {
    
    fileprivate var isAnimating :Bool = false
    fileprivate var backgroundView : UIView!
    
    var isUsrInteractionEnable : Bool = false
    var defaultbgColor: UIColor = UIColor.clear
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    private static var instance : Loader!
    
    static let shared : Loader = {
        
        if instance == nil{
            instance = Loader()
        }
        
        return instance
    }()
    
    @objc fileprivate func destroyShardInstance(){
        Loader.instance = nil
    }
    
    func startAnimation(){
        let win = UIApplication.shared.keyWindow
        
        backgroundView = UIView()
        backgroundView.frame = (UIApplication.shared.keyWindow?.frame)!
        backgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.75)
        win?.addSubview(backgroundView)
        
        backgroundView.addSubview(activityIndicator)
        backgroundView.accessibilityIdentifier = "CustomLoader"
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSExtensionHostDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Loader.ResumeLoader), name: NSNotification.Name.NSExtensionHostDidBecomeActive, object: nil)
        
        self.layoutSubviews()
    }
    
    @objc fileprivate func ResumeLoader(){
        
        if isAnimating{
            self.stopAnimation()
            self.AnimationStart()
        }
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
        self.backgroundColor = defaultbgColor
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = isUsrInteractionEnable
        activityIndicator.center = backgroundView.center
        self.AnimationStart()
    }
    
    
    @objc fileprivate func AnimationStart(){
        
        if isAnimating{
            return
        }
        
        activityIndicator.startAnimating()
        
        self.isAnimating = true
        self.isHidden = false
    }
    
    
    func stopAnimation(){
        
        if !isAnimating{
            return
        }
        
        activityIndicator.stopAnimating()
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
        let winSubviews = UIApplication.shared.keyWindow?.subviews
        if (winSubviews?.count)! > 0
        {
            for viw in winSubviews!
            {
                if viw.accessibilityIdentifier == "CustomLoader"
                {
                    viw.removeFromSuperview()
                    //  break
                }
            }
        }
        
        layer.sublayers = nil
        
        isAnimating = false
        self.isHidden = true
        
        self.destroyShardInstance()
    }
}
