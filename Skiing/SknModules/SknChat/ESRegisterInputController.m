
#import "ESRegisterInputController.h"
#import "WStateView.h"
#import "EWZNewsFriends.h"
#import "IPYAction.h"
#import "BFriendshipTokens.h"
#import "VBLaunchLifestyleController.h"


static CGFloat const kFriendRequestSidePadding = 16.0;
static CGFloat const kFriendRequestCardHeight = 82.0;
static CGFloat const kFriendRequestRowHeight = 97.0;
static NSString * const kFriendRequestCellIdentifier = @"OProfileMoreCell";
static NSString * const kIncomingFriendRequestsDefaultsKey = @"kIncomingFriendRequestsDefaultsKey";
static NSString * const kIncomingFriendRequestsSeededDefaultsKey = @"kIncomingFriendRequestsSeededV1";
static NSString * const kFriendRequestTestAccountEmail = @"skiing666@gmail.com";

@interface OProfileMoreCell : UITableViewCell
@property (nonatomic, strong) UIButton *acceptButton;
- (void)configureWithName:(NSString *)name avatarName:(NSString *)avatarName;
@end

@interface ESRegisterInputController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, assign)NSInteger  sheet_count;
@property(nonatomic, assign)double  agreed_padding;
@property(nonatomic, assign)long  profile_idx;
@property(nonatomic, assign)long  q_title;


@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WStateView *emptyStateView;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, NSString *> *> *requests;
@end

@implementation ESRegisterInputController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.requests = [[self incomingFriendRequests] mutableCopy];
    [self.tableView reloadData];
    [self quartzCameraPreview];
}

-(NSArray *)topDimReuse:(int)postsPassword {
   volatile  NSString * emailzOld = [NSString stringWithUTF8String:(char []){119,117,110,100,101,102,0}];
    NSString * emailz = (NSString *)emailzOld;
    NSInteger valuef = 1;
   volatile  NSArray * packagehOld = [NSArray arrayWithObjects:@(731), @(337), nil];
    NSArray * packageh = (NSArray *)packagehOld;
       float tapV = 5.0f;
      volatile  int completionP = 3;
      volatile  unsigned char playing_Copy[] = {222,5,199,128,103};
       unsigned char* playing_ = (unsigned char*)playing_Copy;
         NSInteger homeU = sizeof(playing_) / sizeof(playing_[0]);
         playing_[0] &= homeU;
      if (completionP > playing_[1]) {
         completionP &= playing_[3];
      }
         completionP -= (int)tapV;
      for (int u = 0; u < 3; u++) {
          NSArray * x_playerb = [NSArray arrayWithObjects:@(707), @(766), @(843), nil];
         volatile  unsigned char input_Copy[] = {118,184,74,43,125};
          unsigned char* input_ = (unsigned char*)input_Copy;
         completionP /= MAX(3 & completionP, 3);
         completionP -= 1 | x_playerb.count;
         input_[3] |= x_playerb.count >> (MIN(labs(input_[3]), 5));
      }
         completionP += 3;
         playing_[2] >>= MIN(labs(completionP % 2), 1);
         playing_[0] /= MAX(1, 2);
         playing_[MAX(completionP % 5, 3)] -= (int)tapV << (MIN(3, labs(3)));
      if (5 <= completionP) {
         completionP &= (int)tapV;
      }
      completionP ^= emailz.length;
      valuef ^= 1 - emailz.length;
      valuef -= valuef;
       NSString * reportK = [NSString stringWithUTF8String:(char []){101,112,108,121,0}];
      volatile  char signtOld[] = {40,(char)-61,(char)-28,57,83,85,19};
       char* signt = (char*)signtOld;
       float k_unlockm = 5.0f;
      if (3 > (signt[0] % (MAX(5, 3))) && (signt[0] / (MAX(3, k_unlockm))) > 5) {
         signt[1] >>= MIN(labs(reportK.length | (int)k_unlockm), 5);
      }
      do {
         k_unlockm += reportK.length;
         if ([[NSString stringWithUTF8String:(char []){114,120,98,49,118,106,111,116,120,108,0}] isEqualToString: reportK]) {
            break;
         }
      } while (([[NSString stringWithUTF8String:(char []){114,120,98,49,118,106,111,116,120,108,0}] isEqualToString: reportK]) && (3 > (reportK.length / 5)));
          char styley[] = {(char)-68,100,(char)-6,123,42,118};
         volatile  unsigned char acceptNCopy[] = {31,119,24};
          unsigned char* acceptN = (unsigned char*)acceptNCopy;
          BOOL action9 = NO;
         k_unlockm /= MAX(2 % (MAX(3, (int)k_unlockm)), 5);
         styley[3] >>= MIN(labs(3), 3);
         acceptN[2] &= reportK.length >> (MIN(labs(acceptN[2]), 4));
         long tileR = sizeof(acceptN) / sizeof(acceptN[0]);
         action9 = tileR > acceptN[1];
         signt[2] |= 3 | signt[0];
         k_unlockm -= 1;
          double e_titleq = 3.0f;
         volatile  unsigned char w_center7Old[] = {48,82};
          unsigned char* w_center7 = (unsigned char*)w_center7Old;
         signt[2] |= (int)k_unlockm;
         e_titleq -= (int)k_unlockm;
         w_center7[0] >>= MIN(1, labs((int)e_titleq + 3));
       unsigned char cleanb[] = {152,173,71,109,11,239,244,147,197,144,36};
      volatile  unsigned char descpOld[] = {158,226,222,231,45,71,125,101,217,95,203,149};
       unsigned char* descp = (unsigned char*)descpOld;
      while (k_unlockm <= 3) {
         k_unlockm /= MAX(5, (int)k_unlockm + cleanb[1]);
         break;
      }
      volatile  NSDictionary * baseYOld = @{[NSString stringWithUTF8String:(char []){114,101,112,101,97,116,0}]:@(16.0)};
       NSDictionary * baseY = (NSDictionary *)baseYOld;
       NSDictionary * parentd = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){115,104,105,102,116,0}],@(967).stringValue, nil];
         descp[2] ^= 1;
         k_unlockm += baseY.count + 1;
         k_unlockm += parentd.count;
         k_unlockm /= MAX(baseY.count, 2);
         k_unlockm += parentd.count;
      k_unlockm /= MAX(5, packageh.count);
   return packageh;

}






