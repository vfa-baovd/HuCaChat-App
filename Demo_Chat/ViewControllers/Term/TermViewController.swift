//
//  TermViewController.swift
//  HuCaChat
//
//  Created by HungNV on 9/18/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

class TermViewController: BaseViewController {

    @IBOutlet weak var tvTerm: UITextView!
    @IBOutlet weak var btnClose: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "Term_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "Term_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        self.view.backgroundColor = Theme.shared.color_App()
        self.tvTerm.text = NSLocalizedString("h_term_content", "")
        btnClose.layer.cornerRadius = btnClose.frame.size.height / 2
        btnClose.clipsToBounds = true
    }
    
    @IBAction func actClose(_ sender: Any) {
        self.dismissViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
