import Foundation
import CoreData

enum MovieCategory: String {
    case Upcoming
    case TopRated
    case Popular
}

struct MoviesPersistanceFetcher {
    private let lifeSpan: Days = 1
    private let context: NSManagedObjectContext
    
    private func fetchNonExpiredManagedCategory(of category: MovieCategory) throws -> MovieCategoryManaged? {
        guard let managedCategory = try fetchManagedCategory(of: category), !managedCategory.isExpired() else { return nil }
        return managedCategory
    }
    
    private func fetchManagedCategory(of category: MovieCategory) throws -> MovieCategoryManaged? {
        let categoryRequest: NSFetchRequest<MovieCategoryManaged> = MovieCategoryManaged.fetchRequest()
        let categoryPredicate = NSPredicate(format: "name == %@", category.rawValue)
        categoryRequest.predicate = categoryPredicate
        let managedCategories = try context.fetch(categoryRequest)
        if managedCategories.isEmpty { return nil }
        return managedCategories[0]
    }
    
    private func fetchManagedMovies(with managedCategory: MovieCategoryManaged, page: Int) throws -> [MovieManaged] {
        let request: NSFetchRequest<MovieManaged> = MovieManaged.fetchRequest()
        let predicate = NSPredicate(format: "ANY categories.name LIKE %@", managedCategory.name!)
        request.predicate = predicate
        request.fetchOffset = (page - 1) * Int(managedCategory.batchSize)
        request.fetchLimit = Int(managedCategory.batchSize)
        return try context.fetch(request)
    }
    
    private func createManagedCategory(with paginatedMovieResults: PaginatedResult<[MovieAbstract]>,
                                       category: MovieCategory,
                                       context:NSManagedObjectContext,
                                       lifeSpan: Int) -> MovieCategoryManaged {
        guard let expirationDate = Calendar.current.date(byAdding: .day, value: lifeSpan, to: Date()) else { fatalError("Was not able to generate expiration date from life span") }
        
        let managedCategory = MovieCategoryManaged(context: context)
        managedCategory.expirationDate = expirationDate
        managedCategory.batchSize = Int64(paginatedMovieResults.results.count)
        managedCategory.totalPages = Int64(paginatedMovieResults.paginationInfo.totalPages)
        managedCategory.name = category.rawValue
        return managedCategory
    }
    
    func fetchMoviePageResult(_ page: Int, of category: MovieCategory) -> PaginatedResult<[MovieAbstract]>? {
        do {
            guard let managedCategory = try fetchNonExpiredManagedCategory(of: category) else {
                return nil
            }
            let managedMovies = try fetchManagedMovies(with: managedCategory, page: page)
            let movieModels = managedMovies.map { $0.movieModel }
            let paginationInfo = PaginationInfo(totalPages: Int(managedCategory.totalPages))
            return PaginatedResult(results: movieModels, paginationInfo: paginationInfo)
        } catch {
            fatalError("Fetch error")
        }
    }
    
    func add(_ paginatedMovieResults: PaginatedResult<[MovieAbstract]>, to category: MovieCategory) {
        guard !paginatedMovieResults.results.isEmpty else { return }
        do {
            let fetchedCategory = try fetchManagedCategory(of: category)
            let managedCategory: MovieCategoryManaged
            if let fetchedCategory = fetchedCategory, !fetchedCategory.isExpired() {
                managedCategory = fetchedCategory
            } else {
                if let fetchedCategory = fetchedCategory, fetchedCategory.isExpired() {
                    context.delete(fetchedCategory)
                    try context.save()
                }
                managedCategory = createManagedCategory(with: paginatedMovieResults, category: category, context: context, lifeSpan: lifeSpan)
            }
            paginatedMovieResults.results.forEach { movie in
                let managedMovie = MovieManaged.managedMovie(with: movie, context: context)
                managedMovie.addToCategories(managedCategory)
            }
            try context.save()
        } catch {
            fatalError("Save error")
        }
    }
    
    func replaceSavedMovies(with: [MovieAbstract], of category: MovieCategory) {
        
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