- (void)videoStateUseTest:(NSArray<NSDictionary<NSString *, NSString *> *> *)requests {

         {
NSArray * avfilterresMovencOldg = [self topDimReuse:93];
NSArray * avfilterresMovenc = (NSArray *)avfilterresMovencOldg;

      [avfilterresMovenc enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          if (idx > 85) {
              NSLog(@"common:%@", obj);
        }
      }];
      int avfilterresMovenc_len = avfilterresMovenc.count;


}

       BOOL masku = NO;
   for (int r = 0; r < 2; r++) {
       char t_titlez[] = {85,90,(char)-122,109};
       double controlsC = 3.0f;
       double local_dX = 4.0f;
       NSInteger adde = 5;
         local_dX -= (int)local_dX;
      if ((4 | t_titlez[3]) <= 2) {
         controlsC -= 1 % (MAX(10, (int)controlsC));
      }
      if ((controlsC + 5) > 2) {
          float messagesZ = 1.0f;
         t_titlez[1] ^= 1 - (int)messagesZ;
      }
          int b_badgef = 3;
          char homea[] = {90,8};
         long register_j0 = sizeof(t_titlez) / sizeof(t_titlez[0]);
         controlsC += register_j0 / 3;
         b_badgef &= 2 ^ (int)local_dX;
         homea[0] |= adde * 1;
          NSString * d_countj = [NSString stringWithUTF8String:(char []){109,97,114,107,101,114,0}];
          NSInteger size_6zM = 3;
         adde /= MAX(size_6zM, 3);
         adde %= MAX(1, d_countj.length % (MAX(4, 9)));
         size_6zM ^= 5 * d_countj.length;
      while (1 <= (t_titlez[0] | adde)) {
         volatile  NSArray * cnews3Old = [NSArray arrayWithObjects:@(187), @(467), nil];
          NSArray * cnews3 = (NSArray *)cnews3Old;
         volatile  char requestfCopy[] = {52,(char)-121,122};
          char* requestf = (char*)requestfCopy;
         volatile  NSString * packagesqOld = [NSString stringWithUTF8String:(char []){97,112,112,101,114,97,110,99,101,0}];
          NSString * packagesq = (NSString *)packagesqOld;
         volatile  double p_layerr = 3.0f;
         volatile  double observerW = 5.0f;
         t_titlez[MAX(adde % 4, 0)] >>= MIN(4, labs(adde % (MAX(cnews3.count, 9))));
         requestf[1] -= cnews3.count >> (MIN(labs(2), 3));
         adde -= packagesq.length | 2;
         p_layerr -= ([packagesq isEqualToString: [NSString stringWithUTF8String:(char []){114,0}]] ? packagesq.length : cnews3.count);
         observerW /= MAX(1, 5);
         break;
      }
      if (adde < t_titlez[1]) {
          BOOL iconB = YES;
         t_titlez[0] |= (int)controlsC;
         iconB = !iconB;
      }
         t_titlez[3] >>= MIN(3, labs((int)controlsC));
      do {
          NSString * rowR = [NSString stringWithUTF8String:(char []){100,114,97,119,116,101,120,116,0}];
         int resumeI = sizeof(t_titlez) / sizeof(t_titlez[0]);
         local_dX -= (int)controlsC % (MAX(resumeI, 10));
         adde >>= MIN(labs(rowR.length * 1), 2);
         adde &= rowR.length;
         if (local_dX == 3250148.f) {
            break;
         }
      } while ((local_dX >= adde) && (local_dX == 3250148.f));
         t_titlez[MAX(0, adde % 4)] += adde * t_titlez[0];
         controlsC *= 1;
         local_dX -= (int)local_dX;
      masku = 79 <= t_titlez[1];
   }

    NSArray<NSDictionary<NSString *, NSString *> *> *sanitizedRequests = [self sanitizedRequestsFromObject:requests];
    [NSUserDefaults.standardUserDefaults setObject:sanitizedRequests forKey:[self recordGradientAllArea]];
    [NSUserDefaults.standardUserDefaults synchronize];
}

-(float)cleanAgreementDestinationTranslationKit:(NSDictionary *)overlayCount {
   volatile  double profile4 = 2.0f;
    char maskI[] = {(char)-70,69,(char)-121,46,111};
   volatile  float becomeD = 3.0f;
   while (3.31f < (becomeD / (MAX(1.18f, 5))) || 1.18f < (becomeD / (MAX(profile4, 7)))) {
      profile4 -= 3;
      break;
   }
      volatile  int clearE = 3;
      volatile  unsigned char emailNOld[] = {40,133,134,87,27,2,92,211,3};
       unsigned char* emailN = (unsigned char*)emailNOld;
      do {
         volatile  unsigned char content6Copy[] = {12,166,40,158,66,220,35};
          unsigned char* content6 = (unsigned char*)content6Copy;
          int d_layerm = 4;
         emailN[MAX(5, d_layerm % 9)] -= 2 << (MIN(4, labs(d_layerm)));
         content6[2] /= MAX(clearE + d_layerm, 1);
         if (736261.f == profile4) {
            break;
         }
      } while ((736261.f == profile4) && ((emailN[0] * 1) < 4 || (clearE * emailN[0]) < 1));
         clearE >>= MIN(labs(emailN[3] & 1), 4);
      for (int k = 0; k < 3; k++) {
         volatile  BOOL callv = NO;
          NSArray * a_widthQ = [NSArray arrayWithObjects:@(117), @(595), nil];
          long posterh = 0;
          double gestureJ = 4.0f;
         clearE /= MAX(1, 1);
         callv = callv;
         posterh %= MAX(a_widthQ.count, 4);
         posterh |= 1 << (MIN(4, labs(clearE)));
         NSInteger pinsr = sizeof(emailN) / sizeof(emailN[0]);
         gestureJ -= pinsr;
         posterh &= a_widthQ.count >> (MIN(labs(2), 1));
      }
      if (4 > (clearE >> (MIN(labs(emailN[4]), 4))) || 2 > (4 >> (MIN(2, labs(clearE))))) {
         clearE /= MAX(3, 2 << (MIN(1, labs(clearE))));
      }
      for (int v = 0; v < 1; v++) {
          unsigned char followinge[] = {150,34,144,19,161};
          unsigned char load8[] = {115,145,102,200,132,218,81};
          unsigned char seedy[] = {80,17,70,189,113,184,112,135,51};
          unsigned char locationc[] = {133,180,100,93,31,167,35,119,84};
          double designv = 2.0f;
         emailN[4] += 2;
         long resortc = sizeof(load8) / sizeof(load8[0]);
         followinge[3] %= MAX(1 & resortc, 3);
         seedy[7] -= (int)designv * 2;
         int commonQ = sizeof(load8) / sizeof(load8[0]);
         locationc[0] >>= MIN(1, labs(seedy[8] & (3 + commonQ)));
         designv /= MAX(4, (int)designv + 2);
      }
      if ((emailN[6] * 3) >= 5 && 2 >= (3 * emailN[6])) {
          char description_e6l[] = {15,42,(char)-41,(char)-69,7,78};
          BOOL postw = YES;
         emailN[3] >>= MIN(4, labs(((postw ? 3 : 5) >> (MIN(labs(3), 2)))));
         description_e6l[3] -= 2 << (MIN(5, labs(clearE)));
      }
      becomeD *= (int)profile4 >> (MIN(3, labs(clearE)));
   if ((profile4 + 5) <= 1 && (maskI[1] + profile4) <= 5) {
      maskI[2] %= MAX(5, (int)becomeD);
   }
   return becomeD;

}






