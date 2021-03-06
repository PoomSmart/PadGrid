#define tweakIdentifier @"com.ps.padgrid"
#import "../PSPrefs/PSPrefs.x"
#import <SpringBoardHome/SBIconListGridLayout.h>
#import <SpringBoardHome/SBIconListGridLayoutConfiguration.h>
#import <version.h>

int GridSize, FolderCols, FolderRows;
NSUInteger cols, rows;

static void ReadGridSize(NSDictionary *PSSettings) {
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
            int c, r;
            GetInt(c, Columns, 0);
            GetInt(r, Rows, 0);
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
        if ([iconLocation hasPrefix:@"SBIconLocationRoot"] && rows && cols) {
            SBIconListGridLayoutConfiguration *config = [layout valueForKey:@"_layoutConfiguration"];
            config.numberOfLandscapeRows = rows;
            config.numberOfLandscapeColumns = cols;
            config.numberOfPortraitRows = cols;
            config.numberOfPortraitColumns = rows;
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
    GetPrefs();
    GetInt2(GridSize, 0);
    ReadGridSize(PSSettings);
    GetInt2(FolderRows, 0);
    GetInt2(FolderCols, 0);
    if (IS_IOS_OR_NEWER(iOS_14_0)) {
        %init(Modern);
    } else {
        %init(Legacy);
    }
}