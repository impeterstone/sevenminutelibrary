//
//  PSTextField.h
//  Moogle
//
//  Created by Peter Shih on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSTextField : UITextField {
  CGSize _inset;
}

- (id)initWithFrame:(CGRect)frame withInset:(CGSize)inset;

@end
