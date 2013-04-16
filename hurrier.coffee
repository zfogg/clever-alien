rr = require 'rereddit'
_  = require 'underscore'

{
    Thread
    Redditor
    Unread
    Comment
    updateOrCreate
} = require './models'


module.exports = (user, cb) ->

    cb
        # Store info about yourself.
        storeUser: (cb=->) ->
            rr.me().as(user).end(updateOrCreate Redditor, cb)

        # Store the threads of the given subreddit.
        storeThreads: (subreddit, n=25, cb=->) ->
            rr.read(subreddit).limit(n).end (err, listing) ->
                for thread in listing.data.children
                    updateOrCreate(Thread, cb) err, thread

        # Store the comments of the stored threads.
        storeComments: (n=5, cb=->) ->
            validThread =
                replied: false
                storedComments: false
            Thread.find(validThread).limit(n).exec (err, docs) ->
                for doc in docs
                    doc.storedComments = true
                    doc.save()

                    # Recursively get comments and moreChildren.
                    do _getComments = (getComments=rr.comments(doc.name.split('_')[1])) ->
                        getComments.end (err, listing) ->
                            return unless listing?[1]?
                            return if listing.error is 404

                            # Recursively store comments into a flat collection.
                            do _storeComments = (comments=listing[1].data) ->
                                for c in comments.children[..-2]
                                    unless c.kind is 'more'

                                        # Grab replies before mongoose schlurps 'em.
                                        replies = _.clone(c.data.replies.data)
                                        updateOrCreate(Comment, cb) err, c

                                        if replies?
                                            _storeComments replies

                                    else # c.kind is more here
                                        {parent, children} = c.data
                                        _getComments rr
                                            .moreChildren(parent, children)
                                            .as(user)

        # Store all unread comment replies.
        storeUnread: (cb=->) ->
            rr.unread().as(user).end (err, listing) ->
                for unread in listing.data.children
                    updateOrCreate(Unread, cb) err, unread

