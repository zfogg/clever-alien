mongoose = require 'mongoose'
_        = require 'underscore'


Schema = mongoose.Schema


module.exports =

    Redditor: mongoose.model 'Redditor',
        new Schema
            name: String

            name: String
            has_replies: Boolean

            link_karma: Number
            comment_karma: Number
    ,
        'redditors'

    Thread: mongoose.model 'Thread',
        new Schema
            name: String

            title: String
            author: String
            created: Number
            url: String
            permalink: String

            score: Number
            ups: Number
            downs: Number

            selftext: String

            replied:
                type: Boolean
                default: false
            storedComments:
                type: Boolean
                default: false
    ,
        'threads'

    Comment: mongoose.model 'Comment',
        new Schema
            name: String

            author: String
            created: Number

            link_id: String
            parent_id: String

            subreddit: String

            ups: Number
            downs: Number

            body: String

            replied:
                type: Boolean
                default: false
    ,
        'comments'

    Unread: mongoose.model 'Unread',
        new Schema
            name: String

            author: String
            created: Date

            subreddit: String
            context: String
            new: Boolean

            body: String

            replied:
                type: Boolean
                default: false
    ,
        'unread'


    updateOrCreate: (Model, cb=->) -> (err, listing) ->
        data = listing.data
        name = data.name
        Model.findOneAndUpdate {name}, data, (err, doc) ->
            doc or= new Model data
            cb err, doc
            doc.save()

    saveAll: (docs, cb=->) ->
        i = docs.length
        _.each docs, (doc) ->
            doc.save (err) ->
                cb 'saveAll: success' if --i is 0

