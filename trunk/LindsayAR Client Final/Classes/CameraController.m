//
//  CameraWrapper.m
//  LindsayAR
//
//  Created by Jishuo Yang on 10-06-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraController.h"

@implementation CameraController
@synthesize delegate;

/**
 * Constructor for the class to initialize video capture settings.
 */
- (id)initVideoCapture {
	
	// Create capture input
	AVCaptureDeviceInput *captureInput = 
	[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
	
	// Create capture output
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	captureOutput.alwaysDiscardsLateVideoFrames = YES;
	
	// Link output processing to main dispatch queue
	[captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	// Set video output to store frame in BGRA
	NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
	NSNumber *val = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
	NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:val forKey:key];
	[captureOutput setVideoSettings:videoSettings];
	
	// Caps number of frames captured per second
	//captureOutput.minFrameDuration = CMTimeMake(1, 15);
	
	// Create capture session
	captureSession = [[AVCaptureSession alloc] init];
	
	// Add capture session to input and output
	[captureSession addInput:captureInput];
	[captureSession addOutput:captureOutput];
	[captureSession beginConfiguration];
	
	// Set quality of video capture, High is 640x480, Medium is 480x360
	[captureSession setSessionPreset:AVCaptureSessionPresetMedium];
	[captureSession commitConfiguration];
	
	// Start capture
	[captureSession startRunning];
	return self;
}

/**
 *
 * Delegate function that is called by the main dispatch queue whenever a new video
 * frame is acquired.
 * This function sends the byte data from the camera frame to the delegate's "processFrameAt"
 * function.
 *
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	
	// Lock the image buffer
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
	// Get information of the image
	unsigned char *baseAddress = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0); 
	//size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
	size_t width = CVPixelBufferGetWidth(imageBuffer); 
	size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
	// Call delegate's process frame method to allow it to use the captured frame
	[delegate processFrameAt:baseAddress withWidth:width andHeight:height];
	
	// Unlock the image buffer 
	CVPixelBufferUnlockBaseAddress(imageBuffer,0); 
}


/**
 *
 * Debugging function for checking the correctness of camera capture. The image
 * in question is saved to the "documents" folder of the app.
 * 
 * @param	CGImageRef imgRef: pointer to location of CGImageRef to be saved. 
 *
 * @param	NSString name: string for the file name the image is to be saved under.
 *
 */
/*
- (void)saveCapturedImage:(CGImageRef)imgRef asName:(NSString*)name
{
	UIImage *image = [UIImage imageWithCGImage:imgRef];
	[imageView setImage:image];
	[imageView setFrame:CGRectMake(0, 0, CGImageGetWidth(imgRef), CGImageGetHeight(imgRef))];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
	NSString *imagePath = [paths objectAtIndex:0] ;
	NSString *filename = [NSString stringWithFormat: @"%@.png", name]; 
	NSString *filepath = [NSString stringWithFormat:@"%@/%@", imagePath, filename] ;
	// Save the image 
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
	[imageData writeToFile:filepath atomically:YES];
}
*/

/**
 *
 * This function creates a CGImageRef from the camera frame, and calls the "processFrame"
 * function on its delegate so that the delegate can access the CGImageRef.
 *
 * Since it is faster to parse the byte array instead of converting the array into an image,
 * this function is no longer used. However, it is still included in case future applications
 * require a CGImageRef.
 */
/*
 - (void)captureOutput2:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
 
 CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
 
 // Lock the image buffer
 CVPixelBufferLockBaseAddress(imageBuffer, 0);
 
 // Get information of the image
 uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0); 
 size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
 size_t width = CVPixelBufferGetWidth(imageBuffer); 
 size_t height = CVPixelBufferGetHeight(imageBuffer); 
 
 // Create CGImageRef 
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
 CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,	kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
 CGImageRef newImage = CGBitmapContextCreateImage(newContext);
 
 // Unlock the image buffer 
 CVPixelBufferUnlockBaseAddress(imageBuffer,0); 
 
 // Release context and colorspace
 CGContextRelease(newContext); 
 CGColorSpaceRelease(colorSpace);
 
 // Call delegate's process frame method to allow it to use the captured frame
 [delegate processFrameWithImage:newImage];
 
 // Release current frame
 CGImageRelease(newImage);
 }
 */


- (void)dealloc {
	[captureSession release];
    [super dealloc];
}

@end
