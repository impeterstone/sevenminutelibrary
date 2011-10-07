//
//  PSCameraCenter.m
//  Rapanut
//
//  Created by Peter Shih on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCameraCenter.h"

@interface PSCameraCenter (Private)

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *)frontFacingCamera;
- (AVCaptureDevice *)backFacingCamera;
- (AVCaptureDevice *)audioDevice;
- (void)deviceOrientationDidChange:(NSNotification *)notification;

@end

@implementation PSCameraCenter

@synthesize session = _session;
@synthesize videoInput = _videoInput;
@synthesize audioInput = _audioInput;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize orientation = _orientation;
@synthesize delegate = _delegate;

+ (id)defaultCenter {
  static id defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
    [self setupSession];
    
    // Orientation
		self.orientation = AVCaptureVideoOrientationPortrait; // Default orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
  }
  return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
  
  [self.session stopRunning];
  RELEASE_SAFELY(_session);
  RELEASE_SAFELY(_stillImageOutput);
  [super dealloc];
}

// Setup
- (BOOL)setupSession {
  BOOL success = NO;
  
  // Set torch and flash mode to auto
	if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	if ([[self backFacingCamera] hasTorch]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeAuto]) {
				[[self backFacingCamera] setTorchMode:AVCaptureTorchModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
  
  // Init the device inputs
  AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
  AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
  
  // Setup the still image file output
  AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
  NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  AVVideoCodecJPEG, AVVideoCodecKey,
                                  nil];
  [newStillImageOutput setOutputSettings:outputSettings];
  [outputSettings release];
  
  // Session
  AVCaptureSession *session = [[[AVCaptureSession alloc] init] autorelease];
  session.sessionPreset = AVCaptureSessionPresetPhoto;
  self.session = session;
  
  // Add inputs and output to the capture session
  if ([session canAddInput:newVideoInput]) {
    [session addInput:newVideoInput];
  }
  if ([session canAddInput:newAudioInput]) {
    [session addInput:newAudioInput];
  }
  if ([session canAddOutput:newStillImageOutput]) {
    [session addOutput:newStillImageOutput];
  }
  self.videoInput = newVideoInput;
  self.audioInput = newAudioInput;
  self.stillImageOutput = newStillImageOutput;
  
  [newVideoInput release];
  [newAudioInput release];
  [newStillImageOutput release];
  
  success = YES;
  
  return success;
}

// Actions
- (void)captureStillImage {
  AVCaptureConnection *stillImageConnection = [PSCameraCenter connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.stillImageOutput connections]];
  if ([stillImageConnection isVideoOrientationSupported]) {
    [stillImageConnection setVideoOrientation:self.orientation];
  }
  
  [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
   {
		 CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
		 if (exifAttachments)
		 {
       // Do something with the attachments.
       NSLog(@"attachements: %@", exifAttachments);
		 }
     else
       NSLog(@"no attachments");
     
     NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
//     UIImage *image = [[UIImage alloc] initWithData:imageData];
     
     // Inform delegate
     if (imageData && self.delegate && [self.delegate respondsToSelector:@selector(cameraCenter:didCaptureStillImageData:)]) {
       [self.delegate cameraCenter:self didCaptureStillImageData:imageData];
     }
	 }];
}

#pragma mark - Utility
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position {
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDevice *device in devices) {
    if ([device position] == position) {
      return device;
    }
  }
  return nil;
}


// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *)frontFacingCamera {
  return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *)backFacingCamera {
  return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *)audioDevice {
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
  if ([devices count] > 0) {
    return [devices objectAtIndex:0];
  }
  return nil;
}

// Keep track of current device orientation so it can be applied to movie recordings and still image captures
- (void)deviceOrientationDidChange:(NSNotification *)notification {	
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
  
	if (deviceOrientation == UIDeviceOrientationPortrait)
		self.orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		self.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	
	// AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		self.orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		self.orientation = AVCaptureVideoOrientationLandscapeLeft;
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

@end
