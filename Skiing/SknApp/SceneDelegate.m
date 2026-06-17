

#import "SceneDelegate.h"
#import "RGUnlockPlayerController.h"
#import "WGDesignController.h"
#import "BFriendshipTokens.h"
#import "VBLaunchLifestyleController.h"

extern void NCSlopeActivateFeatureFromScene(void);


@interface SceneDelegate ()


@property(nonatomic, assign)BOOL  is_Home;
@property(nonatomic, assign)double  delegate_e4;
@property(nonatomic, assign)long  persistIdx;


@end

@implementation SceneDelegate

-(NSString *)mineRoomSpeakerAlwaysPositionBridge{
    NSDictionary * validatev = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){110,105,107,111,110,0}],@(785), nil];
   volatile  double colorc = 4.0f;
    NSString * followingb = [NSString stringWithUTF8String:(char []){112,117,115,104,105,110,103,0}];
   while (![validatev.allValues containsObject:@(colorc)]) {
      volatile  double empty1 = 2.0f;
      volatile  int friendship0 = 5;
       BOOL previous0 = YES;
         previous0 = 96.69f > empty1;
      for (int l = 0; l < 2; l++) {
         previous0 = previous0 || friendship0 >= 95;
      }
         empty1 -= ((previous0 ? 4 : 2) - friendship0);
      if (3 > (friendship0 ^ 3)) {
         previous0 = !previous0 && friendship0 < 68;
      }
         friendship0 ^= (friendship0 & (previous0 ? 5 : 2));
       double launchV = 1.0f;
      volatile  double user7 = 3.0f;
         empty1 /= MAX(1, friendship0 + 1);
         friendship0 ^= (int)user7 ^ 3;
       NSDictionary * privacy1 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){97,101,115,0}],@(786).stringValue, nil];
       NSDictionary * make6 = @{[NSString stringWithUTF8String:(char []){112,114,101,102,105,120,101,115,0}]:@(477), [NSString stringWithUTF8String:(char []){104,117,101,0}]:@(473).stringValue, [NSString stringWithUTF8String:(char []){98,102,114,97,99,116,105,111,110,0}]:@(79).stringValue};
         launchV -= ((int)launchV | (previous0 ? 4 : 2));
         friendship0 += privacy1.count;
         friendship0 &= 3 & make6.count;
         friendship0 ^= privacy1.count % 3;
         friendship0 %= MAX(1, make6.count % 3);
      colorc -= 3;
      break;
   }
      colorc += validatev.count;
      colorc -= 2 + validatev.count;
   for (int q = 0; q < 1; q++) {
       char controlx[] = {4,(char)-41,123,84,88,(char)-82,(char)-75,(char)-31};
       unsigned char tokensv[] = {132,191};
       int playR = 3;
      do {
         int segmentg = sizeof(tokensv) / sizeof(tokensv[0]);
         controlx[3] >>= MIN(1, labs((1 + segmentg) | controlx[6]));
         if (validatev.count == 683088) {
            break;
         }
      } while ((validatev.count == 683088) && (controlx[5] <= 4));
       float indicator5 = 1.0f;
       float actionT = 1.0f;
         tokensv[MAX(0, playR % 2)] %= MAX(5, (int)indicator5 | playR);
      for (int j = 0; j < 1; j++) {
         int summaryC = sizeof(tokensv) / sizeof(tokensv[0]);
         actionT -= summaryC;
      }
       double delegate_qC = 2.0f;
      for (int f = 0; f < 1; f++) {
         indicator5 /= MAX((int)delegate_qC * 3, 4);
      }
       NSString * emailR = [NSString stringWithUTF8String:(char []){109,98,117,102,99,104,97,105,110,0}];
         playR -= emailR.length;
      if (5.97f < (indicator5 / (MAX(actionT, 7))) && (actionT / (MAX(5.97f, 1))) < 5.71f) {
         volatile  unsigned char dialogbOld[] = {46,121};
          unsigned char* dialogb = (unsigned char*)dialogbOld;
          BOOL settings2 = NO;
          NSString * main_hD = [NSString stringWithUTF8String:(char []){105,110,118,97,108,105,100,97,116,105,111,110,0}];
         volatile  char friendshipPCopy[] = {15,(char)-48,(char)-62};
          char* friendshipP = (char*)friendshipPCopy;
         long loginH = sizeof(friendshipP) / sizeof(friendshipP[0]);
         actionT -= 2 ^ loginH;
         long signA = sizeof(controlx) / sizeof(controlx[0]);
         dialogb[0] -= (1 + signA) ^ dialogb[0];
         settings2 = tokensv[1] > 70;
         playR >>= MIN(labs(3 * main_hD.length), 3);
         playR >>= MIN(labs(main_hD.length * 2), 1);
      }
      playR |= followingb.length;
   }
   return followingb;

}







