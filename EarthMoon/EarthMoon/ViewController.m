//
//  ViewController.m
//  EarthMoon
//
//  Created by lly on 2018/7/18.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"

static const GLfloat SceneEarthAxialTiltDeg = 23.5f;
static const GLfloat SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat SceneMoonDistanceFromEarth = 2.0;

@interface ViewController ()<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *mContext;

@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *positionBuffer;//顶点数据
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *normalBuffer;//法线数据
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *textureCoordBuffer;//纹理数据

@property (nonatomic, strong) GLKBaseEffect *mEffect;//效果器

@property (nonatomic, strong) GLKTextureInfo *earthTextureInfo;//地图纹理
@property (nonatomic, strong) GLKTextureInfo *moonTextureInfo;//月球纹理

@property (nonatomic, assign) GLKMatrixStackRef modelViewMatrixStack;//视口矩阵

@property (nonatomic, assign) GLfloat earthDegress;
@property (nonatomic, assign) GLfloat moonDegress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupContext];
    [self setupEffect];
    [self setupLight];
    [self setupDataBuffer];
    [self setupTexture];
    [self setupMatrixStack];
    [self preRender];
    
}

//投影切换 默认是正交投影
- (IBAction)onSwitch:(id)sender {
    
    GLfloat aspectRatio =
    (float)((GLKView *)self.view).drawableWidth /
    (float)((GLKView *)self.view).drawableHeight;
    
    if([(UISwitch *)sender isOn]){
        self.mEffect.transform.projectionMatrix =
        GLKMatrix4MakeFrustum(
                              -1.0 * aspectRatio,
                              1.0 * aspectRatio,
                              -1.0,
                              1.0,
                              2.0,
                              120.0);

    }
    else{
        self.mEffect.transform.projectionMatrix =
        GLKMatrix4MakeOrtho(
                            -1.0 * aspectRatio,
                            1.0 * aspectRatio,
                            -1.0,
                            1.0,
                            1.0,
                            120.0);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)preRender{
    
    glEnable(GL_DEPTH_TEST);
    [self setClearColor:GLKVector4Make(1.0f, // Red
                                       0.0f, // Green
                                       0.0f, // Blue
                                       1.0f)];// Alpha
    self.moonDegress = -20.0f;
}

- (void)setupContext{
    
    self.mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.delegate = self;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
}

- (void)setupEffect{
    
    self.mEffect = [[GLKBaseEffect alloc]init];
    
    GLfloat aspectRatio = self.view.bounds.size.width/self.view.bounds.size.height;
    
//    ModelView matrix is the concatenation of Model matrix and View Matrix. View Matrix defines the position(location and orientation) of the camera, while model matrix defines the frame's position of the primitives you are going to draw.
//        Projection matrix defines the characteristics of your camera, such as clip planes, field of view, projection method etc.
    //物体旋转改变的是modelviewMatrix,投影切换改变的是projectionMatrix
    self.mEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * aspectRatio, 1.0 * aspectRatio, -1.0, 1.0, 1.0, 120);
    self.mEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0);
    
}

- (void)setupLight{
    
    self.mEffect.light0.enabled = GL_TRUE;
    self.mEffect.light0.diffuseColor = GLKVector4Make(
                                                      1.0f, // Red
                                                      1.0f, // Green
                                                      1.0f, // Blue
                                                      1.0f);// Alpha
    self.mEffect.light0.position = GLKVector4Make(
                                                  1.0f,
                                                  0.0f,
                                                  0.8f,
                                                  0.0f);
    
    self.mEffect.light0.ambientColor = GLKVector4Make(
                                                      0.2f, // Red
                                                      0.2f, // Green
                                                      0.2f, // Blue
                                                      1.0f);// Alpha
    
}

