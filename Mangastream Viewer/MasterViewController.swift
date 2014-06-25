//
//  MasterViewController.swift
//  Mangastream Viewer
//
//  Created by Yulian Kuncheff on 6/24/14.
//  Copyright (c) 2014 Yulian Kuncheff. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
  
  var detailViewController: DetailViewController? = nil
  var objects = NSMutableArray()
  var data: NSData = NSData()
  var manga: (name: String, url: String)[] = []
  
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
    
    let urlPath: String = "http://mangastream.com/manga"
    var url: NSURL = NSURL(string: urlPath)
    var request: NSURLRequest = NSURLRequest(URL: url)

    data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    
    var output = NSString(data: data, encoding: NSUTF8StringEncoding)
    println("Output \(output)")
    
    var html = DTHTMLParser(data: data, encoding: NSUTF8StringEncoding)

    var parser = HTMLParser(string: output, error: nil)
    var body = parser.body()
    var mangatrs = body.findChildTags("tr") as HTMLNode[]
    mangatrs.removeAtIndex(0)
    manga = mangatrs.map({ (tr:HTMLNode) -> (String, String) in
      println(tr.rawContents())
      var href = tr.findChildTag("strong").findChildTag("a")
      var link = href.getAttributeNamed("href")
      var name = href.contents()
      self.insertNewObject(name)
      return (name, link)
    })
    
    println("Links \(manga)")
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
    if segue.identifier == "showChapters" {
      let indexPath = self.tableView.indexPathForSelectedRow()
      let object = manga[indexPath.row]
      ((segue.destinationViewController as UINavigationController).topViewController as ChapterTableViewController).mangaName = object.name
      ((segue.destinationViewController as UINavigationController).topViewController as ChapterTableViewController).url = object.url
    }
  }
  
  // #pragma mark - Table View
    
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return objects.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    
    let object = objects[indexPath.row] as String
    cell.textLabel.text = object
    return cell
  }
}

