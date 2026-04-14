#import "CanvasView.h"

@implementation CanvasView {
    NSMutableArray<NSNumber *> *_shapes;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _shapes = [NSMutableArray array];
    }
    return self;
}

- (void)addShape:(CanvasShape)shape {
    [_shapes addObject:@(shape)];
    self.needsDisplay = YES;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Fill background white so shapes are always visible
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);

    CGFloat inset = 30.0;
    NSRect usable = NSInsetRect(self.bounds, inset, inset);

    NSArray<NSColor *> *palette = @[
        [NSColor systemBlueColor],
        [NSColor systemRedColor],
        [NSColor systemGreenColor],
        [NSColor systemOrangeColor],
        [NSColor systemPurpleColor],
        [NSColor systemTealColor]
    ];

    NSInteger count = (NSInteger)_shapes.count;

    for (NSInteger index = 0; index < count; index++) {
        CanvasShape shape = (CanvasShape)[_shapes[(NSUInteger)index] integerValue];

        NSColor *color = palette[(NSUInteger)(index % (NSInteger)palette.count)];
        [color setStroke];
        [[color colorWithAlphaComponent:0.15] setFill];

        // Distribute shapes vertically inside the usable rect
        CGFloat slotHeight = usable.size.height / MAX((CGFloat)count, 1.0);
        CGFloat slotY = usable.origin.y + slotHeight * (CGFloat)index;
        NSRect slotRect = NSMakeRect(usable.origin.x,
                                     slotY + 8.0,
                                     usable.size.width,
                                     slotHeight - 16.0);

        switch (shape) {
            case CanvasShapeLine: {
                NSBezierPath *path = [NSBezierPath bezierPath];
                path.lineWidth = 2.0;
                [path moveToPoint:NSMakePoint(NSMinX(slotRect), NSMidY(slotRect))];
                [path lineToPoint:NSMakePoint(NSMaxX(slotRect), NSMidY(slotRect))];
                [path stroke];
                break;
            }
            case CanvasShapeCircle: {
                CGFloat side = MIN(slotRect.size.width, slotRect.size.height);
                NSRect circleRect = NSMakeRect(NSMidX(slotRect) - side / 2.0,
                                               NSMidY(slotRect) - side / 2.0,
                                               side, side);
                NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:circleRect];
                path.lineWidth = 2.0;
                [path fill];
                [path stroke];
                break;
            }
            case CanvasShapeRectangle: {
                NSBezierPath *rectPath = [NSBezierPath bezierPathWithRect:slotRect];
                rectPath.lineWidth = 2.0;
                [rectPath fill];
                [rectPath stroke];
                break;
            }
        }
    }
}

@end
