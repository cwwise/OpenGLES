//
//  ShaderUtil.swift
//  OpenGLES02-着色器
//
//  Created by chenwei on 2021/3/28.
//

import Foundation
import GLKit

@available(*, deprecated)
class ShaderUtil: NSObject {

    //封装加载着色器程序方法
    class func loadShader(vertexShaderName:String, fragmentShaderName:String) -> GLuint? {
        let program:GLuint = glCreateProgram()
        guard let sname = vertexShaderName.split(separator: ".").first,
              let stype = vertexShaderName.split(separator: ".").last,
              let fname = fragmentShaderName.split(separator: ".").first,
              let ftype = fragmentShaderName.split(separator: ".").last else {
            return nil
        }

        //读取并编译着色器程序
        func compileShader(type:GLenum,filePath:String) -> GLuint? {
            //创建一个空着色器
            let verShader:GLuint = glCreateShader(type)
            //获取源文件中的代码字符串
            guard let shaderString = try? String.init(contentsOfFile: filePath, encoding: String.Encoding.utf8)else    {
                return nil
            }
            //转成C字符串赋值给已创建的shader
            shaderString.withCString { (pointer) in
                var pon:UnsafePointer<GLchar>? = pointer
                glShaderSource(verShader, 1, &pon, nil)
            }

            //编译
            glCompileShader(verShader)

            return verShader
        }

        let spath = Bundle.main.path(forResource: String(sname), ofType: String(stype)) ?? ""
        let fpath = Bundle.main.path(forResource: String(fname), ofType: String(ftype)) ?? ""
        //vertexShader
        guard let verShader:GLuint = compileShader(type: GLenum(GL_VERTEX_SHADER), filePath: spath) else {
            return nil

        }
        //把编译后的着色器代码附着到最终的程序上
        glAttachShader(program, verShader)
        //释放不需要的shader
        glDeleteShader(verShader)

        //fragmentShader
        guard let fragShader = compileShader(type: GLenum(GL_FRAGMENT_SHADER), filePath: fpath)else{
            return nil

        }
        glAttachShader(program, fragShader)
        glDeleteShader(fragShader)

        //链接着色器代程序
        glLinkProgram(program)
        //获取链接状态
        var status:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if status == GLenum(GL_FALSE){
            print("link Error")
            //打印错误信息
            let message = UnsafeMutablePointer<GLchar>.allocate(capacity: 512)
            glGetProgramInfoLog(program, GLsizei(MemoryLayout<GLchar>.size * 512), nil, message)
            let str = String.init(utf8String: message)
            print(str ?? "没有取到ProgramInfoLog")
            return nil
        }else{
            print("link sucess!")
            //链接成功，使用着色器程序
            glUseProgram(program)
            return program
        }

    }

}
