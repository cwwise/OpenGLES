//
//  ViewController.swift
//  OpenGLES01-环境搭建
//
//  Created by chenwei on 2021/3/28.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        self.view = OpenGLESView(frame: UIScreen.main.bounds)
    }


}

