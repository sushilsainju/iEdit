//
//  editFilesManagementViewController.m
//  iEditFast
//
//  Created by SUSHIL on 4/8/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "editFilesManagementViewController.h"
#import "FMMoveTableView.h"
#import "FMMoveTableViewCell.h"
#import "SharedStore.h"


#define bothChecked @"Both.png"
#define bothUnchecked @"Untick_Both.png"
#define compositeChecked @"composite.png"
#define compositeUnchecked @"Untick_Composite.png"
#define indChecked @"Single.png"
#define indUnchecked @"Untick_Single.png"

@interface editFilesManagementViewController ()

@property (assign, nonatomic) saveOptions saveAs;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView   *buttonsContainerView;


@end

@implementation editFilesManagementViewController

static NSString *sCellIdentifier;

#define kIndexNameOfMovie		0
#define kIndexYearOfMovie		1
#define kIndexRowHeightOfMovie  2


+ (void)initialize
{
    sCellIdentifier = @"MoveCell";
}

@synthesize chunksDelegate;
@synthesize editFilesArray;
@synthesize containerView,compositeContainerView,bothContainerView;
@synthesize buttonComposite,buttonIndividual,bothButton;
@synthesize compositeTableView,bothTableView;
@synthesize instructoinLaebl;
@synthesize saveAs;
@synthesize saveButton,cancelButton,buttonsContainerView;
NSString *saveFilesAs;

CGRect compositeContainerViewFrame,bothViewFrame;
CGRect compositebuttonFrame,bothButtonFrame,individualbuttonFrame,buttoncontainterVeiwFrame;
CGRect compositeTableViewFrame,bothTableViewFrame;

CGRect saveBtnFrame;
CGRect cancelBtnFrame;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        sCellIdentifier = @"MoveCell";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    saveAs=notSelected;
    [self.compositeTableView registerNib:[UINib nibWithNibName:@"editFilesTableViewCells" bundle:nil] forCellReuseIdentifier:@"MyCustomCell"];
    [self customizeView];
    
    NSLog(@"frame %f %f %f ",compositeContainerView.frame.size.height,compositeContainerView.frame.origin.x,compositeContainerView.frame.origin.y);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- CUSTOM FUNCTIONS

-(void)positoinSaveCancelButtons
{
    
}

-(void)toggleButtonImages:(saveOptions)option
{
    
    NSLog(@"savebttn %@",saveButton.titleLabel.text);
    saveBtnFrame=self.saveButton.frame;
    cancelBtnFrame=cancelButton.frame;
    saveBtnFrame.origin.x=50;
//    cancelBtnFrame.origin.y=0;
    switch (option)
    {
        case save_IndividualFiles:
        {
            saveButton.hidden=FALSE;
            cancelButton.hidden=FALSE;
            [buttonIndividual setImage:[UIImage imageNamed:indChecked] forState:UIControlStateNormal ];
            [buttonComposite setImage:[UIImage imageNamed:compositeUnchecked] forState:UIControlStateNormal ];
            [bothButton setImage:[UIImage imageNamed:bothUnchecked] forState:UIControlStateNormal ];
            saveBtnFrame.origin.y=buttonIndividual.frame.origin.y+buttonIndividual.frame.size.height-10;
            cancelBtnFrame.origin.y=saveBtnFrame.origin.y;
            saveButton.frame=saveBtnFrame;
            cancelButton.frame=cancelBtnFrame;

            break;
        }
            
        case save_compositeFile:
        {
            saveButton.hidden=FALSE;
            cancelButton.hidden=FALSE;
            [buttonIndividual setImage:[UIImage imageNamed:indUnchecked] forState:UIControlStateNormal ];
            [buttonComposite setImage:[UIImage imageNamed:compositeChecked] forState:UIControlStateNormal ];
            [bothButton setImage:[UIImage imageNamed:bothUnchecked] forState:UIControlStateNormal ];
            saveBtnFrame.origin.y=compositeContainerView.frame.origin.y+compositeContainerView.frame.size.height-14;
            cancelBtnFrame.origin.y=saveBtnFrame.origin.y;
            saveButton.frame=saveBtnFrame;
            cancelButton.frame=cancelBtnFrame;

            
            break;
        }
        case save_Both:
        {
            saveButton.hidden=FALSE;
            cancelButton.hidden=FALSE;
            [buttonIndividual setImage:[UIImage imageNamed:indUnchecked] forState:UIControlStateNormal ];
            [buttonComposite setImage:[UIImage imageNamed:compositeUnchecked] forState:UIControlStateNormal ];
            [bothButton setImage:[UIImage imageNamed:bothChecked] forState:UIControlStateNormal ];
            saveBtnFrame.origin.y=bothContainerView.frame.origin.y+bothContainerView.frame.size.height-10;
            cancelBtnFrame.origin.y=saveBtnFrame.origin.y;
            saveButton.frame=saveBtnFrame;
            cancelButton.frame=cancelBtnFrame;
            
            
            break;
        }
        case notSelected:
        {
            [buttonIndividual setImage:[UIImage imageNamed:indUnchecked] forState:UIControlStateNormal ];
            [buttonComposite setImage:[UIImage imageNamed:compositeUnchecked] forState:UIControlStateNormal ];
            [bothButton setImage:[UIImage imageNamed:bothUnchecked] forState:UIControlStateNormal ];
            saveButton.hidden=TRUE;
            cancelButton.hidden=TRUE;
            break;
        }

        default:
            break;
    }
    
}