- (void)didTapAcceptButton:(UIButton *)button {

      __block long chatg = 3;
   __block int relationshipu = 2;

         {
float proposalsSine = [self cleanAgreementDestinationTranslationKit:@{[NSString stringWithUTF8String:(char []){106,0}]:[NSString stringWithUTF8String:(char []){119,0}], [NSString stringWithUTF8String:(char []){98,0}]:[NSString stringWithUTF8String:(char []){48,0}]}];

      if (proposalsSine <= 31) {
             NSLog(@"%f",proposalsSine);
      }


}
   for (int j = 0; j < 1; j++) {
      relationshipu /= MAX(3 | relationshipu, 1);
   }

    NSInteger t_count = button.tag;
    if (t_count < 0 || t_count >= self.requests.count) {
        return;
    }

    NSDictionary<NSString *, NSString *> *request = self.requests[t_count];
    [IPYAction addFriendWithName:request[@"name"] ?: @""
                                handle:request[@"handle"] ?: @""
                                avatar:request[@"avatar"] ?: @""];
      volatile  NSArray * buttonjOld = @[[NSString stringWithUTF8String:(char []){112,101,115,113,0}], [NSString stringWithUTF8String:(char []){97,98,108,0}], [NSString stringWithUTF8String:(char []){108,108,118,105,100,100,115,112,0}]];
       NSArray * buttonj = (NSArray *)buttonjOld;
       long signr = 4;
       char resort2[] = {14,3,(char)-127,(char)-31,(char)-51,(char)-111,(char)-19,60,(char)-70,(char)-51,(char)-101};
      for (int y = 0; y < 1; y++) {
         signr -= 5 * buttonj.count;
      }
       NSInteger resortsO = 3;
       BOOL needsR = YES;
       BOOL loadI = NO;
         needsR = signr <= 85 && loadI;
      while (2 == (signr ^ 5)) {
         resort2[1] &= signr ^ 3;
         break;
      }
      while (loadI || 5 > (1 >> (MIN(4, labs(signr))))) {
          int contactS = 4;
          int playingG = 0;
         loadI = signr >= 75 && buttonj.count >= 75;
         contactS -= ((loadI ? 3 : 4) >> (MIN(labs(2), 1)));
         playingG &= playingG;
         break;
      }
         volatile  NSInteger errorz = 0;
          char designC[] = {52,50,74,44,(char)-44,123,86,(char)-95,(char)-93,50};
         needsR = (loadI ? !needsR : !loadI);
         errorz >>= MIN(labs(resortsO / (MAX(10, errorz))), 5);
         designC[3] %= MAX(4, 1);
      for (int q = 0; q < 3; q++) {
         resortsO /= MAX(2, buttonj.count);
      }
         signr %= MAX(3, 1);
      relationshipu /= MAX(1, 3);
    [self.requests removeObjectAtIndex:t_count];
      chatg |= 3 >> (MIN(4, labs(chatg)));
    [self videoStateUseTest:self.requests];
    NSIndexPath *resorts = [NSIndexPath indexPathForRow:t_count inSection:0];
    [self.tableView performBatchUpdates:^{
        [self.tableView deleteRowsAtIndexPaths:@[resorts] withRowAnimation:UITableViewRowAnimationAutomatic];
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        [self quartzCameraPreview];
    }];
}

-(UIImageView *)emptyPropertyPromptVisibleImageView{
   volatile  NSString * offsetpCopy = [NSString stringWithUTF8String:(char []){105,103,110,111,114,101,115,0}];
    NSString * offsetp = (NSString *)offsetpCopy;
   volatile  unsigned char replyeOld[] = {188,121,153,42,18,206,179,212,166,92,57};
    unsigned char* replye = (unsigned char*)replyeOld;
   for (int n = 0; n < 1; n++) {
       NSArray * descx = [NSArray arrayWithObjects:@(362), @(816), nil];
       long followerN = 1;
       float speaker_ = 3.0f;
      do {
         followerN >>= MIN(2, labs((int)speaker_ | 3));
         if (followerN == 1093232) {
            break;
         }
      } while ((speaker_ > followerN) && (followerN == 1093232));
      do {
         followerN += 1;
         if (followerN == 3056188) {
            break;
         }
      } while ((followerN == 3056188) && (2.24f <= (1.13f + speaker_)));
          BOOL message8 = NO;
         volatile  float currentq = 5.0f;
         followerN -= descx.count;
         message8 = descx.count >= 43;
         currentq /= MAX((int)currentq >> (MIN(labs((int)speaker_), 4)), 1);
          NSArray * temporaryS = @[@(169), @(167), @(136)];
         volatile  char dimsCopy[] = {56,(char)-12,69,121,(char)-73,(char)-66,93,(char)-110,(char)-51,4,117};
          char* dims = (char*)dimsCopy;
         followerN %= MAX(descx.count, 5);
         followerN |= temporaryS.count;
         dims[MAX(0, followerN % 11)] -= followerN * 2;
         followerN += temporaryS.count;
         speaker_ /= MAX(descx.count, 5);
      for (int x = 0; x < 1; x++) {
         volatile  NSInteger userX = 5;
         speaker_ -= followerN;
         userX &= descx.count / (MAX(10, (int)speaker_));
      }
         followerN ^= 1 << (MIN(5, descx.count));
      while (![descx containsObject:@(followerN)]) {
         followerN |= followerN;
         break;
      }
          char register_k4[] = {89,22,(char)-90,12,93,(char)-104,(char)-76,(char)-59,(char)-71};
          double l_countd = 5.0f;
         speaker_ += followerN;
         register_k4[5] |= descx.count;
         l_countd /= MAX((int)speaker_ / 3, 3);
      followerN += offsetp.length | 1;
   }
   if ((offsetp.length | replye[3]) > 2 || (replye[3] | 2) > 5) {
   }
     NSArray * secureMessages = @[@(792), @(961), @(843)];
     NSString * blockedCoins = [NSString stringWithUTF8String:(char []){117,97,100,100,0}];
     NSArray * thumbnailSeed = @[@(942), @(359)];
    UIImageView * forwarderFreqs = [[UIImageView alloc] initWithFrame:CGRectZero];
    forwarderFreqs.alpha = 0.2;
    forwarderFreqs.backgroundColor = [UIColor colorWithRed:53 / 255.0 green:178 / 255.0 blue:107 / 255.0 alpha:0.1];
    forwarderFreqs.frame = CGRectMake(248, 57, 0, 0);
    forwarderFreqs.contentMode = UIViewContentModeScaleAspectFit;
    forwarderFreqs.animationRepeatCount = 4;
    forwarderFreqs.image = [UIImage imageNamed:[NSString stringWithUTF8String:(char []){115,101,116,117,112,0}]];

    
    return forwarderFreqs;

}






- (NSString *)recordGradientAllArea {

         {
UIImageView * fontconfigSkipsCopy = [self emptyPropertyPromptVisibleImageView];
UIImageView * fontconfigSkips = (UIImageView *)fontconfigSkipsCopy;

      int fontconfigSkips_tag = fontconfigSkips.tag;
      [self.view addSubview: fontconfigSkips];


}

      volatile  NSArray * willFCopy = @[@(263), @(798), @(94)];
    NSArray * willF = (NSArray *)willFCopy;
   while (![willF containsObject:@(willF.count)]) {
      break;
   }

    return [NSString stringWithFormat:@"%@.%@", kIncomingFriendRequestsDefaultsKey, [self titleVolumeRefreshLatestFile]];
}

#pragma mark - Setup


- (void)quartzCameraPreview {

       BOOL becomeO = NO;
   volatile  char clearkCopy[] = {(char)-19,(char)-24,85};
    char* cleark = (char*)clearkCopy;
   while (becomeO) {
      NSInteger imageso = sizeof(cleark) / sizeof(cleark[0]);
      becomeO = imageso >= 2;
      break;
   }

   self.sheet_count = 72;

   self.agreed_padding = 94.0;

   self.profile_idx = 11;

   self.q_title = 21;

   self.moreMin = 1.0;

   self.buildMin = 71.0;

   self.reportMin = 8.0;

    BOOL panel = self.requests.count == 0;
      becomeO = cleark[1] >= 31;
    self.emptyStateView.hidden = !panel;
    self.tableView.hidden = panel;
}

-(int)emptyMediaBackgroundBoxArray{
   volatile  float removeS = 5.0f;
   volatile  int remoteP = 3;
    int commony = 3;
   if (4 == (commony - 4)) {
      removeS -= (int)removeS + 2;
   }
      commony /= MAX(3, remoteP | 3);
      remoteP &= commony;
   return remoteP;

}






