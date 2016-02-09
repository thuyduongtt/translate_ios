/**
 * Autogenerated by Thrift Compiler (0.9.3)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */

#import <Foundation/Foundation.h>

#import "TProtocol.h"
#import "TApplicationException.h"
#import "TProtocolException.h"
#import "TProtocolUtil.h"
#import "TProcessor.h"
#import "TObjective-C.h"
#import "TBase.h"
#import "TAsyncTransport.h"
#import "TProtocolFactory.h"
#import "TBaseClient.h"


//typedef NSString * ThriftString;

typedef int int32_t;

@interface User : NSObject <TBase, NSCoding> {
  NSString * __username;
  NSString * __password;
  NSString * __email;

  BOOL __username_isset;
  BOOL __password_isset;
  BOOL __email_isset;
}

#if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
@property (nonatomic, retain, getter=username, setter=setUsername:) NSString * username;
@property (nonatomic, retain, getter=password, setter=setPassword:) NSString * password;
@property (nonatomic, retain, getter=email, setter=setEmail:) NSString * email;
#endif

- (id) init;
- (id) initWithUsername: (NSString *) username password: (NSString *) password email: (NSString *) email;

- (void) read: (id <TProtocol>) inProtocol;
- (void) write: (id <TProtocol>) outProtocol;

- (void) validate;

#if !__has_feature(objc_arc)
- (NSString *) username;
- (void) setUsername: (NSString *) username;
#endif
- (BOOL) usernameIsSet;

#if !__has_feature(objc_arc)
- (NSString *) password;
- (void) setPassword: (NSString *) password;
#endif
- (BOOL) passwordIsSet;

#if !__has_feature(objc_arc)
- (NSString *) email;
- (void) setEmail: (NSString *) email;
#endif
- (BOOL) emailIsSet;

@end

@protocol TranslationService <NSObject>
- (int) userRegister: (User *) user;  // throws TException
- (int) userLogin: (User *) user;  // throws TException
@end

@interface TranslationServiceClient : TBaseClient <TranslationService> - (id) initWithProtocol: (id <TProtocol>) protocol;
- (id) initWithInProtocol: (id <TProtocol>) inProtocol outProtocol: (id <TProtocol>) outProtocol;
@end

@interface TranslationServiceProcessor : NSObject <TProcessor> {
  id <TranslationService> mService;
  NSDictionary * mMethodMap;
}
- (id) initWithTranslationService: (id <TranslationService>) service;
- (id<TranslationService>) service;
@end

@interface translateConstants : NSObject {
}
@end