-(void)rearrangeViews
{
    saveBtnFrame=saveButton.frame;
    cancelBtnFrame=cancelButton.frame;
    saveBtnFrame.size.height=30;
    individualbuttonFrame = buttonIndividual.frame;
    individualbuttonFrame.origin.y=IOS_Delta+8;
    buttonIndividual.frame=individualbuttonFrame;

    compositebuttonFrame = buttonComposite.frame;
    if (saveAs==save_IndividualFiles)
       compositebuttonFrame.origin.y=saveBtnFrame.origin.y+saveBtnFrame.size.height+5;
    else
       compositebuttonFrame.origin.y=individualbuttonFrame.origin.y+individualbuttonFrame.size.height+8;
   
    buttonComposite.frame=compositebuttonFrame;
    
    compositeContainerViewFrame = compositeContainerView.frame;
    compositeTableViewFrame=compositeTableView.frame;
    bothTableViewFrame=bothTableView.frame;
    compositeTableViewFrame.size.height=compositeContainerViewFrame.size.height-30;
    compositeTableViewFrame.size.width=compositeContainerViewFrame.size.width-10;
    compositeTableViewFrame.origin.x=0;
    compositeTableViewFrame.origin.y=5;
    compositeTableView.frame=compositeTableViewFrame;
    bothViewFrame = bothContainerView.frame;
    
    compositeContainerViewFrame.origin.y = compositebuttonFrame.origin.y+compositebuttonFrame.size.height;
    compositeContainerView.frame = compositeContainerViewFrame;
    
    bothButtonFrame=bothButton.frame;
    if(saveAs==save_compositeFile)
        bothButtonFrame.origin.y=saveBtnFrame.origin.y+saveBtnFrame.size.height+5;
    else
        bothButtonFrame.origin.y=compositeContainerViewFrame.origin.y+compositeContainerViewFrame.size.height+8;
    bothButton.frame=bothButtonFrame;
    
    bothViewFrame.origin.y=253;//bothButtonFrame.origin.y+bothButtonFrame.size.height;
    bothContainerView.frame=bothViewFrame;
    
    bothTableViewFrame.size.height=bothViewFrame.size.height-30;
    bothTableViewFrame.size.width=bothViewFrame.size.width-10;
    bothTableViewFrame.origin.x=0;
    bothTableViewFrame.origin.y=5;
    
    bothTableView.frame=bothTableViewFrame;
}
-(void)customizeView
{
    self.navigationController.navigationBar.hidden = NO;
//    [bothTableView setHidden:YES];
//    [compositeTableView setHidden:YES];
    [self rearrangeViews];
    bothButtonFrame=bothButton.frame;
    bothButtonFrame.origin.y=compositebuttonFrame.origin.y+compositebuttonFrame.size.height+10;
    bothButton.frame=bothButtonFrame;
    
    NSMutableArray *mutableTFs = [[NSMutableArray alloc] init];
    for (UIView *view in [containerView subviews]) {
        if ([view isKindOfClass:[UIView class]])
        {
            if (view!=buttonsContainerView) {
                [mutableTFs addObject:view];
                view.layer.masksToBounds=YES;
                view.layer.borderColor=ViewBorder_color;//[[UIColor colorWithRed:146.0f/255.0f green:146.0f/255.0f blue:146.0f/255.0f alpha:1.0] CGColor];
                view.layer.borderWidth= 0.5f;
                view.layer.sublayerTransform=CATransform3DMakeTranslation(5, 0, 0);
            }
            
            
        }
    }
 
    buttonsContainerView.hidden=TRUE;

    
//    [compositeContainerView whenTapped:^{
//		[self toggleView:compositeContainerView.tag ];
//        [self rearrangeViews];
//	}];
//    
//    [bothContainerView whenTapped:^{
//		[self toggleView:bothContainerView.tag ];
//        [self rearrangeViews];
//
//	}];
    
    [self addSaveCancelButtons ];
    bothViewFrame.size.height=0;
    compositeContainerViewFrame.size.height=0;
    bothContainerView.frame=bothViewFrame;
    compositeContainerView.frame=compositeContainerViewFrame;

    
}


