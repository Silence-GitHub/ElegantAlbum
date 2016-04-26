//
//  EAPhoto.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/24.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAPhoto.h"
#import "EAAlbum.h"

@implementation EAPhoto

- (void)updateNote:(NSString *)note {
    
    self.note = note;
    NSDate *now = [NSDate date];
    self.modificationDate = now;
    
    for (EAAlbum *album in self.albums) {
        album.modificationDate = now;
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
    }
}

- (NSString *)description {
    NSString *str = @"EAPhoto:\n";
    
    str = [str stringByAppendingString:[NSString stringWithFormat:@"URL: %@", self.url]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    if (self.creationDate) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"\nCreation date: %@", [formatter stringFromDate:self.creationDate]]];
    }
    
    if (self.longitude.doubleValue || self.latitude.doubleValue) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"\nLocation coordinate: lng = %@, lat = %@", self.longitude, self.latitude]];
    }
    
    if (self.address) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"\nAddress: %@", self.address]];
    }
    
    if (self.note) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"\nNote: %@\nModification date: %@", self.note, [formatter stringFromDate:self.modificationDate]]];
        
    }
    
    return str;
}

@end
