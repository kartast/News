//
// RSSParser.h
// RSSKit
//
// Created by Árpád Goretity on 01/11/2011.
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import <Foundation/Foundation.h>
#import "RSSDefines.h"
#import "RSSFeed.h"
#import "RSSEntry.h"

@class RSSParser;
typedef void (^RSSParserCompletionBlock)(RSSParser*, RSSFeed*, NSError *);

@protocol RSSParserDelegate;

@interface RSSParser: NSObject <NSXMLParserDelegate> {
	NSString *url;
	NSXMLParser *xmlParser;
	NSMutableArray *tagStack;
	NSMutableString *tagPath;
	RSSFeed *feed;
	RSSEntry *entry;
	id <RSSParserDelegate> delegate;
    RSSParserCompletionBlock completionBlock;
}

@property (copy) RSSParserCompletionBlock completionBlock;
@property (nonatomic, retain) id <RSSParserDelegate> delegate;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) BOOL synchronous;

- (id) initWithUrl:(NSString *)theUrl synchronous:(BOOL)sync;
- (id) initWithUrl:(NSString *)theUrl;
- (void)parse;
- (void)parseWithCompletionCallback:(RSSParserCompletionBlock) block;
- (void)parseData:(NSData *)rssData withCallback:(RSSParserCompletionBlock) block;

@end


@protocol RSSParserDelegate <NSObject>
@optional
- (void) rssParser:(RSSParser *)parser parsedFeed:(RSSFeed *)feed;
- (void) rssParser:(RSSParser *)parser errorOccurred:(NSError *)error;
@end