-(void)addSaveCancelButtons
{
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame=CGRectMake(33,100,100,30);
    [saveButton setTitle:@"Done" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [saveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [saveButton setBackgroundColor:[UIColor colorWithRed:57.0/255.0 green:57.0/255.0 blue:57.0 /255.0 alpha:1.0f]];
    [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame=CGRectMake(166,100,100,30);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [cancelButton setBackgroundColor:[UIColor colorWithRed:57.0/255.0 green:57.0/255.0 blue:57.0 /255.0 alpha:1.0f]];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:saveButton];
    [self.view addSubview:cancelButton];
    saveButton.hidden=TRUE;
    cancelButton.hidden=TRUE;


}


- (void)saveAction
{
    //sagar fix for double clicking the both and composite file when saving edit m4a files
    bothisShown = false;
    compositeisShown = false;
    [self dismissViewControllerAnimated:YES completion:nil];
    
   
        if([self.chunksDelegate respondsToSelector:@selector(manageChunkFiles:andSaveOption:)])
        {
            
            [self.chunksDelegate manageChunkFiles:editFilesArray andSaveOption:saveFilesAs];
        }
    
}



- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if([self.chunksDelegate respondsToSelector:@selector(ignoreChunkFiles:)])
    {
        
        [self.chunksDelegate ignoreChunkFiles:editFilesArray];
    }

}


- (void)goback
{
    [self.navigationController popViewControllerAnimated:YES];
}

bool compositeisShown = false;
bool bothisShown = false;

-(void)toggleView:(NSInteger)viewTag
{
    
   
    UIView *tappedView=(UIView *)[self.view viewWithTag:viewTag];
    CGRect compositContainer=tappedView.frame;

    
    if (!compositeisShown)
    {
        
        compositContainer.size.height=200;
        [UIView animateWithDuration:0.25 animations:^{
            
            tappedView.frame =  compositContainer;
        }];
        tappedView.frame = compositContainer;
        compositeisShown = true;
    }
    else
    {
        compositContainer.size.height=0;
        [UIView animateWithDuration:0.25 animations:^{
            tappedView.frame =  compositContainer;
        }];
        tappedView.frame = compositContainer;
        compositeisShown = false;
    }
   }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger numberOfRows = editFilesArray.count;
	
#warning Implement this check in your table data source
	/******************************** NOTE ********************************
	 * Implement this check in your table view data source to ensure correct access to the data source
	 *
	 * The data source is in a dirty state when moving a row and is only being updated after the user
	 * releases the moving row
	 **********************************************************************/
	
	// 1. A row is in a moving state
	// 2. The moving row is not in it's initial section
	if (tableView.movingIndexPath && tableView.movingIndexPath.section != tableView.initialIndexPathForMovingRow.section)
	{
		if (section == tableView.movingIndexPath.section) {
			numberOfRows++;
		}
		else if (section == tableView.initialIndexPathForMovingRow.section) {
			numberOfRows--;
		}
	}
	
	return numberOfRows;
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return [NSString stringWithFormat:@"Section %i", section];
//}


- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellMainNibID = @"editFilesTableViewCells";
    
    FMMoveTableViewCell *cell = (FMMoveTableViewCell *)[compositeTableView dequeueReusableCellWithIdentifier:cellMainNibID];
    if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"editFilesTableViewCells" owner:nil options:nil];
		for (id currentObject in topLevelObjects) {
			if([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (FMMoveTableViewCell *) currentObject;
			}
		}
    }
    
//    [self configureCell:cell atIndexPath:indexPath];
    
//    return cell;
    
#warning Implement this check in your table view data source
	/******************************** NOTE ********************************
	 * Implement this check in your table view data source to ensure that the moving
	 * row's content is being reseted
	 **********************************************************************/
	if ([tableView indexPathIsMovingIndexPath:indexPath])
	{
		[cell prepareForMove];
	}
	else
	{
#warning Implement this check in your table view data source
		/******************************** NOTE ********************************
		 * Implement this check in your table view data source to ensure correct access to the data source
		 *
		 * The data source is in a dirty state when moving a row and is only being updated after the user
		 * releases the moving row
		 **********************************************************************/
		if (tableView.movingIndexPath != nil)
        {
            indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
		}
		NSMutableDictionary *editFile = [editFilesArray objectAtIndex:indexPath.row];
        cell.title.text = [editFile valueForKey:EDITFILES_param_chunkName];
        cell.duration.text=[editFile valueForKey:EDITFILES_param_duration];
        cell.shouldIndentWhileEditing = NO;
        cell.showsReorderControl = NO;
	}
    
	return cell;
}


