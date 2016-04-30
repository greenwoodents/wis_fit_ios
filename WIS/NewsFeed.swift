//
//  NewsFeed.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 03.03.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class NewsFeed {
    var dataFetchController: DataFetcher
    var feed = [SelectCell]()
    init() {
        dataFetchController = DataFetcher()
        dataFetchController.performFetch {
            for object in self.dataFetchController.fetchedObjects {
                self.feed.append(SelectCell.init(course: object.course!, title: object.title!, detail: object.description, what: object.what!, when: object.when!))
            }
            
            
            
            
        }
    }
}