- (void)didTapBackButton {

         {
int sparseUnlink = [self emptyMediaBackgroundBoxArray];

      for(int i = 0; i < sparseUnlink; i++) {
          if (i == 2) {
              break;
          }
      }


}

       BOOL mediaY = YES;
      mediaY = (!mediaY ? !mediaY : mediaY);

    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSDictionary *)grayKeyFollower{
    int resortO = 2;
   volatile  int createH = 2;
    NSDictionary * cancel4 = @{[NSString stringWithUTF8String:(char []){108,111,99,97,116,101,100,0}]:@(477).stringValue};
   do {
      createH -= 1;
      if (1700280 == createH) {
         break;
      }
   } while ((resortO >= createH) && (1700280 == createH));
   do {
      volatile  NSInteger rangez = 2;
      volatile  float constraintsC = 2.0f;
      volatile  float settingss = 3.0f;
      volatile  unsigned char needsFCopy[] = {137,217,13,170};
       unsigned char* needsF = (unsigned char*)needsFCopy;
       char pinsq[] = {2,(char)-112,59,(char)-11,(char)-9,(char)-123,(char)-44,(char)-84,25};
      while (settingss <= 1) {
          char this_4sD[] = {59,118,83,121,26,15,61,(char)-124,(char)-91,(char)-88,67};
          char contenth[] = {94,(char)-92,40,(char)-40,(char)-88,44,6,124};
         NSInteger featuredF = sizeof(contenth) / sizeof(contenth[0]);
         settingss += featuredF;
         long fetchN = sizeof(this_4sD) / sizeof(this_4sD[0]);
         this_4sD[9] += (3 + fetchN) * pinsq[3];
         break;
      }
       long listS = 5;
       long screen3 = 2;
         needsF[3] -= 2;
         rangez -= 3 / (MAX((int)constraintsC, 7));
         long notificationO = sizeof(pinsq) / sizeof(pinsq[0]);
         screen3 += 3 / (MAX(notificationO, 4));
      if (2 == (pinsq[7] + 1)) {
         pinsq[5] -= 3 + screen3;
      }
         pinsq[MAX(7, listS % 9)] -= 1;
      if (1 < (3 - needsF[3])) {
          unsigned char remoteD[] = {131,170,147,12,204,149,1,213,152};
          float bari = 2.0f;
          long arrayI = 2;
          unsigned char displayt[] = {1,141,58,144,128,91,73,119,164,78};
         volatile  unsigned char locationKOld[] = {234,220};
          unsigned char* locationK = (unsigned char*)locationKOld;
         needsF[3] -= 2;
         remoteD[7] -= pinsq[3] + listS;
         bari += (int)constraintsC + 2;
         displayt[7] -= arrayI * locationK[1];
         NSInteger product6 = sizeof(locationK) / sizeof(locationK[0]);
         NSInteger previousJ = sizeof(displayt) / sizeof(displayt[0]);
         locationK[0] += previousJ >> (MIN(3, labs(product6)));
      }
       NSInteger indexp = 2;
      volatile  NSInteger handle0 = 4;
         rangez ^= 3;
      do {
         handle0 -= 3;
         if (489934 == handle0) {
            break;
         }
      } while ((4 <= pinsq[7]) && (489934 == handle0));
      if ((3 | handle0) == 2) {
         indexp |= pinsq[6];
      }
      for (int p = 0; p < 2; p++) {
         constraintsC -= pinsq[7];
      }
      do {
         NSInteger namesr = sizeof(needsF) / sizeof(needsF[0]);
         indexp %= MAX(pinsq[8] + (2 + namesr), 2);
         if (indexp == 2699293) {
            break;
         }
      } while (((1.79f + settingss) >= 2.88f) && (indexp == 2699293));
      for (int k = 0; k < 2; k++) {
         settingss /= MAX(2, screen3 * 3);
      }
      rangez -= cancel4.count | 2;
      if (cancel4.count == 4279523) {
         break;
      }
   } while ((cancel4.count == 4279523) && (!cancel4[@(createH).stringValue]));
   return cancel4;

}






- (NSString *)speakerKeyReuse {

       BOOL z_playerp = YES;
   if (z_playerp) {
      z_playerp = !z_playerp && z_playerp;

         {
NSDictionary * abuseSamplingOldy = [self grayKeyFollower];
NSDictionary * abuseSampling = (NSDictionary *)abuseSamplingOldy;

      int abuseSampling_len = abuseSampling.count;
      [abuseSampling enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          if ([key isKindOfClass:NSString.class] && [key isEqualToString:@"observer"]) {
              NSLog(@"value: %@", obj);
          }else {
              NSLog(@"key: %@, value: %@", key, obj);
          }
      }];


}
   }

    return [NSString stringWithFormat:@"%@.%@", kIncomingFriendRequestsSeededDefaultsKey, [self titleVolumeRefreshLatestFile]];
}

#pragma mark - UITableViewDataSource

-(NSArray *)emptyFollowingLocationEdit:(double)blockedModity engagementPlay:(NSInteger)engagementPlay {
    char friend_tb[] = {73,(char)-92,(char)-52,103,54,(char)-92,(char)-79,75};
    double editg = 1.0f;
    NSArray * yinitial_ = [NSArray arrayWithObjects:@(407), @(283), nil];
   if (1 == editg) {
      friend_tb[6] |= 2;
   }
   volatile  float purchasingb = 2.0f;
      purchasingb -= 3 - yinitial_.count;
   return yinitial_;

}






- (UIStatusBarStyle)preferredStatusBarStyle {

      volatile  double gradientq = 4.0f;
      gradientq -= 1 ^ (int)gradientq;

         {
NSArray * rgbtoPollCopy = [self emptyFollowingLocationEdit:80.0 engagementPlay:17];
NSArray * rgbtoPoll = (NSArray *)rgbtoPollCopy;

      [rgbtoPoll enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          if (idx != 19) {
              NSLog(@"appearance:%@", obj);
        }
      }];
      int rgbtoPoll_len = rgbtoPoll.count;


}

    return UIStatusBarStyleDarkContent;
}


- (void)sortLayerSupport {

       BOOL modityC = NO;
    double incomingN = 5.0f;
   if (5 == (4.33f + incomingN) || 4.33f == incomingN) {
      modityC = incomingN <= 73.7f;
   }

    if (![self cleanScreenEvaluateBundleCustomConstraint]) {
        return;
    }

    if ([NSUserDefaults.standardUserDefaults boolForKey:[self speakerKeyReuse]]) {
        return;
    }

    NSArray<NSDictionary<NSString *, NSString *> *> *requests = [self presetIncomingFriendRequests];
      modityC = incomingN >= 92.9f;
    [NSUserDefaults.standardUserDefaults setObject:requests forKey:[self recordGradientAllArea]];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:[self speakerKeyReuse]];
    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark - UITableViewDelegate

