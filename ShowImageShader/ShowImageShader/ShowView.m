//
//  ShowView.m
//  ShowImageShader
//
//  Created by lly on 2018/7/11.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ShowView.h"
#import <OpenGLES/ES2/gl.h>

@interface ShowView ()

@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) CAEAGLLayer *mEaglLayer;
@property (nonatomic, assign) GLuint mProgram;

@property (nonatomic, assign) GLuint mColorRenderBuffer;//渲染缓冲区
@property (nonatomic, assign) GLuint mColorFrameBuffer;//帧缓冲区

@property (nonatomic, assign) GLuint inputTexture;
@property (nonatomic, assign) GLint filterInputTextureUniform;


@end



@implementation ShowView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.backgroundColor = [UIColor redColor];
        
    }
    return self;
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews{
    
    [self setupEAGLLayer];
    [self setupContext];
    [self destoryRenderFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
    
}

- (void)setupEAGLLayer{
    
    self.mEaglLayer = (CAEAGLLayer *)self.layer;
    //设置放大倍数
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    self.mEaglLayer.opaque = YES;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.mEaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

//设置渲染上下文
- (void)setupContext{
    
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    self.mContext = context;
}

//设置渲染缓冲区
- (void)setupRenderBuffer{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.mColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.mColorRenderBuffer);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEaglLayer];
}

//设置帧缓冲区
- (void)setupFrameBuffer{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.mColorFrameBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.mColorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.mColorRenderBuffer);
}

//回收资源
- (void)destoryRenderFrameBuffer{
    glDeleteFramebuffers(1, &_mColorFrameBuffer);
    self.mColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_mColorRenderBuffer);
    self.mColorRenderBuffer = 0;
}

- (void)render{
    
    glClearColor(1, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y*scale, scale*self.frame.size.width, scale*self.frame.size.height);//设置视口大小
    
    //读取文件路径
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    //加载shader
    self.mProgram = [self loadShaders:vertFile frag:fragFile];
    
    //链接
    glLinkProgram(self.mProgram);
    
    //链接状态
    GLint linkStatus;
    glGetProgramiv(self.mProgram, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.mProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return ;
    }
    else{
        NSLog(@"link success");
        //使用program
        glUseProgram(self.mProgram);
    }
    
    //给program绑定顶点数据和纹理数据
    //前三个是顶点坐标， 后面两个是纹理坐标
//    GLfloat vertexData[] =
//    {
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//    };
    
    //镜像
    GLfloat vertexData[] =
    {
        0.5, -0.5, 0.0f,   0.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,   0.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,   1.0f, 1.0f, //左上

        0.5, -0.5, 0.0f,   0.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,   1.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,  1.0f, 0.0f, //左下
    };

    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.mProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(self.mProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    self.filterInputTextureUniform = glGetUniformLocation(self.mProgram, "Texture");

    //加载纹理
    [self setupTexture:@"wk.JPG"];
    
//    //获取shader里面的变量，要在glLinkProgram后面
    GLuint rotate = glGetUniformLocation(self.mProgram, "rotateMatrix");

    float radians = M_PI;
    float s = sin(radians);
    float c = cos(radians);

    //绕Z轴旋转矩阵
    GLfloat zRotation[16] = { //
        c, -s, 0, 0, //
        s, c, 0, 0,//
        0, 0, 1.0, 0,//
        0.0, 0, 0, 1.0//
    };

    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.inputTexture);
//    glUniform1f(self.filterInputTextureUniform, 1);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */
- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag{
    
    GLuint verShader,fragShader;
    GLint program = glCreateProgram();
    
    //编译shader
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    //attach shader
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //释放资源
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
    
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    //shader路径
    NSString *shaderPath = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *sourcePath = (GLchar *)[shaderPath UTF8String];
    
    //创建shader
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &sourcePath, NULL);
    glCompileShader(*shader);
    
}

- (GLuint)setupTexture:(NSString *)fileName{
    
    //获取图片的CGImageRef
    CGImageRef imageRef = [UIImage imageNamed:fileName].CGImage;
    if (!imageRef) {
        NSLog(@"load image error %@",imageRef);
        exit(1);
    }
    
    //读取图片的大小
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    GLubyte *imageData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));//图片大小
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    
    //将图片写入上下文
    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(imageContext);
    
    //绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
//    glEnable(GL_TEXTURE_2D);
//    glGenTextures(1, &_inputTexture);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (CGFloat)width, (CGFloat)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    //绑定纹理位置
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(imageData);
    
    return 0;
    
}

@end
