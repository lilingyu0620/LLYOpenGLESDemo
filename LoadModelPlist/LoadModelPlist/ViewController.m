//
//  ViewController.m
//  LoadModelPlist
//
//  Created by lly on 2018/8/8.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ViewController.h"
#import "UtilityModelManager+skinning.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModel+skinning.h"
#import "UtilityJoint.h"
#import "UtilityArmatureBaseEffect.h"
#import "AGLKContext.h"

@interface ViewController ()<GLKViewDelegate>

@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic) UtilityArmatureBaseEffect *baseEffect;
@property (strong, nonatomic) UtilityModel *bone0;
@property (strong, nonatomic) UtilityModel *bone1;
@property (strong, nonatomic) UtilityModel *bone2;
@property (strong, nonatomic) UtilityModel *tube;
@property (assign, nonatomic) float joint0AngleRadians;
@property (assign, nonatomic) float joint1AngleRadians;
@property (assign, nonatomic) float joint2AngleRadians;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GLKView *view = (GLKView *)self.view;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.delegate = self;
    [AGLKContext setCurrentContext:view.context];
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    
    self.baseEffect = [[UtilityArmatureBaseEffect alloc]init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.7, 0.7, 0.7, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.baseEffect.light0Position = GLKVector4Make(1.0, 0.8, 0.4, 0.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"armatureSkin" ofType:@"modelplist"];
    if (modelsPath) {
        self.modelManager = [[UtilityModelManager alloc]initWithModelPath:modelsPath];
    }
    
    self.bone0 = [self.modelManager modelNamed:@"bone0"];
    self.bone1 = [self.modelManager modelNamed:@"bone1"];
    self.bone2 = [self.modelManager modelNamed:@"bone2"];
    self.tube = [self.modelManager modelNamed:@"tube"];
    
    UtilityJoint *bone0Joint = [[UtilityJoint alloc]initWithDisplacement:GLKVector3Make(0, 0, 0) parent:nil];
    float joint0Lenght = self.bone0.axisAlignedBoundingBox.max.y - self.bone0.axisAlignedBoundingBox.min.y;
    UtilityJoint *bone1Joint = [[UtilityJoint alloc]initWithDisplacement:GLKVector3Make(0, joint0Lenght, 0) parent:bone0Joint];
    float joint1Lenght = self.bone1.axisAlignedBoundingBox.max.y - self.bone1.axisAlignedBoundingBox.min.y;
    UtilityJoint *bone2Joint = [[UtilityJoint alloc]initWithDisplacement:GLKVector3Make(0, joint1Lenght, 0) parent:bone1Joint];
    
    self.baseEffect.jointsArray = [NSArray arrayWithObjects:bone0Joint,bone1Joint,bone2Joint, nil];
    [self.tube automaticallySkinRigidWithJoints:self.baseEffect.jointsArray];
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         5.0, 10.0, 15.0,// Eye position
                         0.0, 2.0, 0.0,  // Look-at position
                         0.0, 1.0, 0.0); // Up direction
    
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    // Clear back frame buffer (erase previous drawing)
    // and depth buffer
    [((AGLKContext *)view.context)
     clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    // Cull back faces: Important! many Sketchup models have back
    // faces that cause Z fighting if back faces are not culled.
    [((AGLKContext *)view.context) enable:GL_CULL_FACE];
    
    // Calculate the aspect ratio for the scene and setup a
    // perspective projection
    const GLfloat  aspectRatio =
    (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(35.0f),// Standard field of view
                              aspectRatio,
                              4.0f,   // Don't make near plane too close
                              20.0f); // Far arbitrarily far enough to contain scene
    
    [self.modelManager prepareToDrawWithJointInfluence];
    [self.baseEffect prepareToDrawArmature];
    [self.tube draw];
    
}

- (void)setJoint0AngleRadians:(float)joint0AngleRadians{
    
    _joint0AngleRadians = joint0AngleRadians;
    GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(
                                                       _joint0AngleRadians * M_PI * 0.5, 0, 0, 1);
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:0]
     setMatrix:rotateZMatrix];
    
}

- (void)setJoint1AngleRadians:(float)joint1AngleRadians{
    
    _joint1AngleRadians = joint1AngleRadians;
    GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(
                                                       _joint1AngleRadians * M_PI * 0.5, 0, 0, 1);
    
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:1]
     setMatrix:rotateZMatrix];
    
}
- (void)setJoint2AngleRadians:(float)joint2AngleRadians{
    
    _joint2AngleRadians = joint2AngleRadians;
    GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(
                                                       _joint2AngleRadians * M_PI * 0.5, 0, 0, 1);
    
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:2]
     setMatrix:rotateZMatrix];
    
}

- (IBAction)joint0ValueChanged:(UISlider *)sender {
    self.joint0AngleRadians = sender.value;
}
- (IBAction)joint1ValueChanged:(UISlider *)sender {
    self.joint1AngleRadians = sender.value;
}
- (IBAction)joint2ValueChanged:(UISlider *)sender {
    self.joint2AngleRadians = sender.value;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
