Five files created. Here's a summary of the translation:

New files:

CanvasView.h / CanvasView.m — the custom drawing view
AppDelegate.h / AppDelegate.m — window/menu management
main.m — entry point
Key translation decisions:

Swift	Objective-C
enum Shape	typedef NS_ENUM(NSInteger, CanvasShape)
private var shapes: [Shape]	NSMutableArray<NSNumber *> *_shapes (ivar in @implementation)
shapes.enumerated() for loop	Traditional for (NSInteger index = 0; ...) loop
switch shape { case .line: }	switch (shape) { case CanvasShapeLine: ... break; }
guard let early returns	if (!target) / if (![x isKindOfClass:]) checks
window.isReleasedWhenClosed = false	window.releasedWhenClosed = NO
@objc private func methods	Plain - instance methods
Swift entry point	int main(...) with @autoreleasepool
To compile, you can build with clang:

clang -fobjc-arc -framework AppKit CanvasView.m AppDelegate.m main.m -o Windows