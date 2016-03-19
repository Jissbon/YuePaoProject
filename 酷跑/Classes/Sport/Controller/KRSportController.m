//
//  KRSportController.m
//  酷跑
//
//  Created by apple on 16/3/7.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KRSportController.h"
#import "BMapKit.h"
#import "BMKLocationService.h"
#import "AFNetworking.h"
#import "KRUserInfo.h"
#import "NSString+md5.h"
#import "MBProgressHUD+KR.h"
/**枚举:记录开始跑步与否,记录划线还是不划线*/
typedef  enum
{
    TrailStart = 1,
    TrailEnd
    
}Trail;


@interface KRSportController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>

/**地图View类，使用此View可以显示地图窗口，并且对地图进行相关的操作*/
@property (nonatomic,strong) BMKMapView *mapView;

/**百度地图地理位置*/
@property (nonatomic,strong)BMKLocationService *bmkLocationService;

/**控制开始还是没开始跑步的属性*/
@property (nonatomic,assign) Trail trail;

//开始跑步按钮与暂停按钮
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseSportBtn;

//起点与终点大头针
@property (nonatomic,strong) BMKPointAnnotation *startAnnotation;
@property (nonatomic,strong) BMKPointAnnotation *endAnnotation;

/**用户运动路径的遮盖线*/
@property (nonatomic,strong) BMKPolyline *polyLine;
/**用户位置数组*/
@property (nonatomic,strong) NSMutableArray *locationArrayM;
/**保存用户的上一个位置*/
@property (nonatomic,strong) CLLocation *preLocation;
/**运动总距离*/
@property (nonatomic,assign) double sumDistance;
/**运动的总时间和总热量*/
@property (nonatomic,assign) double sumSportTime;//总时间
@property (nonatomic,assign) double sumHeat;//总热量


@property (weak, nonatomic) IBOutlet UIView *stopView;
@property (weak, nonatomic) IBOutlet UIView *runningEndView;

@end

@implementation KRSportController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setbmkLocationserviceInit];
    [self setmapviewProperty];
    self.bmkLocationService.delegate = self;
    /**启动定位服务*/
    [self.bmkLocationService startUserLocationService];
    self.trail = TrailEnd;
    self.pauseSportBtn.hidden = YES;
    self.stopView.hidden = YES;//隐藏stopview
    
    /**为暂停按钮添加下拉手势*/
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(pauseSportSwipe)];
    gesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.pauseSportBtn addGestureRecognizer:gesture];
    
    self.runningEndView.hidden = YES;
}

/**下拉响应事件*/
-(void)pauseSportSwipe
{
    /** 停止定位服务 */
    [self.bmkLocationService stopUserLocationService];
    self.stopView.hidden = NO;
    self.pauseSportBtn.hidden = YES;
    
}

- (NSMutableArray *)locationArrayM {
    if(_locationArrayM == nil) {
        _locationArrayM = [NSMutableArray array];
    }
    return _locationArrayM;
}

/**初始化:bmkLocationService*/
-(void)setbmkLocationserviceInit
{
    self.bmkLocationService = [[BMKLocationService alloc]init];
    //指定定位的最小更新距离(米)
    [BMKLocationService setLocationDistanceFilter:10];
    //地图的定位精确度
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
}

//mapview的初始化
- (BMKMapView *)mapView {
    if(_mapView == nil) {
        _mapView = [[BMKMapView alloc]init];
        [self.view insertSubview:_mapView atIndex:0];
        _mapView.delegate = self;
    }
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    return _mapView;
}
/**mapview的属性设置*/
-(void)setmapviewProperty
{
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    self.mapView.showMapScaleBar = YES;
    self.mapView.rotateEnabled = NO;
    self.mapView.mapScaleBarPosition = CGPointMake(10, self.view.bounds.size.height-50);//比例尺的位置
    
    //定位图层的显示
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    displayParam.isRotateAngleValid = YES;//跟随态旋转角度是否生效
    displayParam.locationViewOffsetX = 0;//定位图标偏移量X
    displayParam.locationViewOffsetY = 0;//定位图标偏移量Y
    [self.mapView updateLocationViewWithParam:displayParam];
}

