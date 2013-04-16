mongoose  = require 'mongoose'
_         = require 'underscore'
rereddit  = require 'rereddit'
Cleverbot = require 'cleverbot-node'

{
    Thread
    Redditor
    Unread
    Comment

    updateOrCreate
    saveAll
} = require './models'


module.exports = (user, cb) ->

    cleverbot = new Cleverbot

    cb
        commentThread: (cb=->) ->
            Thread.findOne replied: false, (err, doc) ->
                if doc?
                    cleverbot.write doc.title, (cbotRes) ->
                        rereddit.comment(doc.name, cbotRes.message)
                        .as(user)
                        .end (err, res) ->
                            doc.replied = true
                            doc.save()
                            cb err, res

        commentComment: (cb=->) ->
            Comment.findOne replied: false, (err, doc) ->
                if doc?
                    cleverbot.write doc.body, (cbotRes) ->
                        rereddit.comment(doc.name, cbotRes.message)
                        .as(user)
                        .end (err, res) ->
                            Comment.find link_id: doc.link_id, (err, docs) ->
                                _.each docs, (d) -> d.replied = true
                                saveAll docs, -> cb err, res

