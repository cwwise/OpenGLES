//
//  OpenGLESView.swift
//  OpenGLES01-环境搭建
//
//  Created by chenwei on 2021/3/28.
//

import UIKit
import OpenGLES

@available(*, deprecated)
class OpenGLESView: UIView {

    var eaglLayer: CAEAGLLayer {
        return self.layer as! CAEAGLLayer
    }

    var context: EAGLContext!
    var frameBuffer: GLuint = 0
    var colorRenderBuffer: GLuint = 0
    var program: GLuint = 0

    var vao: GLuint = 0
    var vertext: [Vertex] = []
    var vertCount: Int = 100

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayer()
        setupContext()
        setupGLProgram()
        setupVertexData()
        setupVAO()
    }

    override func layoutSubviews() {
        EAGLContext.setCurrent(context)

        self.destoryRenderAndFrameBuffer()
        self.setupFrameAndRenderBuffer()
        self.render()
    }


    func setupLayer() {
        self.eaglLayer.isOpaque = true
        self.eaglLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
    }

    func setupContext() {
        context = EAGLContext(api: .openGLES3)
        if !EAGLContext.setCurrent(context) {
            print("Failed to set current OpenGL context")
        }
    }

    func setupGLProgram() {
        guard let program = ShaderUtil.loadShader(vertexShaderName: "vert.vsh",
                                                  fragmentShaderName: "frag.fsh") else {
            return
        }
        self.program = program
    }

    func destoryRenderAndFrameBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &colorRenderBuffer)
        colorRenderBuffer = 0
    }

    func setupFrameAndRenderBuffer() {
        glGenRenderbuffers(1, &colorRenderBuffer);
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer);
        // 为 color renderbuffer 分配存储空间
        context.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)

        glGenFramebuffers(1, &frameBuffer);
        // 设置为当前 framebuffer
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer);
        // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  colorRenderBuffer)
    }

    struct Vertex {
        var x: GLfloat
        var y: GLfloat
        var z: GLfloat
        var r: GLfloat
        var g: GLfloat
        var b: GLfloat
    }

    func setupVAO() {

        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)

        var vbo: GLuint = 0
        glGenBuffers(1, &vbo);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo);
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<Vertex>.stride * vertCount),
                     vertext,
                     GLenum(GL_STATIC_DRAW))


        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), nil)

        let colors = UnsafePointer<GLfloat>(bitPattern: MemoryLayout<GLfloat>.stride * 3)
        glEnableVertexAttribArray(1)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), colors)

        glBindVertexArray(0)

    }

    func setupVertexData() {

        let p1 = CGPoint(x: -0.8, y: 0)
        let p2 = CGPoint(x: 0.8, y: 0.2)
        let control = CGPoint(x: 0, y: -0.9)
        let deltaT: CGFloat = 0.01;

        vertCount = Int(1.0/deltaT);

        // t的范围[0,1]
        for i in 0..<vertCount {
            let t = CGFloat(i) * deltaT
            // 二次方计算公式
            let cx = (1-t)*(1-t)*p1.x + 2*t*(1-t)*control.x + t*t*p2.x
            let cy = (1-t)*(1-t)*p1.y + 2*t*(1-t)*control.y + t*t*p2.y
            vertext.append(Vertex(x: GLfloat(cx), y: GLfloat(cy), z: 0, r: 1.0, g: 0.0, b: 0.0))
        }

    }

    func render() {
        glClearColor(1.0, 1.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        glLineWidth(2.0)

        glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height));

        glBindVertexArray(vao)

        glDrawArrays(GLenum(GL_LINE_STRIP), 0, GLsizei(vertCount))

        //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
