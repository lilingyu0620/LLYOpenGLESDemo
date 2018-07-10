//
//  ViewController.m
//  ShowImage
//
//  Created by lly on 2018/7/10.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

@interface ViewController ()<GLKViewDelegate>

//GL上下文
@property (nonatomic, strong) EAGLContext *mContext;
//GL效果器,提供一个可配置的shader 不需要自己再写shader
@property (nonatomic, strong) GLKBaseEffect *mEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupConfig];
    [self uploadVerterArrat];
    [self uploadTexture];
    
}

- (void)setupConfig{
    
    self.mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.delegate = self;//除了修改父类，还需要设置一下代理
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    [EAGLContext setCurrentContext:self.mContext];
}


- (void)uploadVerterArrat{
    
    //顶点数据，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（x，y）
    GLfloat vertexData[] =
    {
        1.0, -1.0, 0.0f,   1.0f, 0.0f, //右下
        1.0, 1.0, -0.0f,   1.0f, 1.0f, //右上
        -1.0, 1.0, 0.0f,   0.0f, 1.0f, //左上

        1.0, -1.0, 0.0f,   1.0f, 0.0f, //右下
        -1.0, 1.0, 0.0f,   0.0f, 1.0f, //左上
        -1.0, -1.0, 0.0f,  0.0f, 0.0f, //左下
    };
    
    //上下颠倒
//    GLfloat vertexData[] =
//    {
//        1.0, -1.0, 0.0f,   1.0f, 1.0f, //右下
//        1.0, 1.0, -0.0f,   1.0f, 0.0f, //右上
//        -1.0, 1.0, 0.0f,   0.0f, 0.0f, //左上
//
//        1.0, -1.0, 0.0f,   1.0f, 1.0f, //右下
//        -1.0, 1.0, 0.0f,   0.0f, 0.0f, //左上
//        -1.0, -1.0, 0.0f,  0.0f, 1.0f, //左下
//    };

    
    //镜像
//    GLfloat vertexData[] =
//    {
//        1.0, -1.0, 0.0f,   0.0f, 0.0f, //右下
//        1.0, 1.0, -0.0f,   0.0f, 1.0f, //右上
//        -1.0, 1.0, 0.0f,   1.0f, 1.0f, //左上
//
//        1.0, -1.0, 0.0f,   0.0f, 0.0f, //右下
//        -1.0, 1.0, 0.0f,   1.0f, 1.0f, //左上
//        -1.0, -1.0, 0.0f,  1.0f, 0.0f, //左下
//    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //将顶点数据存入缓冲区
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

- (void)uploadTexture {
    //纹理贴图
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"wk" ofType:@"JPG"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
}

/**
 *  渲染场景代码
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1.f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
