//
//  ViewController.m
//  OpenGLES-纹理形变
//
//  Created by ShiWen on 2017/5/23.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ViewController.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}
SceneVertex;


/////////////////////////////////////////////////////////////////
//矩形
static const SceneVertex vertices[] =
{
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // 第一个三角形
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // 第二个三角形
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};
@interface ViewController ()
@property (nonatomic,strong) AGLKTextureTransformBaseEffect *mBassEffect;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *mVertexBuffer;
@property (nonatomic,assign) GLKMatrixStackRef textureMatixRef;
@property (nonatomic,assign) float scale;
@property (nonatomic,assign) float rotate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textureMatixRef = GLKMatrixStackCreate(kCFAllocatorDefault);
    //初始化比例
    self.scale = 1.0;
    GLKView *glView = (GLKView *)self.view;
    glView.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:glView.context];
    [((AGLKContext*)glView.context) setClearColor:GLKVector4Make(0.0, 0.0, 0.0,1.0)];
    self.mBassEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    self.mBassEffect.useConstantColor = GL_TRUE;
    self.mBassEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
    self.mVertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices)/sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
    
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:options error:nil];
    self.mBassEffect.texture2d0.target = textureInfo0.target;
    self.mBassEffect.texture2d0.name = textureInfo0.name;
    self.mBassEffect.texture2d0.enabled = GL_TRUE;

    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:options error:nil];
    self.mBassEffect.texture2d1.target = textureInfo1.target;
    self.mBassEffect.texture2d1.name = textureInfo1.name;
    self.mBassEffect.texture2d1.enabled = GL_TRUE;
    self.mBassEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    [self.mBassEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S value:GL_REPEAT];
    [self.mBassEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_T value:GL_REPEAT];
    //设置要改变的纹理
    GLKMatrixStackLoadMatrix4(self.textureMatixRef, self.mBassEffect.textureMatrix2d1);
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    
    
    self.mBassEffect.textureMatrix2d1 = GLKMatrixStackGetMatrix4(self.textureMatixRef);
    [self.mVertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    [self.mVertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    [self.mVertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    GLKMatrixStackPush(self.textureMatixRef);
//    //设置纹理围绕中心位置旋转和缩放
    GLKMatrixStackTranslate(self.textureMatixRef, -0.5 ,-0.5, 0.0);
//    x，y轴缩放
    GLKMatrixStackScale(self.textureMatixRef, self.scale, self.scale, 1.0);
    //围绕Z轴旋转
    GLKMatrixStackRotate(self.textureMatixRef,GLKMathDegreesToRadians(self.rotate) , 0.0, 0.0, 1.0);
    //设置围绕中心位置旋转，右上角为-1.0，-1.0
    GLKMatrixStackTranslate(self.textureMatixRef,-0.5, -0.5, 0.0);
    self.mBassEffect.textureMatrix2d1 =
    GLKMatrixStackGetMatrix4(self.textureMatixRef);
    [self.mBassEffect prepareToDrawMultitextures];
    
    [self.mVertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)];
    
   
     GLKMatrixStackPop(self.textureMatixRef);
    self.mBassEffect.textureMatrix2d1 =
    GLKMatrixStackGetMatrix4(self.textureMatixRef);
}
- (IBAction)scale:(UISlider *)sender {
    self.scale = sender.value;
}
- (IBAction)rotate:(UISlider *)sender {
    self.rotate = sender.value;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