- (void)sceneWillResignActive:(UIScene *)scene {

       BOOL chatI = YES;
   volatile  long remindere = 5;
   for (int o = 0; o < 1; o++) {
      chatI = remindere > 78 && chatI;

         {
NSString * reconnectionStrglobOld = [self mineRoomSpeakerAlwaysPositionBridge];
NSString * reconnectionStrglob = (NSString *)reconnectionStrglobOld;

      int reconnectionStrglob_len = reconnectionStrglob.length;
      if ([reconnectionStrglob isKindOfClass:NSString.class] && [reconnectionStrglob isEqualToString:@"reuse"]) {
              NSLog(@"%@",reconnectionStrglob);
      }


}
   }
      chatI = remindere > 44 && !chatI;

    
    
}



- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

       long labelh = 1;
   do {
      labelh ^= labelh * labelh;
      if (1401516 == labelh) {
         break;
      }
   } while ((1401516 == labelh) && ((labelh - labelh) <= 4 || 4 <= (labelh - labelh)));

    UIWindowScene *table = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:table];

    UIViewController *showsController;
    if ([BFriendshipTokens isLoggedIn]) {
        showsController = [[WGDesignController alloc] init];
    } else {
        RGUnlockPlayerController *followController = [[RGUnlockPlayerController alloc] init];
        UINavigationController *handlesView = [[UINavigationController alloc] initWithRootViewController:followController];
        [handlesView setNavigationBarHidden:YES animated:NO];
        showsController = handlesView;
    }

    self.window.rootViewController = showsController;
    [self.window makeKeyAndVisible];
    NCSlopeActivateFeatureFromScene();
}

