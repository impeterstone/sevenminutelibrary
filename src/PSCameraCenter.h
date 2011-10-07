//
//  PSCameraCenter.h
//  Rapanut
//
//  Created by Peter Shih on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/CGImageProperties.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "PSObject.h"

@class PSCameraCenter;

@protocol PSCameraCenterDelegate <NSObject>

@optional
- (void)cameraCenter:(PSCameraCenter *)cameraCenter didCaptureStillImageData:(NSData *)imageData;

@end

@interface PSCameraCenter : PSObject {
  AVCaptureSession *_session;
  AVCaptureDeviceInput *_videoInput;
  AVCaptureDeviceInput *_audioInput;
  AVCaptureStillImageOutput *_stillImageOutput;
  AVCaptureVideoOrientation _orientation;
  
  id <PSCameraCenterDelegate> _delegate;
}

@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic, retain) AVCaptureDeviceInput *audioInput;
@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, assign) AVCaptureVideoOrientation orientation;

@property (nonatomic, assign) id <PSCameraCenterDelegate> delegate;

+ (id)defaultCenter;

// Setup
- (BOOL)setupSession;

// Actions
- (void)captureStillImage;

// Utility
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
@end
