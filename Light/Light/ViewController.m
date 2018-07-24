//
//  ViewController.m
//  Light
//
//  Created by lly on 2018/7/20.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sceneUtil.h"

@interface ViewController ()<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *mContext;

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) GLKBaseEffect *extraEffect;

@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *extraBuffer;

@property (nonatomic, assign, getter=isUseFaceNormals) BOOL useFaceNormals;
@property (nonatomic, assign, getter=isDrawFaceNormals) BOOL drawFaceNormals;
@property (nonatomic, assign) CGFloat zPosition;

@end

@implementation ViewController{
    
    SceneTriangle triangles[NUM_FACES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)setupContext{
    
    //新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView* view = (GLKView *)self.view;
    view.context = self.mContext;
    view.delegate = self;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    
}

- (void)setupEffect{
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useFaceNormal:(id)sender {
    
}

- (IBAction)drawFaceNormal:(id)sender {
    
}
- (IBAction)zPositionValueChanged:(id)sender {
    
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    
}

@end
