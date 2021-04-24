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
    var texture: GLuint = 0

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayer()
        setupContext()
        setupGLProgram()
        setupVBO()
        setupTexure()
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
        context = EAGLContext(api: .openGLES2)
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

    func setupVBO() {

        let vertices: [GLfloat] = [
            -0.5, 0.5,
            -0.5, -0.5,
            0.5, 0.5,
            0.5, -0.5,
        ]

        var vbo: GLuint = 0
        glGenBuffers(1, &vbo);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo);
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * vertices.count),
                     vertices,
                     GLenum(GL_STATIC_DRAW))

        let position = GLuint(glGetAttribLocation(program, "position"))
        glEnableVertexAttribArray(position)
        glVertexAttribPointer(position,
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<GLfloat>.size*2),
                              nil)

//        let texcoord = GLuint(glGetAttribLocation(program, "texcoord"))
//        let texcoords = UnsafePointer<GLfloat>(bitPattern: MemoryLayout<GLfloat>.stride * 3)
//        glEnableVertexAttribArray(texcoord)
//        glVertexAttribPointer(texcoord,
//                              2,
//                              GLenum(GL_FLOAT),
//                              GLboolean(GL_FALSE),
//                              GLsizei(MemoryLayout<GLfloat>.size*5),
//                              texcoords)

    }

    func setupTexure() {
        texture = ShaderUtil.loadTextureImage(imageName: "local_2.jpeg") ?? 0
        glUniform1i(glGetUniformLocation(program, "image"), 0);
    }

    func render() {
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height));

        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)

        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)

        //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
