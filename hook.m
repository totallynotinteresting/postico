#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static BOOL patch_isLicenseProductValid(id self, SEL _cmd, id product) {
  return YES;
}

static BOOL patch_isLicenseValid(id self, SEL _cmd) { return YES; }

static BOOL patch_isTrial(id self, SEL _cmd) { return NO; }

__attribute__((constructor)) static void initialise(void) {
  Class pgeLicenseManager = NSClassFromString(@"PGELicenseManager");

  if (pgeLicenseManager) {
    SEL originalSelector = @selector(isLicenseProductValid:);
    IMP patchImplementation = (IMP)patch_isLicenseProductValid;
    Method originalMethod =
        class_getInstanceMethod(pgeLicenseManager, originalSelector);

    if (originalMethod) {
      const char *typeEncoding = method_getTypeEncoding(originalMethod);
      IMP originalIMP = method_getImplementation(originalMethod);
      IMP previousIMP = class_replaceMethod(pgeLicenseManager, originalSelector,
                                            patchImplementation, typeEncoding);
      Method checkMethod =
          class_getInstanceMethod(pgeLicenseManager, originalSelector);
      IMP currentIMP = method_getImplementation(checkMethod);
      if (currentIMP == patchImplementation) {
        printf("swizzle confirmed\n");
      } else {
        printf("swizzle failed\n");
      }
    } else {
      printf("could not find method isLicenseProductValid\n");
    }
    SEL validSelector = @selector(isLicenseValid);
    Method validMethod =
        class_getInstanceMethod(pgeLicenseManager, validSelector);
    if (validMethod) {
      const char *validType = method_getTypeEncoding(validMethod);
      IMP validPatchIMP = (IMP)patch_isLicenseValid;
      IMP validPrev = class_replaceMethod(pgeLicenseManager, validSelector,
                                          validPatchIMP, validType);
      IMP validNow = method_getImplementation(
          class_getInstanceMethod(pgeLicenseManager, validSelector));
      if (validNow == validPatchIMP) {
        printf("swizzle confirmed for isLicenseValid\n");
      } else {
        printf("swizzle failed for isLicenseValid\n");
      }
    } else {
      printf("could not find method isLicenseValid\n");
    }
    SEL trialSelector = @selector(isTrial);
    Method trialMethod =
        class_getInstanceMethod(pgeLicenseManager, trialSelector);
    if (trialMethod) {
      const char *trialType = method_getTypeEncoding(trialMethod);
      IMP trialPatchIMP = (IMP)patch_isTrial;
      IMP trialPrev = class_replaceMethod(pgeLicenseManager, trialSelector,
                                          trialPatchIMP, trialType);
      IMP trialNow = method_getImplementation(
          class_getInstanceMethod(pgeLicenseManager, trialSelector));
      if (trialNow == trialPatchIMP) {
        printf("swizzle confirmed for isTrial\n");
      } else {
        printf("swizzle failed for isTrial\n");
      }
    } else {
      printf("could not find method isTrial\n");
    }
  } else {
    printf("could not find PGELicenseManager class\n");
  }
}