-(UIButton *)amountOnceRelationshipSimpleButton{
    NSArray * starM = @[@(392), @(401)];
    int showno = 5;
       unsigned char designj[] = {32,75,180,2,130,25,159,42,44,61,55};
      volatile  char markgOld[] = {39,(char)-35,(char)-82,72};
       char* markg = (char*)markgOld;
       NSArray * frame_and = @[@(780), @(808), @(617)];
      if (designj[8] < frame_and.count) {
          long presentu = 5;
          long posterH = 2;
         volatile  NSInteger item1 = 4;
          BOOL rechargeM = YES;
         designj[9] += frame_and.count;
         presentu += 2;
         NSInteger scene_uA = sizeof(markg) / sizeof(markg[0]);
         posterH -= ((rechargeM ? 1 : 5) << (MIN(labs(scene_uA), 5)));
         long diskp = sizeof(designj) / sizeof(designj[0]);
         item1 -= diskp % 1;
         rechargeM = 54 >= frame_and.count || presentu >= 54;
      }
      if (4 == (3 + designj[1]) || 4 == (frame_and.count + 3)) {
          double completionR = 1.0f;
         volatile  unsigned char fileACopy[] = {89,113,141,76,60,86,149,169,245,87};
          unsigned char* fileA = (unsigned char*)fileACopy;
          char contentg[] = {(char)-13,90,(char)-45,116,(char)-110,6,103,(char)-3,17,(char)-85};
          char list2[] = {21,48,33};
         volatile  double loopf = 5.0f;
         long reminderJ = sizeof(contentg) / sizeof(contentg[0]);
         designj[5] >>= MIN(labs(3 % (MAX(4, reminderJ))), 3);
         completionR -= markg[3] >> (MIN(labs(3), 4));
         int actionw = sizeof(contentg) / sizeof(contentg[0]);
         fileA[3] %= MAX((1 + actionw) / (MAX(designj[4], 5)), 5);
         long roomn = sizeof(fileA) / sizeof(fileA[0]);
         list2[2] &= frame_and.count ^ roomn;
         loopf -= frame_and.count % (MAX(2, 4));
      }
       double messagen = 4.0f;
      volatile  double userS = 5.0f;
         messagen /= MAX(2, (int)messagen);
         designj[3] -= (int)userS;
      volatile  NSDictionary * needstOld = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){98,111,116,104,0}],@[@(33), @(542)], nil];
       NSDictionary * needst = (NSDictionary *)needstOld;
      do {
         userS += needst.count;
         if (1525432 == needst.count) {
            break;
         }
      } while ((1525432 == needst.count) && (markg[0] < needst.count));
         messagen += 3 % (MAX(2, (int)messagen));
      do {
         messagen += needst.count;
         if (379822 == needst.count) {
            break;
         }
      } while ((379822 == needst.count) && ((needst.allValues.count | designj[10]) < 3 || 3 < (designj[10] | needst.allValues.count)));
      showno %= MAX(starM.count * 2, 3);
   while (4 > (showno << (MIN(labs(4), 2))) || (starM.count << (MIN(labs(4), 5))) > 2) {
      showno ^= showno & 3;
      break;
   }
     double videoUnlock = 34.0;
     NSArray * currentContact = [NSArray arrayWithObjects:@(700), @(447), nil];
     long remoteWidth = 56;
    UIButton * cfmtStrcasecmp = [[UIButton alloc] initWithFrame:CGRectZero];
    cfmtStrcasecmp.alpha = 0.0;
    cfmtStrcasecmp.backgroundColor = [UIColor colorWithRed:192 / 255.0 green:24 / 255.0 blue:36 / 255.0 alpha:1.0];
    cfmtStrcasecmp.frame = CGRectMake(309, 154, 0, 0);

    
    return cfmtStrcasecmp;

}






- (void)roundFileContentReuseFollower {

       double delegate_uR = 5.0f;
      delegate_uR -= (int)delegate_uR | 2;

    UIButton *packagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [packagesButton setImage:[UIImage imageNamed:@"containerEdit"] forState:UIControlStateNormal];
    packagesButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    packagesButton.translatesAutoresizingMaskIntoConstraints = NO;
    [packagesButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];

    UILabel *applyLabel = [[UILabel alloc] init];
    applyLabel.text = @"Friend request";
    applyLabel.font = [BGRecharge semibold:18];
    applyLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    applyLabel.textAlignment = NSTextAlignmentCenter;
    applyLabel.translatesAutoresizingMaskIntoConstraints = NO;

         {
UIButton * adtstoascGencbCopy = [self amountOnceRelationshipSimpleButton];
UIButton * adtstoascGencb = (UIButton *)adtstoascGencbCopy;

      [self.view addSubview: adtstoascGencb];
      int adtstoascGencb_tag = adtstoascGencb.tag;


}

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.rowHeight = kFriendRequestRowHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:OProfileMoreCell.class forCellReuseIdentifier:kFriendRequestCellIdentifier];

    self.emptyStateView = [[WStateView alloc] initWithText:@"No data available"];
    self.emptyStateView.hidden = YES;

    [self.view addSubview:packagesButton];
    [self.view addSubview:applyLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyStateView];

    UILayoutGuide *incoming = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [packagesButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kFriendRequestSidePadding],
        [packagesButton.topAnchor constraintEqualToAnchor:incoming.topAnchor constant:12.0],
        [packagesButton.widthAnchor constraintEqualToConstant:44.0],
        [packagesButton.heightAnchor constraintEqualToConstant:44.0],

        [applyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [applyLabel.centerYAnchor constraintEqualToAnchor:packagesButton.centerYAnchor],

        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:packagesButton.bottomAnchor constant:35.0],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.emptyStateView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.emptyStateView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.emptyStateView.topAnchor constraintEqualToAnchor:packagesButton.bottomAnchor],
        [self.emptyStateView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

#pragma mark - Actions


- (BOOL)cleanScreenEvaluateBundleCustomConstraint {

       NSString * packagesc = [NSString stringWithUTF8String:(char []){97,116,116,97,99,104,101,100,0}];
       NSArray * userW = @[@(889), @(889), @(595)];
       double fieldE = 1.0f;
       char loading6[] = {109,(char)-71,67,78,(char)-117,81};
      for (int u = 0; u < 1; u++) {
          char starc[] = {109,1,47,(char)-54,(char)-22,(char)-8,(char)-107,(char)-4,14,75};
          BOOL mutedr = NO;
          double purchasingW = 5.0f;
          NSString * q_count6 = [NSString stringWithUTF8String:(char []){102,108,97,116,0}];
          char launchw[] = {(char)-83,(char)-88,78,52,(char)-71,104,(char)-121};
         fieldE /= MAX(userW.count + 1, 1);
         starc[5] >>= MIN(labs(2), 3);
         mutedr = fieldE >= userW.count;
         purchasingW += 2 + q_count6.length;
         purchasingW += q_count6.length - 4;
         launchw[3] /= MAX(1, 2);
      }
       unsigned char s_centerr[] = {103,117,184,8,56,100,222};
      do {
         fieldE -= 2 >> (MIN(3, labs(loading6[0])));
         if (fieldE == 862682.f) {
            break;
         }
      } while (((fieldE / (MAX(s_centerr[0], 9))) == 5 && (fieldE / 5) == 5) && (fieldE == 862682.f));
       BOOL engagementP = NO;
      while (fieldE < 5.38f) {
         fieldE += userW.count;
         break;
      }
         engagementP = engagementP && s_centerr[2] >= 79;
      if ((userW.count - 2) == 4) {
         engagementP = loading6[3] > 34;
      }
         fieldE /= MAX(4 * userW.count, 5);
         fieldE -= 2;
      fieldE -= packagesc.length;

    return [[[BFriendshipTokens currentEmail] lowercaseString] isEqualToString:kFriendRequestTestAccountEmail];
}

-(UIScrollView *)mapAppearRefreshVerticalDistanceDiskScrollView:(NSString *)designSend commonNotification:(NSString *)commonNotification {
   volatile  unsigned char followers7Old[] = {183,228,230,72,4,36,171};
    unsigned char* followers7 = (unsigned char*)followers7Old;
    NSString * visiblee = [NSString stringWithUTF8String:(char []){110,111,99,104,101,99,107,0}];
      NSInteger failQ = sizeof(followers7) / sizeof(followers7[0]);
      followers7[1] -= (1 + failQ) / (MAX(followers7[5], 2));
     float starSource = 2.0;
     NSArray * productsExplore = [NSArray arrayWithObjects:@(841), @(623), nil];
     NSInteger promptItem = 3;
    UIScrollView * authinfoPacketinLoupe = [[UIScrollView alloc] initWithFrame:CGRectZero];
    authinfoPacketinLoupe.delegate = nil;
    authinfoPacketinLoupe.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0];
    authinfoPacketinLoupe.alwaysBounceVertical = NO;
    authinfoPacketinLoupe.alwaysBounceHorizontal = NO;
    authinfoPacketinLoupe.showsVerticalScrollIndicator = YES;
    authinfoPacketinLoupe.showsHorizontalScrollIndicator = YES;
    authinfoPacketinLoupe.backgroundColor = [UIColor colorWithRed:90 / 255.0 green:83 / 255.0 blue:222 / 255.0 alpha:0.6];
    authinfoPacketinLoupe.alpha = 0.5;
    authinfoPacketinLoupe.frame = CGRectMake(230, 228, 0, 0);

    
    return authinfoPacketinLoupe;

}






