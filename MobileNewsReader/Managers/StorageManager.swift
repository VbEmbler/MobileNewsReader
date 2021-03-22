//
//  StorageManager.swift
//  MobileNewsReader
//
//  Created by Vladimir on 18/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    
    //MARK: - Public Properties
    public static let shared = StorageManager()
    
    //MARK: - Private Properties
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    //MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "MobileNewsReader")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: - Initializers
    private init() {}
    
    //MARK: - Public Methods
    // MARK: - Core Data Saving support
    public func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    //MARK: - For Sources
    public func saveSource(source: Source) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: EntityName.sourcesStorage.rawValue, in: viewContext) else { return }
        guard let sourceStorage = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? SourcesStorage else { return }
        sourceStorage.id = source.id
        sourceStorage.name = source.name
        sourceStorage.sourceDescription = source.description
        sourceStorage.url = source.url
        sourceStorage.category = source.category
        sourceStorage.language = source.language
        sourceStorage.country = source.country
        
        saveContext()
    }
    
    public func editSourceFavouriteProperty(sourceId: String, isFavourite: Bool) throws {
        let fetchRequest: NSFetchRequest<SourcesStorage> = SourcesStorage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", sourceId)
        
        do {
            let fetchResult = try viewContext.fetch(fetchRequest) as [SourcesStorage]
            if let source = fetchResult.first {
                source.favourite = isFavourite
            }
        } catch let error {
            throw error
        }
        
        saveContext()
    }
    
    public func getSources() throws -> [SourcesStorage] {
        let fetchRequest: NSFetchRequest<SourcesStorage> = SourcesStorage.fetchRequest()
        let sortById = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortById]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            throw error
        }
    }
    
    public func getFavouriteSources() throws -> [SourcesStorage] {
        let fetchRequest: NSFetchRequest<SourcesStorage> = SourcesStorage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "favourite == %@", NSNumber(value: true))
        let sortById = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortById]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            throw error
        }
    }
    
    public func isSourceFavourite(sourceId: String) -> Bool? {
        var isFavourite = false
        let fetchReguest: NSFetchRequest<SourcesStorage> = SourcesStorage.fetchRequest()
        fetchReguest.predicate = NSPredicate(format: "id == %@", sourceId)
        do {
            let fetchedResult = try viewContext.fetch(fetchReguest) as [SourcesStorage]
            if let source = fetchedResult.first {
                isFavourite = source.favourite
            }
        } catch {
            return false
        }
        return isFavourite
    }
    
    public func isSourceExistInBase(sourceId: String)  -> Bool {
        var isExist = false
        let fetchRequest: NSFetchRequest<SourcesStorage> = SourcesStorage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", sourceId)
        do {
            let fetchResult = try viewContext.fetch(fetchRequest) as [SourcesStorage]
            if let _ = fetchResult.first {
                isExist = true
            }
        } catch {
            return false
        }
        return isExist
    }
    
    public func deleteAllSources() throws {
        var sources = [SourcesStorage]()
        do {
            sources = try getSources()
        } catch let error {
            throw error
        }
        for source in sources {
            viewContext.delete(source)
        }
        saveContext()
    }
    
    public func deleteNotFavouriteSources() throws {
        var sources = [SourcesStorage]()
        do {
            sources = try getSources()
        } catch let error {
            throw error
        }
        for source in sources {
            if  !source.favourite {
                viewContext.delete(source)
            }
        }
        saveContext()
    }
    
    //MARK: - For Articles
    public func saveArticle(article: Article) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: EntityName.articlesStorage.rawValue, in: viewContext) else { return }
        guard let articleStorage = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? ArticlesStorage else { return }
        articleStorage.sourceId = article.source?.id
        articleStorage.sourceName = article.source?.name
        articleStorage.author = article.author
        articleStorage.title = article.title
        articleStorage.articleDescription = article.description
        articleStorage.url = article.url
        articleStorage.urlToImage = article.urlToImage
        articleStorage.publishedAt = article.publishedAt
        articleStorage.content = article.content
        articleStorage.fromSearch = article.fromSearch ?? false
        articleStorage.imageData = article.imageData
        
        saveContext()
    }
    
    public func getArticlesFromSearch() throws -> [ArticlesStorage] {
        let fetchRequest: NSFetchRequest<ArticlesStorage> = ArticlesStorage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fromSearch == %@", NSNumber(value: true))
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            throw error
        }
    }
    
    public func getArticles() throws -> [ArticlesStorage] {
        let fetchRequest: NSFetchRequest<ArticlesStorage> = ArticlesStorage.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            throw error
        }
    }
    
    public func getArticles(sourceId: String) throws -> [ArticlesStorage] {
        let fetchRequest: NSFetchRequest<ArticlesStorage> = ArticlesStorage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sourceId == %@ AND fromSearch == %@", sourceId, NSNumber(value: false))
        do {
            let articles = try viewContext.fetch(fetchRequest)
            return articles
        } catch let error {
            throw error
        }
    }
    
    public func isArticleExistInBase(articleTitle: String) -> Bool {
        var isExist = false
        let fetchRequest: NSFetchRequest<ArticlesStorage> = ArticlesStorage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", articleTitle)
        do {
            let fetchResult = try viewContext.fetch(fetchRequest) as [ArticlesStorage]
            if let _ = fetchResult.first {
                isExist = true
            }
        } catch  {
            return false
        }
        return isExist
    }
    
    public func deleteAllArticles() throws {
        var articles = [ArticlesStorage]()
        do {
            articles = try getArticles()
        } catch let error {
            throw error
        }
        for article in articles {
            viewContext.delete(article)
        }
        saveContext()
    }
    
    public func deleteAllArticles(sourceId: String) throws {
        var articles = [ArticlesStorage]()
        do {
            articles = try getArticles(sourceId: sourceId)
        } catch let error {
            throw error
        }
        for article in articles {
            viewContext.delete(article)
        }
        saveContext()
    }

    public func deleteAllArticlesWithotFromSearchWith(sourceId: String) throws {
        var articles = [ArticlesStorage]()
        do {
            articles = try getArticles()
        } catch let error {
            throw error
        }
        for article in articles {
            if !article.fromSearch && article.sourceId == sourceId {
                viewContext.delete(article)
            }
        }
        saveContext()
    }
    
    public func deleteAllArticlesFromSearch() throws {
        var articles = [ArticlesStorage]()
        do {
            articles = try getArticles()
        } catch let error {
            throw error
        }
        for article in articles {
            if article.fromSearch {
                viewContext.delete(article)
            }
        }
        saveContext()
    }
    
    //Mark: - Enums
    enum EntityName: String {
        case articlesStorage = "ArticlesStorage"
        case sourcesStorage = "SourcesStorage"
    }
}


