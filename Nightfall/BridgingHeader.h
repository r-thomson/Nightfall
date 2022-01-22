#import <objc/NSObject.h>

BOOL SLSGetAppearanceThemeLegacy();
void SLSSetAppearanceThemeLegacy(BOOL);
void SLSSetAppearanceThemeNotifying(BOOL, BOOL);

typedef void (^NSGlobalPreferenceTransitionBlock)(void);

@interface NSGlobalPreferenceTransition : NSObject

+ (id)transition;
- (void)waitForTransitionWithCompletionHandler:(NSGlobalPreferenceTransitionBlock)arg1;
- (void)postChangeNotification:(unsigned long long)arg1 completionHandler:(NSGlobalPreferenceTransitionBlock)arg2;

@end