//-(void)configureCell:(iEditLibraryCell *)cell atIndexPath:(NSIndexPath *)indexPath
//{
//    
//    
//    NSString *duration= [ self getDuration:recording.filepath];
//    NSString* theFileName = [recording.filepath lastPathComponent] ;
//    NSString *nametoShow=[self namewithoutExtensoin:recording.filename];
//    cell.title.text =nametoShow;
//    cell.duration.text=duration;
//    self.LibraryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [recordingsArray addObject:theFileName];
//    [recordingNamesArray addObject:nametoShow];
//    
//    
//}


- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}


- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	NSArray *record = [editFilesArray objectAtIndex:fromIndexPath.row];
	[editFilesArray removeObjectAtIndex:fromIndexPath.row];
	[editFilesArray insertObject:record atIndex:toIndexPath.row];
	
	NSLog(@"Moved row from %@ to %@", fromIndexPath, toIndexPath);
}



#pragma mark - Table view delegate

- (CGFloat)tableView:(FMMoveTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning Implement this check in your table view delegate if necessary
    /******************************** NOTE ********************************
     * Implement this check in your table view delegate to ensure correct access to the row heights in
     * data source.
     *
     * SKIP this check if all of your rows have the same heigt!
     *
     * The data source is in a dirty state when moving a row and is only being updated after the user
     * releases the moving row
     **********************************************************************/
//    indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
//	
//    NSArray *movie = [[editFilesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    CGFloat heightForRow = [[movie objectAtIndex:kIndexRowHeightOfMovie] floatValue];
    
    return 40;
}


- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	//	Uncomment these lines to enable moving a row just within it's current section
	//	if ([sourceIndexPath section] != [proposedDestinationIndexPath section]) {
	//		proposedDestinationIndexPath = sourceIndexPath;
	//	}
	
	return proposedDestinationIndexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	NSLog(@"Did select row at %@", indexPath);
}


#pragma mark - IBACTOIN METHODS

- (IBAction)compositeButtonClicked:(id)sender
{
    CGRect Frame;
    Frame=compositeContainerView.frame;
    if (!compositeisShown)
    {
        
        Frame.size.height=200;
        bothViewFrame.size.height=0;
        [UIView animateWithDuration:0.25 animations:^{
            compositeContainerView.frame =  Frame;
            bothContainerView.frame=bothViewFrame;

        }];
        saveAs=save_compositeFile;
        saveFilesAs=optioncompositeFile;
        compositeisShown = true;
        bothisShown=false;
    }
    else
    {
        Frame.size.height=0;
//        bothViewFrame.size.height=250;

        [UIView animateWithDuration:0.25 animations:^{
            compositeContainerView.frame =  Frame;
//            bothContainerView.frame=bothViewFrame;
        }];
        compositeisShown = false;
        saveAs=notSelected;


    }
    [compositeTableView reloadData];
    [self toggleButtonImages:saveAs ];
    [self rearrangeViews];

    NSLog(@"COMP save as %u",saveAs);
}

- (IBAction)individualFilesButtonClicked:(id)sender
{
    if (saveAs==save_IndividualFiles)
    {
        saveAs=notSelected;

    }
    else
    {

        saveAs=save_IndividualFiles;
        saveFilesAs=optionIndividualFiles;

    }
    compositeContainerViewFrame.size.height=0;
    bothViewFrame.size.height=0;
    compositeContainerView.frame=compositeContainerViewFrame;
    bothContainerView.frame=bothViewFrame;
    compositeisShown=false;
    bothisShown=false;
    NSLog(@" INDIV save as %u",saveAs);
    [self toggleButtonImages:saveAs ];
    [self   rearrangeViews];

}

- (IBAction)bothButtonClicked:(id)sender
{
    CGRect Frame;
    Frame=bothContainerView.frame;
    if (!bothisShown)
    {
        
        Frame.size.height=200;
        compositeContainerViewFrame.size.height=0;
        [UIView animateWithDuration:0.25 animations:^{
            bothContainerView.frame =  Frame;
            compositeContainerView.frame=compositeContainerViewFrame;
        }];
        bothisShown=true;
        saveAs=save_Both;
        saveFilesAs=optionBoth;

        compositeisShown=false;
    }
    else
    {
        Frame.size.height=0;
//        compositeContainerViewFrame.size.height=250;

        [UIView animateWithDuration:0.25 animations:^{
            bothContainerView.frame =  Frame;
//            compositeContainerView.frame=compositeContainerViewFrame;
            //sagar maharjan hot fix for double clicking both button on saving edit file
            saveAs=notSelected;

        }];
        bothisShown = false;

    }
    [bothTableView reloadData];
    [self toggleButtonImages:saveAs ];
    [self rearrangeViews];


    NSLog(@" BOTH save as %u",saveAs);

}

- (IBAction)savebuttonClicked:(id)sender {
    [self saveAction];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self cancelAction];
}
@end
