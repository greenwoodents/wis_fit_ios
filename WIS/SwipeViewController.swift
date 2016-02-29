//
//  JXSwipeBetweenViewControllers.swift
//  JXSwipeBetweenViewControllers
//
//  Created by Jonathan Xie on 5/18/15.
//  Copyright (c) 2015 Jonathan Xie. All rights reserved.
//

import UIKit


class JXSwipeBetweenViewControllers: UINavigationController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {
    
    // Constant to determine which swipable screen to show first
    // 0 = Left Screen, 1 = Middle Screen, 2 = Right Screen
    let STARTING_INDEX:Int = 1;
    
    // Set the current screen to the middle one
    var currentPageIndex:Int!
    
    // The page view controller that holds all the scrollable UIViewcontrollers
    var pageController:UIPageViewController!
    
    // Reference to the UIScrollView in the pageController UIPageViewController above
    var pageScrollView:UIScrollView!
    
    // Holds the UIViewControllers to scroll through
    var viewControllerArray:[UIViewController]!
    
    // Prevents scrolling
    var isPageScrollingFlag:Bool!
    
    // Prevents reloading to maintain state
    var hasAppearedFlag:Bool!
    
    // Buttons in the navigation bar
    var leftButton: UIButton!
    var middleButton: UIButton!
    var rightButton: UIButton!
    
    var logoutButton: UIButton!
    
    var selector:UISegmentedControl!
    
    // Holds the nav buttons above and will set it to: pageController.navigationController.navigationBar.topItem.titleView
    var navigationView:NavigationView!
    