/**监听用户位置变化*/
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    MYLog(@"用户纬度:%lf,用户经度:%lf",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    //定位到用户位置的生活更新一下用户当前的位置
    [self.mapView updateLocationData:userLocation];
    
    /**显示当前位置为中心点,并显示范围*/
    if (self.trail == TrailEnd) {
        BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.002, 0.002))];
        [self.mapView setRegion:adjustRegion animated:YES];
    }
    /** 判断用户是否在户外 */
    if (userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
        return;
    }
    /** 开始运动 */
    if(self.trail == TrailStart){
        // 开始用户路径跟踪
        [self  startTrailRouterWithUserLocation:userLocation];
        [self.mapView setRegion:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.002, 0.002)) animated:YES];
    }
}
/** 用户路径跟踪 */
- (void) startTrailRouterWithUserLocation:(BMKUserLocation*)userLocation
{
   
    if(self.preLocation){
        /** 计算当前点 和 前一个点的距离 */
        double distance = [userLocation.location distanceFromLocation:self.preLocation];
        self.sumDistance += distance;
    }
     self.preLocation = userLocation.location;
    /** 把用户当前位置 放入数组中 */
    [self.locationArrayM addObject:userLocation.location];
    /** 根据数组中的位置 绘制到地图上 */
    [self  drawWalkLine];
    
}
/** 画线 */
- (void) drawWalkLine
{
    NSInteger count = self.locationArrayM.count;
//    int  x;
    BMKMapPoint  *points = malloc(sizeof(BMKMapPoint)*count);//结构体指针
    
    /** 把locationArrM 中位置 转换成 BMKMapPoint  存入 points 对应的
     堆内存中 */
    [self.locationArrayM  enumerateObjectsUsingBlock:^(CLLocation* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /** 根据位置 转换成一个点 */
        BMKMapPoint point = BMKMapPointForCoordinate(obj.coordinate);
        points[idx] = point;
    }];
    /**移除原来的线*/
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
    }
    self.polyLine = [BMKPolyline polylineWithPoints:points count:count];
    // 把折线对象 绘制到地图上
    //把上一次画的线清除
    [self.mapView addOverlay:self.polyLine];
    
    // 释放堆内存
    free(points);
}

/** 折线应该如何显示 */
- (BMKOverlayView*) mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView * polyLineView  = [[BMKPolylineView alloc]initWithOverlay:overlay];
        polyLineView.lineWidth = 3;
        polyLineView.strokeColor = [UIColor redColor];
        return polyLineView;
    }
    return  nil;
}


//开始跑步
- (IBAction)startRun:(UIButton *)sender {
    
    
    self.sumDistance = 0;
    /**启动定位服务*/
    [self.bmkLocationService startUserLocationService];
    self.startBtn.hidden = YES;
    self.pauseSportBtn.hidden = NO;
    self.trail = TrailStart;
    /**在运动起点产生大头针*/
    self.startAnnotation = [self createPointAnnotation:self.bmkLocationService.userLocation.location titile:@"起点"];
    /*把用户当前位置存入locationArraym*/
    [self.locationArrayM addObject:self.bmkLocationService.userLocation.location];
}

/** 用来产生大头针的方法 */
- (BMKPointAnnotation*) createPointAnnotation:(CLLocation*) location titile:(NSString*) title
{
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc]init];
    point.coordinate = location.coordinate;
    point.title = title;
    // 添加大头针
    [self.mapView addAnnotation:point];
    return point;
}

/** 显示大头针 */
- (BMKAnnotationView*) mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *view = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        /** 起点大头针没值 就设置起点图片 否则设置终点图片 */
        if (self.startAnnotation) {
            view.image = [UIImage imageNamed:@"终点"];
        }else{
            view.image = [UIImage imageNamed:@"起点"];
        }
        view.animatesDrop = YES;
        view.draggable = NO;
        return view;
    }
    return  nil;
}