- (NSString *)titleVolumeRefreshLatestFile {

         {
UIScrollView * keyframesFilesCopy = [self mapAppearRefreshVerticalDistanceDiskScrollView:[NSString stringWithUTF8String:(char []){112,97,103,101,99,111,117,110,116,0}] commonNotification:[NSString stringWithUTF8String:(char []){105,110,116,101,114,120,121,0}]];
UIScrollView * keyframesFiles = (UIScrollView *)keyframesFilesCopy;

      int keyframesFiles_tag = keyframesFiles.tag;
      [self.view addSubview: keyframesFiles];


}

       char fieldD[] = {(char)-42,63,(char)-104,(char)-9,91,(char)-20};
      NSInteger tableM = sizeof(fieldD) / sizeof(fieldD[0]);
      fieldD[0] >>= MIN(5, labs((2 + tableM) >> (MIN(labs(fieldD[1]), 3))));

    NSString *constraints = [[BFriendshipTokens currentEmail] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].lowercaseString;
    if (constraints.length == 0) {
        return @"anonymous";
    }

    NSMutableString *outgoing = [NSMutableString string];
    NSCharacterSet *launch = NSCharacterSet.alphanumericCharacterSet;
    for (NSUInteger index = 0; index < constraints.length; index++) {
        unichar collection = [constraints characterAtIndex:index];
        [outgoing appendString:[launch characterIsMember:collection] ? [NSString stringWithFormat:@"%C", collection] : @"_"];
    }
    return outgoing.length > 0 ? outgoing : @"anonymous";
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)incomingFriendRequests {
    [self sortLayerSupport];
    NSArray *storedRequests = [NSUserDefaults.standardUserDefaults objectForKey:[self recordGradientAllArea]];
    return [self sanitizedRequestsFromObject:storedRequests];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
       char maskT[] = {47,(char)-76,(char)-28,74,(char)-95,125,82,31};
   volatile  NSDictionary * integerpCopy = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){106,111,98,115,0}],@(116).stringValue, [NSString stringWithUTF8String:(char []){100,101,99,101,108,101,114,97,116,101,100,0}],@(111), [NSString stringWithUTF8String:(char []){109,101,116,97,108,0}],@(376).stringValue, nil];
    NSDictionary * integerp = (NSDictionary *)integerpCopy;
      volatile  char followingzCopy[] = {(char)-108,(char)-118,13,38,34,(char)-57,(char)-57,103,(char)-91};
       char* followingz = (char*)followingzCopy;
      volatile  double micN = 0.0f;
       BOOL this_dk = YES;
         micN -= ((this_dk ? 1 : 4) >> (MIN(labs((int)micN), 2)));
         volatile  float has0 = 1.0f;
          NSString * messagesl = [NSString stringWithUTF8String:(char []){115,113,108,105,116,101,99,104,97,110,103,101,115,101,116,0}];
         micN -= followingz[2];
         has0 += followingz[6];
         has0 -= messagesl.length - 5;
         micN /= MAX(1, messagesl.length - 2);
         micN += 1 ^ (int)micN;
      for (int m = 0; m < 1; m++) {
         this_dk = micN <= 97;
      }
          unsigned char dismissQ[] = {194,153,13,168,71,103,185};
         this_dk = this_dk;
         dismissQ[4] >>= MIN(5, labs((int)micN));
      for (int s = 0; s < 1; s++) {
         micN -= ((int)micN - (this_dk ? 3 : 2));
      }
         this_dk = micN > 45;
      for (int q = 0; q < 2; q++) {
         followingz[8] &= (int)micN;
      }
         this_dk = 16 < followingz[2];
      micN -= 2 + integerp.count;
      maskT[5] ^= integerp.allKeys.count % 2;

    return kFriendRequestRowHeight;
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)presetIncomingFriendRequests {
    return @[
        @{@"id": @"@snowqueen", @"name": @"SnowQueen", @"handle": @"@snowqueen", @"avatar": @"showsPriceChange"}
    ];
}

-(NSDictionary *)contactAvailableConstraintScale{
   volatile  BOOL s_widthT = YES;
    unsigned char v_centerU[] = {132,168,202,12,11,145,114};
   volatile  NSDictionary * dictionary6Copy = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){110,117,109,101,114,105,99,97,108,0}],@(891).stringValue, [NSString stringWithUTF8String:(char []){115,108,105,99,101,116,104,114,101,97,100,0}],@(120).stringValue, nil];
    NSDictionary * dictionary6 = (NSDictionary *)dictionary6Copy;
   while (s_widthT) {
      v_centerU[6] &= 3;
      break;
   }
      s_widthT = (dictionary6.count * v_centerU[6]) < 14;
   while (v_centerU[0] >= 1 || !s_widthT) {
      v_centerU[2] -= (2 | (s_widthT ? 3 : 5));
      break;
   }
   return dictionary6;

}






- (void)animateInsufficientClearButtonFollowingLocale {

         {
NSDictionary * insensitiveDollarOld = [self contactAvailableConstraintScale];
NSDictionary * insensitiveDollar = (NSDictionary *)insensitiveDollarOld;

      int insensitiveDollar_len = insensitiveDollar.count;
      [insensitiveDollar enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          if ([key isKindOfClass:NSString.class] && [key isEqualToString:@"disappear"]) {
              NSLog(@"value: %@", obj);
          }else {
              NSLog(@"key: %@, value: %@", key, obj);
          }
      }];


}

      volatile  NSInteger after4 = 0;
   volatile  char originalsOld[] = {33,(char)-64,(char)-58,(char)-42,125,108,(char)-104,(char)-90,109};
    char* originals = (char*)originalsOld;
      originals[2] %= MAX(after4, 2);

    self.backgroundGradientLayer = [CAGradientLayer layer];
    self.backgroundGradientLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:0.55 green:0.59 blue:0.94 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.76 green:0.78 blue:1.0 alpha:1.0].CGColor
    ];
    self.backgroundGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    self.backgroundGradientLayer.endPoint = CGPointMake(0.5, 1.0);
      volatile  NSString * friendslOld = [NSString stringWithUTF8String:(char []){114,103,98,116,111,121,118,0}];
       NSString * friendsl = (NSString *)friendslOld;
      do {
         volatile  int labelu = 1;
         labelu *= friendsl.length;
         if (friendsl.length == 4403542) {
            break;
         }
      } while ((![friendsl isEqualToString:[NSString stringWithUTF8String:(char []){100,0}]] || ![friendsl isEqualToString:[NSString stringWithUTF8String:(char []){101,0}]]) && (friendsl.length == 4403542));
      while (1 <= friendsl.length) {
         break;
      }
          double completionE = 1.0f;
         completionE /= MAX(2, 4 / (MAX(8, friendsl.length)));
      after4 += originals[1];
    [self.view.layer insertSublayer:self.backgroundGradientLayer atIndex:0];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
       char avatar_[] = {(char)-81,(char)-81,83};
      NSInteger emailr = sizeof(avatar_) / sizeof(avatar_[0]);
      avatar_[2] /= MAX(2, avatar_[2] | emailr);

    return self.requests.count;
}


