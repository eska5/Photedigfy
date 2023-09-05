//
//  Wrapper.m
//  photodaegify
//
//  Created by Jakub Sachajko on 04/09/2023.
//

#import "Wrapper.h"
#import <opencv2/opencv.hpp>

@implementation Wrapper : NSObject

+ (NSString *) openCVVersionString {
    return [NSString stringWithFormat:@"openCV Version %s", CV_VERSION];
}

@end