//下拉暂停
- (IBAction)pauseSport:(UIButton *)sender {
    
}

//继续按钮
- (IBAction)continue:(UIButton *)sender {
    MYLog(@"继续");
    self.stopView.hidden = YES;
    self.pauseSportBtn.hidden = NO;
    [self.bmkLocationService startUserLocationService];
}
//完成按钮
- (IBAction)finish:(UIButton *)sender {
    MYLog(@"完成");
    self.stopView.hidden = YES;
    [self.bmkLocationService stopUserLocationService];
    self.endAnnotation = [self createPointAnnotation:[self.locationArrayM lastObject] titile:@"终点"];
    [self mapViewFitRectForPolyLine];
    
    /**计算运动完成时 热量和运动总时间*/
    CLLocation *firstLoc = self.locationArrayM.firstObject;
    CLLocation *lastLoc = self.locationArrayM.lastObject;
    self.sumSportTime = lastLoc.timestamp.timeIntervalSince1970- firstLoc.timestamp.timeIntervalSince1970;//运动总时长
    self.sumHeat = (self.sumSportTime/3600.00)*700;
   
    
    /**显示运动完成界面*/
    self.runningEndView.hidden = NO;
    
    self.trail = TrailEnd;
}

/** 根据折线对象中的点 算显示范围 */
- (void) mapViewFitRectForPolyLine
{
    CGFloat  ltX,ltY,maxX,maxY;
    if (_polyLine.pointCount < 2) {
        return;
    }
    BMKMapPoint pt = self.polyLine.points[0];
    ltX = pt.x;
    maxX = pt.x;
    ltY = pt.y;
    maxY = pt.y;
    for (int i=1; i<_polyLine.pointCount; i++)
    {
        BMKMapPoint temp = self.polyLine.points[i];
        if (temp.x < ltX )
        {
            ltX = temp.x;
        }
        if (temp.y < ltY)
        {
            ltY = temp.y;
        }
        if (temp.x > maxX)
        {
            maxX = temp.x;
        }
        if (temp.y > maxY)
        {
            maxY = temp.y;
        }
    }
    
    /** 算出一个矩形 */
    BMKMapRect  rect ;
    rect.origin  = BMKMapPointMake(
                                   ltX - 40, ltY - 60);
    rect.size = BMKMapSizeMake((maxX - ltX)+80, (maxY - ltY)+120);
    
    //设置地图的可视范围;
    [self.mapView setVisibleMapRect:rect];
}

//取消按钮
- (IBAction)cancel:(UIButton *)sender {
    self.runningEndView.hidden = YES;
    self.startBtn.hidden = NO;
    //状态清理
    [self cleanState];
    /**重新调整地图显示区域*/
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.bmkLocationService.userLocation.location.coordinate, BMKCoordinateSpanMake(0.002, 0.002))];
    [self.mapView setRegion:adjustRegion animated:YES];
}

/**状态清理*/
-(void)cleanState
{
    self.sumDistance = 0;
    [self.locationArrayM removeAllObjects];
    if (self.startAnnotation) {
        [self.mapView removeAnnotation:self.startAnnotation];
        self.startAnnotation = nil;
    }
    if (self.endAnnotation) {
        [self.mapView removeAnnotation:self.endAnnotation];
        self.endAnnotation = nil;
    }
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
        self.polyLine = nil;
    }
    
}


/**点击保存按钮,把数据保存到服务器*/
- (IBAction)keepBtn:(UIButton *)sender {
    [self saveSportDateToServer];//调用保存数据的方法
    [self cancel:nil];//同时调用清理状态的方法
}

