//
//  NewsFeedView.swift
//  InfiniteScrollFromAPI
//
//  Created by cristian on 15/09/2020.
//  Copyright © 2020 cristian. All rights reserved.
//

import SwiftUI

struct NewsFeedView: View {
    @ObservedObject var newsFeedViewModel = NewsFeedViewModel()
    
    var body: some View {
        List(newsFeedViewModel.newsListItems) { (article) in
            NewsListItemsView(article: article)
                .onAppear() {
                    self.newsFeedViewModel.loadMoreArticles(currentItem: article)
            }
        }
    }
}

struct NewsListItemsView: View {
    var article: NewsListItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(article.title)")
                .font(.headline)
            Text("(\(article.author)")
                .font(.subheadline)
        }
        .padding()
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView()
    }
}
