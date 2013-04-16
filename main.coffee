# === Config ===

mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/test'

rereddit = require 'rereddit'

util     = require 'util'

hurrier = require('./hurrier')
bot     = require('./bot'    )


randomMinute = (min, max) ->
    1000 * 60 * (Math.random() * (max - min) + min)

log = (x) ->
    console.log util.inspect x,
        colors: true
        depth: 1


# === Login to Reddit ===

{USER, PASS} = process.env
rereddit.login(USER, PASS).end (err, user) ->

    # === Initialize Hurrier ===

    hurrier user, (h) ->

        do storeThreads = ->
            log 'Storing threads.'
            h.storeThreads 'all', 50
            setTimeout storeThreads, randomMinute 25, 45

        do storeComments = ->
            log 'Storing comments.'
            h.storeComments()
            setTimeout storeComments, randomMinute 5, 9


    # === Initialize Bot ===

    bot user, (b) ->

        do commentComment = ->
            log 'Commenting on a comment.'
            b.commentComment (err, res) ->
                log res
                setTimeout commentComment,
                    #(1000*res.json.ratelimit) or
                    (randomMinute 7, 11)

