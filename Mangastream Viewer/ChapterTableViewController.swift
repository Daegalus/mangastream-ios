//
//  MasterViewController.swift
//  Mangastream Viewer
//
//  Created by Yulian Kuncheff on 6/24/14.
//  Copyright (c) 2014 Yulian Kuncheff. All rights reserved.
//

import UIKit

class ChapterTableViewController: UITableViewController {
  
  var detailViewController: DetailViewController? = nil
  var objects = NSMutableArray()
  var data: NSData = NSData()
  var mangaName = ""
  var url = ""
  var chapters: (name: String, url: String)[] = []
  
  init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  init(coder aDecoder: NSCoder!) {
    super.init(coder: aDecoder)
  }
  
  init(style: UITableViewStyle) {
    super.init(style: style)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      self.clearsSelectionOnViewWillAppear = false
      self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = controllers[controllers.endIndex-1].topViewController as? DetailViewController
    }
    
    let urlPath: String = self.url
    var url: NSURL = NSURL(string: urlPath)
    var request: NSURLRequest = NSURLRequest(URL: url)
    
    data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    
    var output = NSString(data: data, encoding: NSUTF8StringEncoding)
    
    var html = DTHTMLParser(data: data, encoding: NSUTF8StringEncoding)
    
    var parser = HTMLParser(string: output, error: nil)
    var body = parser.body()
    var mangatrs = body.findChildTags("tr") as HTMLNode[]
    mangatrs.removeAtIndex(0)
    chapters = mangatrs.map({ (tr:HTMLNode) -> (String, String) in
      println(tr.rawContents())
      var href = tr.findChildTag("td").findChildTag("a")
      var link = href.getAttributeNamed("href")
      var name = href.contents()
      self.insertNewObject(name)
      return (name, link)
      })
    
    println("Links \(chapters)")
  }
  
  func insertNewObject(manga: String) {
    if objects == nil {
      objects = NSMutableArray()
    }
    objects.addObject(manga)
    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
  }
  
  // #pragma mark - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      let indexPath = self.tableView.indexPathForSelectedRow()
      let object = (chapters[indexPath.row].name, chapters[indexPath.row].url)
      ((segue.destinationViewController as UINavigationController).topViewController as DetailViewController).detailItem = object
    }
  }
  
  // #pragma mark - Table View
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return objects.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ChapterCell", forIndexPath: indexPath) as UITableViewCell
    
    let object = objects[indexPath.row] as String
    cell.textLabel.text = object
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      let object = objects[indexPath.row] as String
      self.detailViewController!.detailItem = (chapters[indexPath.row].name, chapters[indexPath.row].url)
    }
  }
  
  
}

