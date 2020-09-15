//
//  NewsFeedItem.swift
//  InfiniteScrollFromAPI
//
//  Created by cristian on 15/09/2020.
//  Copyright © 2020 cristian. All rights reserved.
//

import Foundation



class NewsListItem: Identifiable {
    var uuid = UUID()
    var author: String
    var title: String
    
    init(title: String, author: String) {
        self.title = title
        self.author = author
    }
}

