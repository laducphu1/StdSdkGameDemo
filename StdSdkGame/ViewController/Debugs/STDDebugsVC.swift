//
//  STDDebugsVC.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit

class STDDebugsVC: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var debugsTextView: UITextView!
    
    var debugsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugsTextView.text = STDAppDataSingleton.sharedInstance.debugsString;
        registerObserversNotification()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    private func registerObserversNotification() {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDebugs:) name:@"Debugs Error" object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDebugs:) name:@"Debugs Response" object:nil];
        NotificationCenter.default.addObserver(self, selector: #selector(didGetDebugs), name: NSNotification.Name(rawValue: "Debugs Error"), object: nil)
    }
    
    @objc func didGetDebugs(notification: Notification) {
        
        guard let debugsString = notification.object as? String else {return}
        debugsArray.append(debugsString)
        STDAppDataSingleton.sharedInstance.debugsString = "\(STDAppDataSingleton.sharedInstance.debugsString)\n\(debugsString)"
        debugsTextView.text = STDAppDataSingleton.sharedInstance.debugsString
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