- (void)setupDataBuffer{
    
    self.positionBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:(sizeof(sphereVerts)/(3 * sizeof(GLfloat))) bytes:sphereVerts usage:GL_STATIC_DRAW];
    self.normalBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:(sizeof(sphereNormals)/(3 * sizeof(GLfloat))) bytes:sphereNormals usage:GL_STATIC_DRAW];
    self.textureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(2 * sizeof(GLfloat)) numberOfVertices:(sizeof(sphereTexCoords)/(2 * sizeof(GLfloat))) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    
}

- (void)setupTexture{
    
    CGImageRef earthImageRef = [UIImage imageNamed:@"Earth512x256.jpg"].CGImage;
    self.earthTextureInfo = [GLKTextureLoader textureWithCGImage:earthImageRef options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    
    CGImageRef moonImageRef = [UIImage imageNamed:@"Moon256x128.png"].CGImage;
    self.moonTextureInfo = [GLKTextureLoader textureWithCGImage:moonImageRef options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    
}

- (void)setupMatrixStack{
    
    self.modelViewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    GLKMatrixStackLoadMatrix4(self.modelViewMatrixStack, self.mEffect.transform.modelviewMatrix);
    
}

- (void)setClearColor:(GLKVector4)clearColor{
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
}

- (void)renderEarth{
    
    self.mEffect.texture2d0.name = self.earthTextureInfo.name;
    self.mEffect.texture2d0.target = self.earthTextureInfo.target;
    
    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 1.000000 0.000000 0.000000
     0.000000 0.000000 1.000000 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    GLKMatrixStackPush(self.modelViewMatrixStack);
    
    GLKMatrixStackRotate(
                         self.modelViewMatrixStack,
                         GLKMathDegreesToRadians(SceneEarthAxialTiltDeg),
                         1.0, 0.0, 0.0);
    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.000000 -0.398749 0.917060 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    
    GLKMatrixStackRotate(
                         self.modelViewMatrixStack,
                         GLKMathDegreesToRadians(self.earthDegress),
                         0.0, 1.0, 0.0);
    /*
     current matrix:
     0.994522 0.041681 -0.095859 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.104528 -0.396565 0.912036 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    self.mEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelViewMatrixStack);
    
    [self.mEffect prepareToDraw];
    
    
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];
    
    /*
     
     current matrix:
     0.994522 0.041681 -0.095859 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.104528 -0.396565 0.912036 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    GLKMatrixStackPop(self.modelViewMatrixStack);
    
    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 1.000000 0.000000 0.000000
     0.000000 0.000000 1.000000 0.000000
     0.000000 0.000000 -5.000000 1.000000
     
     */
    self.mEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelViewMatrixStack);
    
}
- (void)renderMoon{
    
    self.mEffect.texture2d0.name = self.moonTextureInfo.name;
    self.mEffect.texture2d0.target = self.moonTextureInfo.target;
    
    GLKMatrixStackPush(self.modelViewMatrixStack);
    
    GLKMatrixStackRotate(
                         self.modelViewMatrixStack,
                         GLKMathDegreesToRadians(self.moonDegress),
                         0.0, 1.0, 0.0);
    GLKMatrixStackTranslate(
                            self.modelViewMatrixStack,
                            0.0, 0.0, SceneMoonDistanceFromEarth);
    GLKMatrixStackScale(
                        self.modelViewMatrixStack,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth);
    GLKMatrixStackRotate(
                         self.modelViewMatrixStack,
                         GLKMathDegreesToRadians(self.moonDegress),
                         0.0, 1.0, 0.0);
    
    self.mEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelViewMatrixStack);
    
    [self.mEffect prepareToDraw];
    
    
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelViewMatrixStack);
    
    self.mEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelViewMatrixStack);
}

#pragma mark - rotate 自动横屏
- (BOOL)shouldAutorotate{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    self.earthDegress += 360.0f / 60.0f;
    self.moonDegress += (360.0f / 60.0f) / SceneDaysPerMoonOrbit;
    
    [self.positionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    
    [self.normalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    
    [self.textureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
    
    [self renderEarth];
    [self renderMoon];
    
}

@end
