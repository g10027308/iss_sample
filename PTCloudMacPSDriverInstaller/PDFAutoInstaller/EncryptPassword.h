//
//  EncryptPassword.h
//  theResult
//
//  Created by g10027308 on 2023/02/01.
//  Copyright © 2023 rits. All rights reserved.
//

#ifndef EncryptPassword_h
#define EncryptPassword_h


#endif /* EncryptPassword_h */

@interface EncryptPassword : NSObject

- (NSData *)getEncryptPassword:(NSString *)strPassword userid:(NSString *)userid;
- (NSString *)getDecryptPassword:(NSData *)password userid:(NSString *)userid;

@end