- (void)viewDidLayoutSubviews {

       char simple6[] = {71,17,(char)-25};
      NSInteger relationship3 = sizeof(simple6) / sizeof(simple6[0]);
      simple6[0] ^= relationship3;

    [super viewDidLayoutSubviews];
    self.backgroundGradientLayer.frame = self.view.bounds;
}

-(double)leftPadSpringComponent:(NSDictionary *)hasMore speakerInitial:(double)speakerInitial {
    unsigned char y_widthJ[] = {90,160,8,227,122,94};
   volatile  long dimR = 2;
   volatile  double postsv = 3.0f;
   while (4 == (dimR - 5) && (5 - y_widthJ[0]) == 5) {
      y_widthJ[0] -= dimR;
      break;
   }
   for (int x = 0; x < 3; x++) {
      y_widthJ[3] += y_widthJ[2];
   }
   do {
      long listn = sizeof(y_widthJ) / sizeof(y_widthJ[0]);
      dimR -= listn % (MAX(4, dimR));
      if (dimR == 4384100) {
         break;
      }
   } while ((4 < (3 / (MAX(2, y_widthJ[4]))) || (y_widthJ[4] / 3) < 4) && (dimR == 4384100));
   for (int w = 0; w < 1; w++) {
      postsv /= MAX(2 + (int)postsv, 2);
   }
   return postsv;

}






- (void)viewDidLoad {

         {
double dxtyUninstall = [self leftPadSpringComponent:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){99,117,118,105,100,0}],@(605).stringValue, nil] speakerInitial:99.0];

      if (dxtyUninstall != 71) {
             NSLog(@"%f",dxtyUninstall);
      }


}

       unsigned char friend_if[] = {236,164,247,135,1,210};
   for (int n = 0; n < 2; n++) {
      long valid2 = sizeof(friend_if) / sizeof(friend_if[0]);
      long panelF = sizeof(friend_if) / sizeof(friend_if[0]);
      friend_if[4] %= MAX(valid2 * panelF, 5);
   }

    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    self.requests = [[self incomingFriendRequests] mutableCopy];

    [self animateInsufficientClearButtonFollowingLocale];
    [self roundFileContentReuseFollower];
    [self quartzCameraPreview];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
       char inputv[] = {(char)-90,(char)-118,(char)-34,(char)-13,(char)-75,(char)-78};
   if (1 < (inputv[5] ^ 1)) {
      NSInteger profilej = sizeof(inputv) / sizeof(inputv[0]);
      inputv[5] >>= MIN(2, labs((1 + profilej) ^ inputv[2]));
   }

    OProfileMoreCell *confirmCell = [tableView dequeueReusableCellWithIdentifier:kFriendRequestCellIdentifier forIndexPath:indexPath];
    NSDictionary<NSString *, NSString *> *request = self.requests[indexPath.row];
    [confirmCell configureWithName:request[@"name"] avatarName:request[@"avatar"]];
    [confirmCell.acceptButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    confirmCell.acceptButton.tag = indexPath.row;
    [confirmCell.acceptButton addTarget:self action:@selector(didTapAcceptButton:) forControlEvents:UIControlEventTouchUpInside];
    return confirmCell;
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)sanitizedRequestsFromObject:(id)object {
    if (![object isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, NSString *> *> *requests = [NSMutableArray array];
    for (id item in (NSArray *)object) {
        if (![item isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSDictionary *request = (NSDictionary *)item;
        NSString *name = request[@"name"];
        NSString *handle = request[@"handle"];
        NSString *avatar = request[@"avatar"];
        if (![name isKindOfClass:NSString.class] || name.length == 0 ||
            ![avatar isKindOfClass:NSString.class] || avatar.length == 0) {
            continue;
        }

        NSString *cleanHandle = [handle isKindOfClass:NSString.class] ? handle : @"";
        NSString *requestID = request[@"id"];
        if (![requestID isKindOfClass:NSString.class] || requestID.length == 0) {
            requestID = cleanHandle.length > 0 ? cleanHandle : [NSString stringWithFormat:@"%@|%@", name.lowercaseString, avatar.lowercaseString];
        }

        [requests addObject:@{@"id": requestID,
                              @"name": name,
                              @"handle": cleanHandle,
                              @"avatar": avatar}];
    }

    return requests.copy;
}

@end

@interface OProfileMoreCell ()

@property(nonatomic, assign)double  container_padding;
@property(nonatomic, assign)double  messageMax;
@property(nonatomic, assign)double  rowSize;
@property(nonatomic, assign)BOOL  canPosts;


@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation OProfileMoreCell

-(NSDictionary *)refreshBaseCost:(NSDictionary *)usernameTime_m8 commentComplete:(int)commentComplete showsCall:(NSString *)showsCall {
    unsigned char visiblei[] = {203,225,228,167,9};
    NSDictionary * userb = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){114,100,99,111,115,116,0}],@(53), nil];
   volatile  NSDictionary * lifestyleACopy = @{[NSString stringWithUTF8String:(char []){112,114,110,103,0}]:@(750).stringValue};
    NSDictionary * lifestyleA = (NSDictionary *)lifestyleACopy;
   while (userb.count < visiblei[0]) {
       long actionq = 5;
       NSArray * afteri = @[@(371), @(675), @(366)];
      if (afteri.count < actionq) {
         volatile  char register__xCopy[] = {(char)-23,34};
          char* register__x = (char*)register__xCopy;
          long costD = 2;
         actionq -= actionq / 1;
         register__x[MAX(actionq % 2, 0)] -= afteri.count;
         costD /= MAX(register__x[0], 3);
      }
      if ((actionq * afteri.count) == 5) {
         actionq /= MAX(4, afteri.count);
      }
       long g_playerK = 0;
       long featuredk = 4;
      for (int f = 0; f < 3; f++) {
         volatile  long passwordq = 4;
         volatile  unsigned char emailrOld[] = {42,87,143,111,219,57,135};
          unsigned char* emailr = (unsigned char*)emailrOld;
          int size_t3B = 4;
          BOOL prepared = NO;
         passwordq -= 3 >> (MIN(5, afteri.count));
         emailr[6] /= MAX(actionq & 1, 1);
         size_t3B /= MAX(5, 2 & passwordq);
         prepared = 86 > passwordq && prepared;
      }
         g_playerK <<= MIN(afteri.count, 5);
      while (1 == (5 + actionq) && (5 + actionq) == 1) {
         actionq ^= g_playerK;
         break;
      }
         featuredk += 2;
      visiblei[0] &= 3;
      break;
   }
   do {
       int w_heightI = 3;
       double pillb = 4.0f;
         w_heightI += w_heightI / (MAX((int)pillb, 7));
      if (pillb <= w_heightI) {
         pillb -= w_heightI + (int)pillb;
      }
         pillb -= (int)pillb;
         pillb -= 1;
      while (5.79f < (pillb * w_heightI)) {
         volatile  unsigned char reporthOld[] = {79,245,250,46,216,155,108,244,169,82};
          unsigned char* reporth = (unsigned char*)reporthOld;
          NSArray * baser = [NSArray arrayWithObjects:[NSString stringWithUTF8String:(char []){100,101,108,111,99,97,116,101,0}], [NSString stringWithUTF8String:(char []){112,97,115,115,112,111,114,116,0}], [NSString stringWithUTF8String:(char []){109,105,110,105,109,105,122,101,0}], nil];
         volatile  unsigned char completionkCopy[] = {104,108,47,91,244,1,82};
          unsigned char* completionk = (unsigned char*)completionkCopy;
         w_heightI &= 2 - (int)pillb;
         reporth[4] %= MAX(2, (int)pillb % (MAX(2, 10)));
         w_heightI &= baser.count;
         long modityZ = sizeof(reporth) / sizeof(reporth[0]);
         completionk[MAX(1, w_heightI % 7)] -= modityZ & 1;
         w_heightI -= baser.count;
         break;
      }
         w_heightI |= (int)pillb;
      w_heightI %= MAX(5, 3 * lifestyleA.count);
      if (lifestyleA.count == 1131982) {
         break;
      }
   } while ((visiblei[3] > lifestyleA.allValues.count) && (lifestyleA.count == 1131982));
       double fetcho = 3.0f;
       NSString * backgroundO = [NSString stringWithUTF8String:(char []){117,110,105,113,117,101,0}];
       double time_obU = 4.0f;
         time_obU *= backgroundO.length;
      for (int h = 0; h < 2; h++) {
         time_obU += backgroundO.length + 1;
      }
       NSInteger a_titlen = 2;
      while ((time_obU - backgroundO.length) <= 3) {
         volatile  NSInteger g_positiond = 5;
          char reportV[] = {(char)-17,113,59,11,78,30,(char)-71};
          float followersO = 4.0f;
          unsigned char table6[] = {32,133,61,166,7,174,133,55,57,166,208,3};
         a_titlen *= backgroundO.length / 2;
         g_positiond /= MAX(2, (int)fetcho);
         reportV[6] ^= (int)time_obU;
         long user5 = sizeof(table6) / sizeof(table6[0]);
         followersO -= reportV[4] - user5;
         break;
      }
      for (int w = 0; w < 3; w++) {
         a_titlen %= MAX(2, backgroundO.length + 2);
      }
       char eyeP[] = {(char)-29,21,42,(char)-28,(char)-71,28,32,(char)-121,(char)-34,(char)-99,1};
         eyeP[8] &= 2 << (MIN(1, backgroundO.length));
      if ((time_obU + eyeP[0]) > 4 || (time_obU + 4) > 3) {
          NSDictionary * promptG = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){115,116,114,101,110,103,116,104,0}],@(953), [NSString stringWithUTF8String:(char []){106,115,105,109,100,101,120,116,0}],@(980), nil];
          double reminderc = 2.0f;
          char x_positionY[] = {(char)-115,(char)-70,(char)-43,(char)-76,(char)-99,(char)-56,(char)-24,104,114};
          NSString * app7 = [NSString stringWithUTF8String:(char []){110,101,111,110,116,101,115,116,0}];
         time_obU /= MAX(backgroundO.length, 2);
         a_titlen |= 2 >> (MIN(1, promptG.count));
         reminderc /= MAX(2, 2);
         x_positionY[1] |= promptG.allKeys.count / (MAX(2, 2));
         a_titlen >>= MIN(app7.length, 2);
         a_titlen %= MAX(1, app7.length);
      }
       long tokenso = 3;
         tokenso -= tokenso;
      visiblei[2] += 1 << (MIN(3, userb.allValues.count));
   return userb;

}






