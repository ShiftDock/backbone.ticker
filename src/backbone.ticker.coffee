# Backbone.Ticker.js
#
# A simple, drop-in Backbone.js ticker that runs a given payload at a specified interval. Useful for
# implementing a solid long-poller; it comes with start, stop, pause and resume built in, as well
# as a handy `nudge` function, to run the payload immediately before resuming again. 
# 
# Used at ShiftDock. © 2013 John M Hope, released under MIT License. 

class Backbone.Ticker extends Backbone.Model
  defaults: ->
    blocked: false
    interval: 1000
    id: null
    queue: []
    payload: (complete) => @defaultPayload(complete)
    
  initialize: ->
    @on 'change:id', @clearOldProcess, this
    this
    
  validate: (attrs, options) -> return "Payload must be a function" if typeof attrs.payload isnt 'function'
  
  # Start the ticker with the existing payload, or overriding with the specified payload
  start: (payload) -> 
    @set 'payload', payload, {validate: true} unless not payload
    @tick()
  
  # Stop the current ticker and wipe the payload, effectively a reset
  stop: -> @set 'payload', (->) if @pause()
  
  # Pause the current ticker without wiping the payload
  pause: -> if @isRunning() then !!@set('id', null) else false
  
  # Resume the current ticker using the existing payload
  resume: -> @tick()
  
  # Jumps the remaining interval to execute the payload immediately, then resumes if the ticker was running
  nudge: (payload) -> 
    payload ?= @executePayload
    if @isBlocked()
      @enqueue(payload)
    else if @isRunning()
      @executeWithCompletionCallback(payload) if @pause()
    else
      payload()
  
  # Silently sets the next tick process id to the id variable
  tick: (options = {}) -> @set 'id', @scheduleTick(), options
  
  # Schedules the next tick, returning the process id
  scheduleTick: -> setTimeout (=> @executePayload()), @get('interval')
  
  # Combines the payload with a call to schedule the next tick
  executePayload: -> 
    @set('id', null) # wipes the id momentarily. Permanently if the ticker stalls.
    @block() # block any stacked calls until this has completed, e.g. through a nudge
    @executeWithCompletionCallback(@get('payload'))
    
  # Executes any function, passing a callback to cue up the next call
  executeWithCompletionCallback: (_function) -> 
    _function => @unblock() and @workOrTick()

  # Work through the next in the queue or schedule a tick
  workOrTick: -> @workNext() or @tick({silent: true})

  # Work next payload in the queue
  workNext: -> @work(@nextQueued()) unless not @queued()

  # Work a payload
  work: (payload) -> @block() and @unqueue(payload) and @executeWithCompletionCallback(payload)
  
  defaultPayload: (complete) -> complete()
    
  # Make sure only one process is scheduled at a time by clearing old processes
  # when the id changes. 
  clearOldProcess: -> !clearTimeout(@previous('id')) unless not @previous('id')
  
  isRunning: -> !!@get('id')
  
  isBlocked: -> @get('blocked')
  
  # Block when a process is running
  block: -> @set("blocked", true)
  
  # Unblock when process has completed
  unblock: -> @set("blocked", false)
  
  # Queue payloads while the ticker is blocked
  enqueue: (payload) -> @set('queue', @get('queue').concat([payload])) 
  
  unqueue: (payload) -> @set('queue', _.without(@get('queue'), payload))
  
  queued: -> @get('queue').length isnt 0
  
  nextQueued: -> _.first(@get('queue'))
  
