//
//  ViewController.swift
//  OpenGLES04-VAOVBO
//
//  Created by chenwei on 2021/3/29.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func loadView() {
        self.view = OpenGLESView(frame: UIScreen.main.bounds)
    }

}