-(int)videoThanBannerApplyText:(NSArray *)emailEngagement clearSeed:(NSArray *)clearSeed labelPoster:(long)labelPoster {
    float descC = 5.0f;
   volatile  char storeTCopy[] = {115,(char)-95,(char)-82,(char)-20,(char)-109,8};
    char* storeT = (char*)storeTCopy;
   volatile  int resumeb = 1;
      storeT[MAX(5, resumeb % 6)] %= MAX(4, 3);
       NSArray * featured2 = @[@(73.0)];
       int j_playerX = 4;
      while ((4 % (MAX(3, j_playerX))) < 4 || 3 < (featured2.count % (MAX(4, 2)))) {
         volatile  char pauseaCopy[] = {(char)-36,85,108,(char)-59,27,(char)-117,(char)-70,37};
          char* pausea = (char*)pauseaCopy;
          NSDictionary * promptq = @{[NSString stringWithUTF8String:(char []){114,101,99,111,100,101,0}]:@(277).stringValue};
         j_playerX /= MAX(j_playerX % (MAX(featured2.count, 10)), 1);
         pausea[MAX(4, j_playerX % 8)] -= j_playerX;
         j_playerX ^= promptq.count;
         j_playerX -= 2 - promptq.count;
         break;
      }
         j_playerX %= MAX(featured2.count, 2);
      for (int h = 0; h < 1; h++) {
         j_playerX >>= MIN(1, labs(1));
      }
         j_playerX -= 2 | featured2.count;
      for (int x = 0; x < 1; x++) {
         volatile  double delete_in = 3.0f;
         volatile  int shownk = 0;
          char loadingO[] = {(char)-91,(char)-98,75,(char)-113,39,(char)-20,86};
         volatile  char refreshZCopy[] = {66,74,54,57,(char)-93,(char)-98,27,71};
          char* refreshZ = (char*)refreshZCopy;
         j_playerX -= (int)delete_in * 2;
         shownk |= (int)delete_in | 1;
         loadingO[6] |= 2 - shownk;
         refreshZ[MAX(j_playerX % 8, 5)] /= MAX(3, 3);
      }
      do {
          float blockedh = 3.0f;
          char prompty[] = {(char)-34,(char)-78,108,44,9,54,(char)-100,(char)-46,(char)-44,125};
          double v_title7 = 5.0f;
          char mineX[] = {(char)-123,(char)-87,(char)-93,(char)-17,(char)-63,41,(char)-105,(char)-43,(char)-49,(char)-91,(char)-36,15};
          char range9[] = {64,68,31,45,9,122,(char)-8,34,102,17};
         j_playerX |= featured2.count;
         blockedh += (int)v_title7;
         prompty[8] %= MAX((int)v_title7 >> (MIN(2, labs((int)blockedh))), 5);
         mineX[9] >>= MIN(labs(mineX[1] + featured2.count), 2);
         NSInteger dictionaryR = sizeof(range9) / sizeof(range9[0]);
         range9[6] &= (int)v_title7 << (MIN(labs(dictionaryR), 3));
         if (featured2.count == 119474) {
            break;
         }
      } while ((featured2.count == 119474) && (![featured2 containsObject:@(j_playerX)]));
      resumeb -= storeT[3];
      descC -= (int)descC;
   return resumeb;

}







- (void)sceneWillEnterForeground:(UIScene *)scene {

         {
int choiceSubscript = [self videoThanBannerApplyText:[NSArray arrayWithObjects:@(21), @(776), nil] clearSeed:@[@(4), @(532)] labelPoster:84];

      if (choiceSubscript <= 48) {
             NSLog(@"%d",choiceSubscript);
      }


}

       NSDictionary * delegate_mJ = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){108,111,117,100,110,101,115,115,0}],@(492).stringValue, nil];

    
    
}

-(NSArray *)whiteRegularSheet:(NSString *)centerHandler {
    NSArray * publishS = [NSArray arrayWithObjects:@(37), nil];
    char commong[] = {(char)-56,(char)-113,76,(char)-59,10,(char)-119,(char)-4,(char)-116,89,(char)-54};
    NSArray * main_x7 = [NSArray arrayWithObjects:@(480), @(452), nil];
   if (3 == commong[7]) {
      commong[0] += main_x7.count * commong[7];
   }
   while (4 == (3 & publishS.count) && 3 == (commong[7] & publishS.count)) {
      commong[6] &= publishS.count / (MAX(commong[4], 3));
      break;
   }
   for (int m = 0; m < 2; m++) {
   }
   return publishS;

}







