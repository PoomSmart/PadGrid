#define tweakIdentifier @"com.ps.padgrid"
#import "../PSPrefs/PSPrefs.x"
#import <SpringBoardHome/SBIconListGridLayout.h>
#import <SpringBoardHome/SBIconListGridLayoutConfiguration.h>
#import <version.h>

int GridSize;
NSUInteger cols, rows;

static void ReadGridSize() {
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
		}
	}
	return layout;
}

%end

%end

%ctor {
	GetPrefs();
    GetInt2(GridSize, 0);
	ReadGridSize();
	if (IS_IOS_OR_NEWER(iOS_14_0)) {
		%init(Modern);
	} else {
		%init(Legacy);
	}
}