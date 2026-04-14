#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, CanvasShape) {
    CanvasShapeLine,
    CanvasShapeCircle,
    CanvasShapeRectangle
};

@interface CanvasView : NSView
- (void)addShape:(CanvasShape)shape;
@end