/**保存数据的方法*/
-(void)saveSportDateToServer
{
    NSString *urlstr = [NSString stringWithFormat:@"http://%@:8080/%@/addSportData.jsp",KRXMPPHOSTNAME,KRALLRUNSERVER];
    /**请求参数*/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [KRUserInfo sharedKRUserInfo].userName;
    parameters[@"md5password"] = [[KRUserInfo sharedKRUserInfo].userPasswd md5StrXor];
    parameters[@"sportType"] = @(2);
    /**data参数*/
    CLLocation *firstLoc = self.locationArrayM.firstObject;
    CLLocation *lastLoc = self.locationArrayM.lastObject;
    NSString *dataStr = [NSString stringWithFormat:@"%lf|%lf|%lf@%lf|%lf|%lf",[firstLoc.timestamp timeIntervalSince1970],firstLoc.coordinate.latitude,firstLoc.coordinate.latitude,[lastLoc.timestamp timeIntervalSince1970],lastLoc.coordinate.latitude,lastLoc.coordinate.latitude];
    parameters[@"data"] = dataStr;
    parameters[@"sportStartTime"] = @(firstLoc.timestamp.timeIntervalSince1970);
    parameters[@"sportDistance"] = @(self.sumDistance);//运动总距离
    double st = lastLoc.timestamp.timeIntervalSince1970- firstLoc.timestamp.timeIntervalSince1970;//运动总时长
    parameters[@"sportTimeLen"] = @(st);
    parameters[@"sportHeat"] = @((st/3600.00)*700);
    /**运动的总距离 总热量 总时间
     爬楼梯1500级（不计时） 250卡
     快走（一小时8公里） 　　 555卡
     快跑(一小时12公里） 700卡
     单车(一小时9公里) 245卡
     单车(一小时16公里) 415卡
     单车(一小时21公里) 655卡
     舞池跳舞 300卡
     健身操 300卡
     骑马 350卡
     网球 425卡
     爬梯机 680卡
     手球 600卡
     桌球 300卡
     慢走(一小时4公里) 255卡
     慢跑(一小时9公里) 655卡
     游泳(一小时3公里) 550卡
     有氧运动(轻度) 275卡
     有氧运动(中度) 350卡
     高尔夫球(走路自背球杆) 270卡
     锯木 400卡
     体能训练 300卡
     走步机(一小时6公里) 345卡
     轮式溜冰 350卡
     跳绳 660卡
     郊外滑雪(一小时8公里) 600卡
     练武术 790*/
    
    /**上传数据到服务器*/
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:urlstr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"%@",error);
    }];
}

/**获取截图*/
-(UIImage *)takeImage
{
    UIImage *sportimage = [self.mapView takeSnapshot];
    return sportimage;
}

/**保存数据到新浪微博*/
-(void) saveSportDataToSina{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = @"https://upload.api.weibo.com/2/statuses/upload.json";
    
    NSMutableDictionary *paremeters = [NSMutableDictionary dictionary];
    //必选参数1:access_token
    paremeters[@"access_token"] = [KRUserInfo sharedKRUserInfo].userPasswd;
    NSString *statuesStr = [NSString stringWithFormat:@"本次运动的总距离%.1lf米,运动总时长:%.1lf秒,消耗总热量:%.4lf卡",self.sumDistance,self.sumSportTime,self.sumHeat];
    //必选参数2:status
    paremeters[@"status"] = statuesStr;
    
   [manager POST:urlStr parameters:paremeters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
       [formData appendPartWithFileData:UIImagePNGRepresentation([self takeImage]) name:@"pic2" fileName:@"sport.png" mimeType:@"image/jpeg"];
   } success:^(AFHTTPRequestOperation *operation, id responseObject) {
       [MBProgressHUD showSuccess:@"微博发送成功"];
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [MBProgressHUD showError:@"微博发送成功"];
       MYLog(@"error:%@",error);
   }];
    
}
/**分享到新浪*/
- (IBAction)sharetoSina:(UIButton *)sender {
    [self saveSportDataToSina];
    
}
/**把运动数据 和 运动图片 分享到KR*/
- (IBAction)sharetoKR:(UIButton *)sender {
    
    if ([KRUserInfo sharedKRUserInfo].isSinaLogin) {
        
    }else{
        MYLog(@"当前登陆账号不是新浪账户");
        [MBProgressHUD showError:@"请用新浪微博登陆"];
    }
}



@end
