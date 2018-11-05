import Foundation
import CoreData

extension MovieManaged {
    static func managedMovie(with movieAbstract: MovieAbstract, context: NSManagedObjectContext) -> MovieManaged {
        let managedMovie = MovieManaged(context: context)
        managedMovie.hasVideo = movieAbstract.hasVideo
        managedMovie.id = Int64(movieAbstract.id)
        managedMovie.overview = movieAbstract.overview
        managedMovie.releaseDate = movieAbstract.releaseDate
        movieAbstract.genreIds.forEach { id in
            managedMovie.addToGenres(MovieGenreManaged.managedGenreWithId(id, context:context))
        }
        managedMovie.originalTitle = movieAbstract.originalTitle
        managedMovie.originalLanguage = movieAbstract.originalLanguage
        managedMovie.title = movieAbstract.title
        managedMovie.popularity = movieAbstract.popularity
        managedMovie.vote = MovieVoteManaged.managedVote(with:movieAbstract.vote, context: context)
        managedMovie.imagePaths = MovieImagePathsManaged.managedImagePaths(with:movieAbstract.imagePaths, context: context)
        return managedMovie
    }
    
    var movieModel: MovieAbstract {
        let genreIds = Array(self.genres as! Set<MovieGenreManaged>).map { Int($0.id) }
        return MovieAbstract(overview: self.overview!,
                             releaseDate: self.releaseDate! as Date,
                             genreIds: genreIds,
                             id: Int(self.id),
                             originalTitle: self.originalTitle!,
                             originalLanguage: self.originalLanguage!,
                             title: self.title!,
                             popularity: self.popularity,
                             hasVideo: self.hasVideo,
                             vote: self.vote!.voteModel,
                             imagePaths: self.imagePaths!.imagePathsModel)
    }
}

extension MovieGenreManaged {
    static func managedGenreWithId(_ genreId: Int, context: NSManagedObjectContext) -> MovieGenreManaged {
        let genre = MovieGenreManaged(context: context)
        genre.id = Int64(genreId)
        return genre
    }
}

extension MovieVoteManaged {
    static func managedVote(with movieVote: MovieAbstract.Vote, context: NSManagedObjectContext) -> MovieVoteManaged {
        let managedVote = MovieVoteManaged(context: context)
        managedVote.count = Int64(movieVote.count)
        managedVote.average = movieVote.average
        return managedVote
    }
    
    var voteModel: MovieAbstract.Vote {
        return MovieAbstract.Vote(count: Int(self.count), average: self.average)
    }
}

extension MovieImagePathsManaged {
    static func managedImagePaths(with imagePaths: MovieAbstract.ImagePaths, context: NSManagedObjectContext) -> MovieImagePathsManaged {
        let managedImagePaths = MovieImagePathsManaged(context: context)
        managedImagePaths.poster = imagePaths.poster
        managedImagePaths.backdrop = imagePaths.backdrop
        return managedImagePaths
    }
    
    var imagePathsModel: MovieAbstract.ImagePaths {
        return MovieAbstract.ImagePaths(poster: self.poster, backdrop: self.backdrop)
    }
}

extension MovieCategoryManaged: ExpirableManagedObject {}
