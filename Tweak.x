#import <SpringBoardHome/SBIconListGridLayout.h>
#import <SpringBoardHome/SBIconListGridLayoutConfiguration.h>
#import <version.h>

BOOL ReduceInsets;
int GridSize, FolderCols, FolderRows;
NSUInteger cols, rows;

static void ReadGridSize(NSUserDefaults *defaults) {
    switch (GridSize) {
        case 0:
            cols = rows = 0;
            break;
        case 1:
            cols = 6;
            rows = 5;
            break;
        case 2:
            cols = 8;
            rows = 5;
            break;
        case 3:
            cols = 8;
            rows = 6;
            break;
        case 4:
            cols = 9;
            rows = 6;
            break;
        case 5:
            cols = 10;
            rows = 7;
            break;
        case 6:
            cols = 10;
            rows = 8;
            break;
        case 99: {
            int c = [defaults integerForKey:@"ColumnsKey"];
            int r = [defaults integerForKey:@"RowsKey"];
            if (c < 0) c = 0;
            if (r < 0) r = 0;
            cols = c;
            rows = r;
            break;
        }
    }
}

%group Legacy

%hook SBIconListView

+ (NSUInteger)iconColumnsForInterfaceOrientation:(NSInteger)orientation {
    if (cols && rows)
        return UIInterfaceOrientationIsLandscape(orientation) ? cols : rows;
    return %orig;
}

+ (NSUInteger)maxVisibleIconRowsInterfaceOrientation:(NSInteger)orientation {
    if (cols && rows)
        return UIInterfaceOrientationIsLandscape(orientation) ? rows : cols;
    return %orig;
}

%end

%end

%group Modern

%hook SBHDefaultIconListLayoutProvider

- (SBIconListGridLayout *)makeLayoutForIconLocation:(NSString *)iconLocation {
    SBIconListGridLayout *layout = %orig;
    if (@available(iOS 13.0, *)) {
        if ([iconLocation hasPrefix:@"SBIconLocationRoot"]) {
            SBIconListGridLayoutConfiguration *config = [layout valueForKey:@"_layoutConfiguration"];
            if (rows && cols) {
                config.numberOfLandscapeRows = rows;
                config.numberOfLandscapeColumns = cols;
                config.numberOfPortraitRows = cols;
                config.numberOfPortraitColumns = rows;
            }
            if (IS_IOS_OR_NEWER(iOS_15_0) && ReduceInsets) {
                UIEdgeInsets landscapeInsets = config.landscapeLayoutInsets;
                UIEdgeInsets portraitInsets = config.portraitLayoutInsets;
                landscapeInsets.left /= 2;
                landscapeInsets.right /= 2;
                portraitInsets.left /= 2;
                portraitInsets.right /= 2;
                config.landscapeLayoutInsets = landscapeInsets;
                config.portraitLayoutInsets = portraitInsets;
            }
        } else if ([iconLocation hasPrefix:@"SBIconLocationFolder"] && FolderRows && FolderCols) {
            SBIconListGridLayoutConfiguration *config = [layout valueForKey:@"_layoutConfiguration"];
            config.numberOfLandscapeRows = FolderRows;
            config.numberOfLandscapeColumns = FolderCols;
            config.numberOfPortraitRows = FolderCols;
            config.numberOfPortraitColumns = FolderRows;
        }
    }
    return layout;
}

%end

%end

%ctor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    GridSize = [defaults integerForKey:@"GridSizeKey"];
    ReadGridSize(defaults);
    FolderRows = [defaults integerForKey:@"FolderRowsKey"];
    FolderCols = [defaults integerForKey:@"FolderColsKey"];
    if (IS_IOS_OR_NEWER(iOS_14_0)) {
        ReduceInsets = [defaults boolForKey:@"ReduceInsetsKey"];
        %init(Modern);
    } else {
        %init(Legacy);
    }
}
