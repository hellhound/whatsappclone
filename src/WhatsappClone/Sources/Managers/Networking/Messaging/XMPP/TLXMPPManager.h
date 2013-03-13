#import <Foundation/Foundation.h>

#import <XMPPFramework.h>

#import "../TLProtocolManager.h"

@interface TLXMPPManager: NSObject <TLProtocol, TLProtocolBridge,
    XMPPStreamDelegate, XMPPRosterMemoryStorageDelegate>
@end
