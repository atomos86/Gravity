//
//  GDIBoundTextView.m
//  Gravity
//
//  Created by Grant Davis on 6/20/12.
//  Copyright (c) 2012 Grant Davis Interactive, LLC. All rights reserved.
//

#import "GDIBoundTextView.h"

@interface GDIBoundTextView () {
    BOOL _isSettingText;
    __weak NSObject *_boundObject;
    NSString *_boundKeypath;
}

- (void)updateBoundObjectValue;
- (void)updateTextByTrimmingIfNecessary;

@end

@implementation GDIBoundTextView
@synthesize shouldTrimInput;
@synthesize placeholder;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        shouldTrimInput = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        shouldTrimInput = YES;
    }
    return self;
}


- (void)bindTextToObject:(NSObject *)obj keyPath:(NSString *)keypath
{
    // remove bind to previous object
    [self removeBind];
    
    // store references
    _boundObject = obj;
    _boundKeypath = keypath;
    
    // bind to new object
    if (_boundObject && _boundKeypath) {
        
        // register KVO observer
        [_boundObject addObserver:self forKeyPath:_boundKeypath options:NSKeyValueObservingOptionNew context:nil];
        
        // set our text to the value of our object's keypath
        [super setText:[_boundObject valueForKey:_boundKeypath]];
    }
}


- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updateBoundObjectValue];
}


- (void)dealloc
{
    [self removeBind];
}


- (void)removeBind
{
    if (_boundObject && _boundKeypath) {
        [_boundObject removeObserver:self forKeyPath:_boundKeypath];
    }
    _boundObject = nil;
    _boundKeypath = nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:_boundKeypath] && !_isSettingText) {
        NSString *newText = [change objectForKey:NSKeyValueChangeNewKey];
        super.text = newText;
    }
}


- (void)updateBoundObjectValue
{
    if (_boundObject && _boundKeypath && ![self.text isEqualToString:self.placeholder]) {
        NSString *storedValue = [_boundObject valueForKey:_boundKeypath];
        if (![storedValue isEqualToString:self.text]) {
            _isSettingText = YES;   
            NSString *text = shouldTrimInput ? [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
            : self.text;
            [_boundObject setValue:text forKey:_boundKeypath];
            _isSettingText = NO;
        }
    }
}

- (void)updateTextByTrimmingIfNecessary
{
    if (shouldTrimInput && self.text && ![self.text isEqualToString:self.placeholder]) {
        super.text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}


- (BOOL)resignFirstResponder
{
    [self updateBoundObjectValue];
    [self updateTextByTrimmingIfNecessary];
    return [super resignFirstResponder];
}

@end