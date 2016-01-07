//
//  TYDKFilePickerWindowsController.m
//  TYDKSynxPlugin
//
//  Created by 李浩然 on 1/7/16.
//  Copyright © 2016 tydic-lhr. All rights reserved.
//

#import "TYDKFilePickerWindowsController.h"

@interface TYDKFilePickerWindowsController () <NSTableViewDelegate,NSTableViewDataSource>
{
    NSMutableArray *ArrayCommonPara;
    NSMutableArray *ArraySelPara;
    NSMutableArray *ArrayPopupPara;
}
@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation TYDKFilePickerWindowsController

//- (void)awakeFromNib {
// 
//    
//}


- (void)windowDidLoad {
    [super windowDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    ArrayCommonPara=[[NSMutableArray alloc] init];
    [ArrayCommonPara removeAllObjects];
    NSInteger i;
    NSString *nsTemp;
    for(i=0;i<10;i++){
        nsTemp=[NSString stringWithFormat:@"name of %02d",i];
        [ArrayCommonPara addObject:nsTemp];
    }
    
    ArraySelPara=[[NSMutableArray alloc] init];
    [ArraySelPara removeAllObjects];
    for(i=0;i<10;i++){
        if(i%2==0){
            nsTemp=@"1";
            [ArraySelPara addObject:nsTemp];
        }
        else{
            nsTemp=@"0";
            [ArraySelPara addObject:nsTemp];
        }
    }
    ArrayPopupPara=[[NSMutableArray alloc] init];
    [ArrayPopupPara removeAllObjects];
    for(i=0;i<10;i++){
        nsTemp=[NSString stringWithFormat:@"%d",i];
        [ArrayPopupPara addObject:nsTemp];
    }
    [self.tableView reloadData];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - tableview delegate 
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [ArrayCommonPara count];
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    

    
    NSString *strIdt = [tableColumn identifier];
    if([strIdt isEqualToString:@"name"]){
        NSString *nsTemp=(NSString*)[ArrayCommonPara objectAtIndex:row];
        return nsTemp;
    }
    else if([strIdt isEqualToString:@"value"]){
        NSButtonCell* cell = [tableColumn dataCellForRow:row];
        [cell setTag:row];
        [cell setAction:@selector(CellClick:)];
        [cell setTarget:self];
        NSInteger nTemp;
        cell.title = [NSString stringWithFormat:@"check button %@",@(row)];
        NSString *nsTemp=(NSString*)[ArraySelPara objectAtIndex:row];
        nTemp=[nsTemp intValue];
        [cell setState:nTemp];
        
        return cell;
    }
    else{
        NSPopUpButtonCell* pcell = [tableColumn dataCellForRow:row];
        [pcell removeAllItems];
        for(int i=0;i<=10;i++){
            [pcell addItemWithTitle:[NSString stringWithFormat:@"%d",i]];
        }
        //[pcell selectItemWithTitle:(NSString *)[ArrayPopupPara objectAtIndex:row]];
        //[pcell setTag:row];
        //[pcell setTarget:self];
        
        return (NSString *)[ArrayPopupPara objectAtIndex:row];
    }
    
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    
    NSString *strIdt=[aTableColumn identifier];
    if([strIdt isEqualToString:@"value"]){
        NSString *nsTemp=(NSString*)[ArraySelPara objectAtIndex:rowIndex];
        if([nsTemp isEqualToString:@"1"])
            nsTemp=@"0";
        else
            nsTemp=@"1";
        [ArraySelPara replaceObjectAtIndex:rowIndex withObject:nsTemp];
    }
    else if([strIdt isEqualToString:@"name"]){
        NSString *nsT=(NSString*)anObject;
        NSLog(@"*******%@",nsT);
        [ArrayCommonPara replaceObjectAtIndex:rowIndex withObject:anObject];
    }
    else{
        //NSNumber* pcell = (NSNumber *)anObject;
        //NSLog(@"*******%@",anObject);
        //NSString *nsT=[NSString stringWithFormat:@"%d",pcell];
        [ArrayPopupPara replaceObjectAtIndex:rowIndex withObject:anObject];
    }
}


-(void)CellClick:(id)sender{
    //if(sender!=nil){
    NSButtonCell* cell=(NSButtonCell *)[_tableView selectedCell];
    if([cell state]==1)
        [cell setState:0];
    else {
        [cell setState:1];
    }
    
    
    NSLog(@"CellClick=%ld",[_tableView selectedCell].tag);
    //}
}

@end
