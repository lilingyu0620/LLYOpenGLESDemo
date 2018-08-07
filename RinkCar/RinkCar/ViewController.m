//
//  ViewController.m
//  RinkCar
//
//  Created by lly on 2018/8/7.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ViewController.h"
#import "SceneCarModel.h"
#import "SceneRinkModel.h"
#import "SceneCar.h"
#import "AGLKContext.h"


@interface ViewController ()<GLKViewDelegate>

@property (nonatomic, strong) NSMutableArray *cars;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@property (nonatomic, strong) SceneModel *carModel;
@property (nonatomic, strong) SceneModel *rinkModel;

@property (nonatomic, assign) BOOL shouldUseFirstPersonPOV;
@property (nonatomic, assign) CGFloat pointOfViewAnimationCountdown;

@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, assign) GLKVector3 lookAtPosition;

@property (nonatomic, assign) GLKVector3 targetEyePosition;
@property (nonatomic, assign) GLKVector3 targetLookAtPosition;

@property (nonatomic, assign) SceneAxisAllignedBoundingBox rinkBoundingBox;

@end

static const int SceneNumberOfPOVAnimationSeconds = 2.0;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _cars = [NSMutableArray array];
    
    GLKView *view = (GLKView *)self.view;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.delegate = self;
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.6, 0.6, 0.6, 1);
    self.baseEffect.light0.position = GLKVector4Make(1.0, 0.8, 0.4, 0.0);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    [((AGLKContext *)view.context) enable:GL_BLEND];
    
    self.carModel = [[SceneCarModel alloc]init];
    self.rinkModel = [[SceneRinkModel alloc]init];
    
    self.rinkBoundingBox = self.rinkModel.axisAlignedBoundingBox;
    
    SceneCar *sceneCar1 = [[SceneCar alloc]initWithModel:self.carModel position:GLKVector3Make(1.0, 0.0, 1.0) velocity:GLKVector3Make(1.5, 0.0, 1.5) color:GLKVector4Make(0.0, 0.5, 0.0, 1.0)];
    [self.cars addObject:sceneCar1];

    SceneCar *sceneCar2 = [[SceneCar alloc]initWithModel:self.carModel position:GLKVector3Make(-1.0, 0.0, 1.0) velocity:GLKVector3Make(-1.5, 0.0, 1.5) color:GLKVector4Make(0.5, 0.5, 0.0, 1.0)];
    [self.cars addObject:sceneCar2];
    
    SceneCar *sceneCar3 = [[SceneCar alloc]initWithModel:self.carModel position:GLKVector3Make(1.0, 0.0, -1.0) velocity:GLKVector3Make(1.5, 0.0, -1.5) color:GLKVector4Make(0.5, 0.0, 0.0, 1.0)];
    [self.cars addObject:sceneCar3];
    
    SceneCar *sceneCar4 = [[SceneCar alloc]initWithModel:self.carModel position:GLKVector3Make(2.0, 0.0, -2.0) velocity:GLKVector3Make(-1.5, 0.0, -0.5) color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)];
    [self.cars addObject:sceneCar4];
    
    self.eyePosition = GLKVector3Make(10.5, 5.0, 0.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
    
}

- (void)updatePointOfView{
    
    if(!self.shouldUseFirstPersonPOV)
    {  // Set the target point of view to arbitrary "third person"
        // perspective
        self.eyePosition = GLKVector3Make(10.5, 5.0, 0.0);
        self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
    }
    else
    {  // Set the target point of view to a position within the
        // last car and facing the direction of the car's motion.
        SceneCar *viewerCar = [self.cars lastObject];
        
        // Set the new target position up a bit from center of
        // car
        self.targetEyePosition = GLKVector3Make(
                                                viewerCar.position.x,
                                                viewerCar.position.y + 0.45f,
                                                viewerCar.position.z);
        
        // Look from eye position in direction of motion
        self.targetLookAtPosition = GLKVector3Add(
                                                  self.eyePosition,
                                                  viewerCar.velocity);
    }
    
}


- (void)update
{
    if(0 < self.pointOfViewAnimationCountdown)
    {
        self.pointOfViewAnimationCountdown -=
        self.timeSinceLastUpdate;
        
        // Update the current eye and look-at positions with slow
        // filter so user can savor the POV animation
        self.eyePosition = SceneVector3SlowLowPassFilter(
                                                         self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        self.lookAtPosition = SceneVector3SlowLowPassFilter(
                                                            self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    }
    else
    {  // Update the current eye and look-at positions with fast
        // filter so POV stays close to car orientation but still
        // has a little "bounce"
        self.eyePosition = SceneVector3FastLowPassFilter(
                                                         self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        self.lookAtPosition = SceneVector3FastLowPassFilter(
                                                            self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    }
    
    // Update the cars
    [self.cars makeObjectsPerformSelector:
     @selector(updateWithController:) withObject:self];
    
    // Update the target positions
    [self updatePointOfView];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Make the light white
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    
    // Clear back frame buffer (erase previous drawing)
    [((AGLKContext *)view.context)
     clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    // Calculate the aspect ratio for the scene and setup a
    // perspective projection
    const GLfloat  aspectRatio =
    (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(35.0f),// Standard field of view
                              aspectRatio,
                              0.1f,   // Don't make near plane too close
                              25.0f); // Far is aritrarily far enough to contain scene
    
    // Set the modelview matrix to match current eye and look-at
    // positions
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         self.eyePosition.x,
                         self.eyePosition.y,
                         self.eyePosition.z,
                         self.lookAtPosition.x,
                         self.lookAtPosition.y,
                         self.lookAtPosition.z,
                         0, 1, 0);
    
    // Draw the rink
    [self.baseEffect prepareToDraw];
    [self.rinkModel draw];
    
    // Draw the cars
    [self.cars makeObjectsPerformSelector:@selector(drawWithBaseEffect:)
                          withObject:self.baseEffect];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotate{
    // Return YES for supported orientations
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscape;
    
}


- (IBAction)povSwitch:(id)sender {
    
    self.shouldUseFirstPersonPOV = ((UISwitch *)sender).on;
    _pointOfViewAnimationCountdown = SceneNumberOfPOVAnimationSeconds;
    
}


@end