- (void)sceneDidDisconnect:(UIScene *)scene {

         {
NSArray * mousLiteralOld = [self whiteRegularSheet:[NSString stringWithUTF8String:(char []){98,97,122,101,108,0}]];
NSArray * mousLiteral = (NSArray *)mousLiteralOld;

      int mousLiteral_len = mousLiteral.count;
      [mousLiteral enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          if (idx < 0) {
              NSLog(@"temporary:%@", obj);
        }
      }];


}

      volatile  NSDictionary * sheetyCopy = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){110,105,109,97,116,105,111,110,0}],@(991), nil];
    NSDictionary * sheety = (NSDictionary *)sheetyCopy;
    unsigned char followerL[] = {221,142,92,169,70,134,36};
      volatile  double dialogI = 3.0f;
      if ((dialogI / (MAX(7, 5.49f))) == 2.2f || (5.49f / (MAX(9, dialogI))) == 5.98f) {
         dialogI -= (int)dialogI | (int)dialogI;
      }
       NSArray * changer = @[[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char []){97,100,106,101,99,116,105,118,101,115,0}], [NSString stringWithUTF8String:(char []){112,103,109,120,0}], nil]];
       NSArray * lifestyleF = [NSArray arrayWithObjects:@(297), @(661), nil];
         dialogI += changer.count;
         dialogI /= MAX(lifestyleF.count, 3);
         dialogI -= lifestyleF.count - 3;
      followerL[3] &= (int)dialogI - sheety.allValues.count;
       float contentJ = 4.0f;
      volatile  NSString * speakerLOld = [NSString stringWithUTF8String:(char []){115,112,97,119,110,97,98,108,101,0}];
       NSString * speakerL = (NSString *)speakerLOld;
      for (int k = 0; k < 2; k++) {
          char settingsM[] = {103,(char)-99,(char)-52,91,91,(char)-90,64,(char)-48};
          unsigned char home5[] = {163,63,232,158,107,116,219,233,81,147,84};
         volatile  char roomnCopy[] = {81,(char)-17,(char)-83,(char)-39};
          char* roomn = (char*)roomnCopy;
         contentJ += speakerL.length;
         long incomingW = sizeof(home5) / sizeof(home5[0]);
         settingsM[5] ^= incomingW % (MAX(settingsM[7], 6));
         long addv = sizeof(settingsM) / sizeof(settingsM[0]);
         roomn[3] %= MAX(5, addv * roomn[2]);
      }
         contentJ -= speakerL.length;
      for (int u = 0; u < 1; u++) {
          char relationshipq[] = {55,(char)-82,(char)-64,(char)-24,117,(char)-93,(char)-19,70,(char)-65};
         volatile  long followersG = 3;
         followersG += speakerL.length;
         relationshipq[MAX(followersG % 9, 2)] /= MAX(3, 3);
      }
      while ([speakerL containsString:@(contentJ).stringValue]) {
         contentJ += speakerL.length / 2;
         break;
      }
         contentJ /= MAX(4, speakerL.length);
       char micZ[] = {(char)-112,86,(char)-67,(char)-87};
         micZ[1] ^= 1 - (int)contentJ;
      int fileN = sizeof(followerL) / sizeof(followerL[0]);
      followerL[0] >>= MIN(2, labs(fileN + speakerL.length));
   do {
      if (sheety.count == 2942855) {
         break;
      }
   } while (((sheety.allValues.count | 1) <= 2 && (1 | sheety.allValues.count) <= 5) && (sheety.count == 2942855));

    
    
    
    
}



- (void)sceneDidBecomeActive:(UIScene *)scene {

       double needsC = 4.0f;
   do {
      needsC += 3 << (MIN(labs((int)needsC), 1));
      if (needsC == 1914281.f) {
         break;
      }
   } while ((needsC == 1914281.f) && ((4 - needsC) >= 1.18f));

   self.is_Home = NO;

   self.delegate_e4 = 3.0;

   self.persistIdx = 88;

   self.backMin = 24.0;

   self.commentSum = 19;

   self.enterIndex = 26;

   self.inputPadding = 41.0;

    
    
}



- (void)sceneDidEnterBackground:(UIScene *)scene {

      volatile  NSDictionary * colorKCopy = @{[NSString stringWithUTF8String:(char []){108,115,112,112,111,108,121,102,0}]:@(243).stringValue, [NSString stringWithUTF8String:(char []){115,111,117,110,0}]:@(770), [NSString stringWithUTF8String:(char []){97,100,100,105,116,105,111,110,115,0}]:@(744)};
    NSDictionary * colorK = (NSDictionary *)colorKCopy;
   volatile  int dismissH = 1;
   if ((colorK.allValues.count << (MIN(3, labs(dismissH)))) >= 1 || 2 >= (colorK.allValues.count << (MIN(labs(1), 4)))) {
      dismissH >>= MIN(5, colorK.count);
   }
   while (1 < (dismissH % (MAX(colorK.allKeys.count, 8))) || (dismissH % (MAX(2, colorK.allKeys.count))) < 1) {
      dismissH += colorK.count;
      break;
   }

    
    
    
}


@end
