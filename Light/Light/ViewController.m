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
    
    [self setupContext];
    [self setupEffect];
    [self setupBuffer];
    [self preSender];
    
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
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         0.7f, // Red
                                                         0.7f, // Green
                                                         0.7f, // Blue
                                                         1.0f);// Alpha
    
    self.baseEffect.light0.position = GLKVector4Make(
                                                     1.0f,
                                                     1.0f,
                                                     0.5f,
                                                     0.0f);
    
    self.extraEffect = [[GLKBaseEffect alloc]init];
    self.extraEffect.useConstantColor = GL_TRUE;
    
    //初始矩阵
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60), 1.0, 0.0, 0.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30), 0.0, 0.0, 1.0);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0, 0.0, 0.25);
    
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
    self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
    
}

- (void)setupBuffer{
    
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
    self.extraBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:0 bytes:NULL usage:GL_DYNAMIC_DRAW];
    
}

- (void)preSender{
    
    [self setClearColor:GLKVector4Make(
                                       0.0f, // Red
                                       0.0f, // Green
                                       0.0f, // Blue
                                       1.0f)];// Alpha
    
    self.zPosition = 0.0;
    self.useFaceNormals = YES;
    
}

- (void)setClearColor:(GLKVector4)clearColorRGBA{
    glClearColor(
                 clearColorRGBA.r,
                 clearColorRGBA.g,
                 clearColorRGBA.b,
                 clearColorRGBA.a);
}


- (void)updateNormals{
    
    if (self.useFaceNormals) {
        SceneTrianglesUpdateFaceNormals(triangles);
    }
    else{
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
}

- (void)drawNormals{
    
    GLKVector3 normalVertices[NUM_LINE_VERTS];
    
    SceneTrianglesNormalLinesUpdate(triangles, GLKVector3MakeWithArray(self.baseEffect.light0.position.v), normalVertices);
    [self.extraBuffer reinitWithAttribStride:sizeof(GLKVector3) numberOfVertices:NUM_LINE_VERTS bytes:normalVertices];
    [self.extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor = GLKVector4Make(0.0, 1.0, 0.0, 1.0);
    [self.extraEffect prepareToDraw];
    [self.extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:0 numberOfVertices:NUM_NORMAL_LINE_VERTS];
    
    self.extraEffect.constantColor = GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    [self.extraEffect prepareToDraw];
    [self.extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:0 numberOfVertices:NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useFaceNormal:(id)sender {
    self.useFaceNormals = ((UISwitch *)sender).isOn;
}

- (IBAction)drawFaceNormal:(id)sender {
    self.drawFaceNormals = ((UISwitch *)sender).isOn;
}
- (IBAction)zPositionValueChanged:(id)sender {
    self.zPosition = ((UISlider *)sender).value;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, position)
                                  shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, normal)
                                  shouldEnable:YES];
    
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];
    
    if(self.drawFaceNormals){
        [self drawNormals];
    }
    
}

#pragma mark - Setter

- (void)setZPosition:(CGFloat)zPosition{
    
    _zPosition = zPosition;
    
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = _zPosition;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    [self updateNormals];
}

- (void)setUseFaceNormals:(BOOL)useFaceNormals{
    
    if (useFaceNormals != _useFaceNormals) {
        _useFaceNormals = useFaceNormals;
        [self updateNormals];
    }
    
}

@end