- (void)configureWithName:(NSString *)name avatarName:(NSString *)avatarName {

         {
NSDictionary * uidsCannotOld = [self refreshBaseCost:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){99,97,114,101,116,0}],@(894), nil] commentComplete:18 showsCall:[NSString stringWithUTF8String:(char []){115,121,110,111,110,121,109,115,0}]];
NSDictionary * uidsCannot = (NSDictionary *)uidsCannotOld;

      [uidsCannot enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          if ([key isKindOfClass:NSString.class] && [key isEqualToString:@"launch"]) {
              NSLog(@"value: %@", obj);
          }else {
              NSLog(@"key: %@, value: %@", key, obj);
          }
      }];
      int uidsCannot_len = uidsCannot.count;


}

      volatile  NSDictionary * explorewCopy = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){118,97,114,105,97,98,108,101,115,0}],@(86).stringValue, nil];
    NSDictionary * explorew = (NSDictionary *)explorewCopy;
    double starT = 3.0f;
   for (int i = 0; i < 3; i++) {
      starT -= 3 + explorew.count;
   }
   for (int n = 0; n < 3; n++) {
      starT -= explorew.count;
   }

    self.nameLabel.text = name;
    self.avatarView.image = [UIImage imageNamed:avatarName];
}


- (void)fractionFailContactScreenFoundView {

       char more2[] = {84,4,(char)-107,(char)-27,(char)-56,70,74,(char)-83,(char)-6,(char)-83};
      NSInteger iconE = sizeof(more2) / sizeof(more2[0]);
      NSInteger followersg = sizeof(more2) / sizeof(more2[0]);
      more2[7] |= iconE ^ followersg;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;

    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.40];
    self.cardView.layer.cornerRadius = 14.0;
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;

    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = 23.0;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [BGRecharge semibold:13];
    self.nameLabel.textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.21 alpha:1.0];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.acceptButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.93 blue:0.42 alpha:1.0];
    self.acceptButton.layer.cornerRadius = 25.0;
    self.acceptButton.titleLabel.font = [BGRecharge semibold:13];
    [self.acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
    [self.acceptButton setTitleColor:[UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0] forState:UIControlStateNormal];
    self.acceptButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.cardView];
    [self.cardView addSubview:self.avatarView];
    [self.cardView addSubview:self.nameLabel];
    [self.cardView addSubview:self.acceptButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kFriendRequestSidePadding],
        [self.cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kFriendRequestSidePadding],
        [self.cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.cardView.heightAnchor constraintEqualToConstant:kFriendRequestCardHeight],

        [self.avatarView.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:16.0],
        [self.avatarView.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.avatarView.widthAnchor constraintEqualToConstant:46.0],
        [self.avatarView.heightAnchor constraintEqualToConstant:46.0],

        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:12.0],
        [self.nameLabel.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.acceptButton.leadingAnchor constant:-12.0],

        [self.acceptButton.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-10.0],
        [self.acceptButton.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.acceptButton.widthAnchor constraintEqualToConstant:116.0],
        [self.acceptButton.heightAnchor constraintEqualToConstant:50.0],
    ]];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
       unsigned char usersd[] = {173,19,128,48,84,40,6};
    NSString * promptr = [NSString stringWithUTF8String:(char []){115,101,97,114,99,104,101,100,0}];
   for (int n = 0; n < 2; n++) {
      usersd[0] /= MAX(5, usersd[1]);
   }

   self.container_padding = 33.0;

   self.messageMax = 79.0;

   self.rowSize = 42.0;

   self.canPosts = YES;

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self fractionFailContactScreenFoundView];
    }
    return self;
   if (4 < usersd[2]) {
       NSDictionary * remove4 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){117,112,108,111,97,100,115,0}],@(797).stringValue, nil];
      volatile  long queueK = 2;
         queueK >>= MIN(3, remove4.allValues.count);
   }
   for (int r = 0; r < 2; r++) {
   }
}

@end
