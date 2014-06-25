//
//  DetailViewController.swift
//  Mangastream Viewer
//
//  Created by Yulian Kuncheff on 6/24/14.
//  Copyright (c) 2014 Yulian Kuncheff. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UISplitViewControllerDelegate {
  
  @IBOutlet var detailDescriptionLabel: UILabel
  @IBOutlet var mangaPageImageView: UIImageView
  var masterPopoverController: UIPopoverController? = nil
  
  
  var detailItem: (name: String, chapUrl: String)? {
    didSet {
      // Update the view.
      self.configureView()
      
      if self.masterPopoverController != nil {
        self.masterPopoverController!.dismissPopoverAnimated(true)
      }
    }
  }
  
  func configureView() {
    // Update the user interface for the detail item.
    if let detail: (name: String, chapUrl: String) = self.detailItem {
      let urlPath: String = detail.chapUrl
      var url: NSURL = NSURL(string: urlPath)
      var request: NSURLRequest = NSURLRequest(URL: url)
      
      var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
      
      var output = NSString(data: data, encoding: NSUTF8StringEncoding)
      
      var html = DTHTMLParser(data: data, encoding: NSUTF8StringEncoding)
      
      var parser = HTMLParser(string: output, error: nil)
      var body = parser.body()
    
      var img:HTMLNode[] = body.findChildTags("img") as HTMLNode[]
      
      var imgsrc = img[img.count-1].getAttributeNamed("src")
      println(imgsrc)

      url = NSURL(string: imgsrc)
      request = NSURLRequest(URL: url)
      data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
      
      var uiimage = UIImage(data: data)
      
      if let imageview = self.mangaPageImageView {
        imageview.image = uiimage
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.configureView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // #pragma mark - Split view
  
  func splitViewController(splitController: UISplitViewController, willHideViewController viewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController popoverController: UIPopoverController) {
    barButtonItem.title = "Master" // NSLocalizedString(@"Master", @"Master")
    self.navigationItem.setLeftBarButtonItem(barButtonItem, animated: true)
    self.masterPopoverController = popoverController
  }
  
  func splitViewController(splitController: UISplitViewController, willShowViewController viewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    self.navigationItem.setLeftBarButtonItem(nil, animated: true)
    self.masterPopoverController = nil
  }
  func splitViewController(splitController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
    return true
  }
  
}

