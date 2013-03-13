#import <Foundation/Foundation.h>

#import "TLBaseController.h"

@protocol TLTChatControllerDelegate;

@interface TLTChatController: TLBaseController

- (id)initWithDelegate:(id<TLTChatControllerDelegate>)theDelegate;
- (void)populateMessagesForBuddyAccountName:(NSString *)accountName;
- (NSData *)getAvatarForAccountName:(NSString *)accountName;
- (NSInteger)messageLogCount;
- (NSDictionary *)messageAtIndex:(NSInteger)index;
- (void)setMessagesAsRead;
- (void)sendTmojiImage:(NSString *)imageName;
- (void)sendMediaPhoto:(NSData *)imageData;
- (void)sendMediaVideo:(NSData *)videoData;

// Actions
- (void)sendTextMessage;
- (void)backButtonAction;
- (void)tmojiButtonAction;
- (void)mediaButtonAction;

@end

@protocol TLTChatControllerDelegate <TLBaseControllerDelegate>

@required
- (void)controllerGotBackButtonAction:(TLTChatController *)controller;
- (void)controllerGotTmojiButtonAction:(TLTChatController *)controller;
- (void)controllerGotMediaButtonAction:(TLTChatController *)controller;
- (NSUInteger)controllerNeedMessageLength:(TLTChatController *)controller;
- (NSString *)controllerNeedMessageText:(TLTChatController *)controller;
- (NSString *)controllerNeedAccountName:(TLTChatController *)controller;
- (NSString *)controllerNeedDisplayName:(TLTChatController *)controller;
- (void)controllerDidSendMessage:(TLTChatController *)controller;
- (void)controllerDidReceivedMessage:(TLTChatController *)controller;
- (void)controllerDidUpdateAvatar:(TLTChatController *)controller;
- (void)            controller:(TLTChatController *)controller
  keyboardWillShowWithUserInfo:(NSDictionary *)userInfo;
- (void)            controller:(TLTChatController *)controller
  keyboardWillHideWithUserInfo:(NSDictionary *)userInfo;
- (void)controllerDidReceivedResignedActive:(TLTChatController *)controller;
@end
