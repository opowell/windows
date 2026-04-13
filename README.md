Here's your complete single-file macOS app. To build and run it, open Terminal and do:

```bash
swiftc main.swift -o Windows -framework AppKit
./Windows
```

**How it works:**

The app is entirely programmatic (no storyboard/XIB). The menu bar has three menus: the standard **App** menu (with Quit), **Windows** (Create New Window ⌘N / Delete Window ⌘W), and **Lines** (2 pt Line ⌘1 / Circle ⌘2 / Rectangle ⌘3).

Each created window contains a `CanvasView` that accumulates shapes. When you pick a shape from the Lines menu it draws into whichever managed window is frontmost. Shapes stack vertically within the window, each in a distinct colour so overlaps are easy to see. If no window exists yet, you get a friendly alert prompting you to create one first.

Windows cascade slightly with each creation so they don't pile on top of each other. "Delete Window" removes the most recently created one.