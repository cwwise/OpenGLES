//
//  ViewController.swift
//  OpenGLES03-圆形绘制
//
//  Created by chenwei on 2021/3/28.
//

import UIKit

class ViewController: UIViewController {

    override func loadView() {
        self.view = OpenGLESView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

