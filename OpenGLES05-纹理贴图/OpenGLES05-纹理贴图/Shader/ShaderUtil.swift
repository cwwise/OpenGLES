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

    //加载一张纹理图片
    class func loadTextureImage(imageName: String, map: Bool = false) -> GLuint? {
        
        guard let image = UIImage(named: imageName)?.cgImage else {
            return nil
        }

        let width = image.width
        let height = image.height

        //开辟内存，绘制到这个内存上去
        let spriteData: UnsafeMutablePointer = UnsafeMutablePointer<GLubyte>.allocate(capacity: MemoryLayout<GLubyte>.size * width * height * 4)

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        //获取context
        let spriteContext = CGContext(data: spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)
        //2.图片反转2
        spriteContext?.translateBy(x: 0, y: CGFloat(height))//向下平移图片的高度
        spriteContext?.scaleBy(x: 1, y: -1)//反转图片

        spriteContext?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsEndImageContext()

        //绑定纹理
        var textureID: GLuint = 0
        glGenTextures(1, &textureID)
        glActiveTexture(textureID)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureID)

        //设置纹理参数
        //缩小/放大过滤器
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        //环绕方式
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        //载入纹理
        /*
        参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
        参数2：加载的层次，一般设置为0
        参数3：纹理的颜色值GL_RGBA
        参数4：宽
        参数5：高
        参数6：border，边界宽度
        参数7：format
        参数8：type
        参数9：纹理数据
        */
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE),spriteData)

        if map {
            glGenerateMipmap(GLenum(GL_TEXTURE_2D))
        }
        //释放内存
        free(spriteData)
        return textureID
    }

}