    var loggedIn: Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let tmpLoggedIn = defaults.boolForKey("loggedIn")
        return tmpLoggedIn
    }
    
    
    
    
    
    
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        setUpPageViewController()
        setupNavigationButtons()
        hasAppearedFlag = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayNavigationElements:", name: "displayNavigationElementsID", object: nil)
        
        self.navigationBar.translucent = false;
        
        viewControllerArray = [UIViewController]()
        currentPageIndex = STARTING_INDEX; // Set it to the middle index of 1 since we're starting off there
        isPageScrollingFlag = false;
        hasAppearedFlag = false;
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func setUpPageViewController() {
        pageController = self.topViewController as! UIPageViewController;
        pageController.delegate = self;
        pageController.dataSource = self;
        
        // Set the initial swipable view controller to the first one to match the currentPageIndex instance variable
        pageController.setViewControllers(
            [viewControllerArray[STARTING_INDEX]], // Set the initial swipable view ot the first one
            direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        syncScrollView();
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Allows us to get information back from the UIScrollView via its delegate methods,
    // namely the coordinate information to shift the navigation buttons left or right
    func syncScrollView() {
        for view in pageController.view.subviews {
            if(view.isKindOfClass(UIScrollView)) {
                self.pageScrollView = view as! UIScrollView
                self.pageScrollView.delegate = self;
                self.pageScrollView.scrollEnabled = false
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func setupNavigationButtons() {
        
        //println("self.navigationBar.frame.size.width = \(self.navigationBar.frame.size.width)");
        
        // Create a new UIView that has the weight and height of the navigation bar
        // This will be a subview of the navigation bar
        navigationView = NavigationView(frame: CGRectMake(0, 0, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height))
        
        let symbols = [ String.fontAwesomeIconWithName(FontAwesome.Calendar),
            String.fontAwesomeIconWithName(FontAwesome.ClockO),
            String.fontAwesomeIconWithName(FontAwesome.Inbox)]
        
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.fontAwesomeOfSize(20)
        ]
        let selectedTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.fontAwesomeOfSize(20)
        ]
        
        
        selector = UISegmentedControl(items:symbols)
        selector.selectedSegmentIndex = 1
        selector.frame.size.width = selector.frame.size.width + 100
        selector.frame = CGRectMake(
            self.navigationBar.center.x - (selector.frame.size.width/2),
            self.navigationBar.center.y - (selector.frame.size.height/2),
            selector.frame.size.width,
            selector.frame.size.height
        )
        
        selector.tintColor = UIColor.blackColor()
        selector.setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        selector.setTitleTextAttributes(selectedTextAttributes, forState: .Selected)
        selector.apportionsSegmentWidthsByContent = true
        selector.addTarget(self, action: "touchedNavBarButton:", forControlEvents: .ValueChanged)
        
        
        navigationView.addSubview(selector)
        
        navigationBar.addSubview(navigationView)
        
        
        
        rightButton = UIButton()
        rightButton.tag = 2
        rightButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        rightButton.addTarget(self, action: "logout:", forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.setTitle("Odhlasit", forState: UIControlState.Normal)
        rightButton.sizeToFit()
        
        navigationView.addSubview(rightButton)
        
        
        rightButton.frame = CGRectMake(
            (self.navigationBar.frame.size.width as CGFloat) - rightButton.frame.size.width - 10,
            (self.navigationBar.frame.size.height as CGFloat) - rightButton.frame.size.height - 10,
            rightButton.frame.size.width,
            rightButton.frame.size.height)
        
        if !loggedIn {
            selector.hidden = true
            rightButton.hidden = true
        }
    }
    
    
    
    func displayNavigationElements(notification: NSNotification) {
        selector.hidden = false
        rightButton.hidden = false
    }
    
    
    
    
    func touchedNavBarButton(segmentControl: UISegmentedControl) {
        if (!self.isPageScrollingFlag) {
            
            
            let tempIndex = self.currentPageIndex
            
            // Check to see if you're going from left -> right or right -> left
            if (segmentControl.selectedSegmentIndex > tempIndex) {
                
                
                //scroll through all the objects between the two points
                var i:Int = tempIndex;
                for i = tempIndex+1; i <= segmentControl.selectedSegmentIndex; i++ {
                    
                    pageController.setViewControllers(
                        [viewControllerArray[i]],
                        direction: UIPageViewControllerNavigationDirection.Forward,
                        animated: true,
                        completion: {[unowned self] (complete:Bool) -> Void in
                            
                            if(complete) {
                                
                                self.updateCurrentPageIndex(i-1) // I had an off by 1 error here for some reason
                            }
                        }
                    )
                }
            }
                
            else if (segmentControl.selectedSegmentIndex < tempIndex) {
                
                //println("Going reverse since button.tag = \(button.tag)")
                var i:Int = tempIndex;
                for i = tempIndex-1; i >= segmentControl.selectedSegmentIndex; i-- {
                    //println("i in reverse for loop = \(i) and button.tag = \(button.tag)")
                    pageController.setViewControllers([viewControllerArray[i]],
                        direction: UIPageViewControllerNavigationDirection.Reverse,
                        animated: true,
                        completion: {[unowned self] (complete:Bool) -> Void in
                            if(complete) {
                                //println("i in complete reverse for loop = \(i) and button.tag = \(button.tag)")
                                self.updateCurrentPageIndex(i+1) // I had an off by 1 error here for some reason
                            }
                        }
                    )
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func logout(sender: UIBarButtonItem) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let loggedIn = defaults.objectForKey("loggedIn") as? Bool {
            if loggedIn {
                let alert = UIAlertController(title: "Odhlásit se", message: "Chceš se opravdu odhlásit?", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "Ano", style: .Default, handler: { action in
                    defaults.setBool(false, forKey: "loggedIn")
                    defaults.setObject("", forKey: "login")
                    defaults.setObject("", forKey: "passwd")
                    defaults.setValue(nil, forKey: "class")
                    defaults.synchronize()
                    
                    UIView.animateWithDuration(0.5) {
                        self.selector.hidden = false
                        self.rightButton.hidden = false
                    }
                    
                    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                        NotificationManager().deleteCoreData()
                    }
                    
                    let appDelegate = UIApplication.sharedApplication()
                    appDelegate.cancelAllLocalNotifications()
                    
                    let notifTableView = self.viewControllerArray[1] as! ViewController
                    notifTableView.expandableCells.removeAll()
                    //                    self.navigationItem.rightBarButtonItem = nil
                    
                    self.selector.selectedSegmentIndex = 1
                    self.touchedNavBarButton(self.selector)
                    self.selector.hidden = true
                    self.rightButton.hidden = true
                    
                    
                    notifTableView.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Ne", style: .Cancel, handler: { action in }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Make sure to update the current index after swiping or touching the button is done
    func updateCurrentPageIndex(newIndex:Int) {
        self.currentPageIndex = newIndex;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: UIScrollView Delegate Methods
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: UIPageViewController Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfController(viewController)
        
        if ((index == NSNotFound) || (index == 0)) {
            return nil;
        }
        
        index--;
        
        return viewControllerArray[index];
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfController(viewController)
        
        if (index == NSNotFound) {
            return nil;
        }
        
        index++;
        
        if (index == viewControllerArray.count) {
            return nil;
        }
        
        return viewControllerArray[index];
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(completed) {
            currentPageIndex = indexOfController(pageViewController.viewControllers!.last!);
        }
    }
    
    
    //    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
    //
    //        if(completed) {
    //            currentPageIndex = indexOfController(pageViewController.viewControllers.last as! UIViewController);
    //        }
    //    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Checks to see which item we are currently looking at from the array of view controllers.
    func indexOfController(viewController:UIViewController) -> Int {
        for i in 0..<viewControllerArray.count {
            if viewController == viewControllerArray[i] {
                return i;
            }
        }
        return NSNotFound;
    }
    
    // MARK: Scroll View Delegate Functions
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isPageScrollingFlag = false
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        isPageScrollingFlag = false
    }
    
}