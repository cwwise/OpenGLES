//
//  ViewController.swift
//  OpenGLES06-效果
//
//  Created by chenwei on 2021/4/24.
//

import UIKit

class ViewController: UIViewController {

    var displayLink: CADisplayLink?
    var startTimeInterval: Float = 0
    
    lazy var renderView: OpenGLESView = {
        let renderView = OpenGLESView(frame: CGRect(x: 0, y: 120,
                                                    width: self.view.bounds.size.width,
                                                    height: self.view.bounds.size.width))
        return renderView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(renderView)
        
        startFilter()
        // Do any additional setup after loading the view.
    }
    
    func startFilter() {
        if displayLink != nil {
            displayLink?.invalidate()
            displayLink = nil
        }
        startTimeInterval = 0
        displayLink = CADisplayLink(target: self, selector: #selector(renderAction))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        
        renderView.setupGLProgram(name: "Shake")
        renderView.setupVBO()
        renderView.setupTexure()
    }

    @objc
    func renderAction() {
        guard let displayLink = displayLink else {
            return
        }
        if startTimeInterval == 0 {
            startTimeInterval = Float(displayLink.timestamp)
        }
        
        let currentTime = Float(displayLink.timestamp) - startTimeInterval
        let time = glGetUniformLocation(renderView.program, "Time")
        glUniform1f(time, GLfloat(currentTime))
        
        renderView.render()
    }

}

