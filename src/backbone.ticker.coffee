# Backbone.Ticker.js
#
# A simple, drop-in Backbone.js ticker that runs a given payload at a specified interval. Useful for
# implementing a solid long-poller; it comes with start, stop, pause and resume built in, as well
# as a handy `nudge` function, to run the payload immediately before resuming again. 
# 
# Used at ShiftDock. © 2014 John M Hope, released under MIT License. 

class Backbone.Ticker extends Backbone.Model
  defaults: ->
    blocked: false
    interval: 1000
    id: null
    queue: []
    payload: (complete) => @defaultPayload(complete)
    

  # Register an event to clear any existing process when the id is changed,
  # i.e. when a new setTimeout process is registered.
  #
  initialize: ->
    @on 'change:id', @clearOldProcess, this
    this
  

  validate: (attrs, options) -> 
    return "Payload must be a function" if typeof attrs.payload isnt 'function'
  

  # Start the ticker with the existing payload, or override with the specified payload
  #
  start: (payload) -> 
    @set 'payload', payload, {validate: true} unless not payload
    @tick()
  

  # Stop the current ticker and wipe the payload, effectively a reset
  #
  stop: -> @set 'payload', (->) if @pause()
  

  # Pause the current ticker without wiping the payload
  #
  pause: -> if @isRunning() then !!@set('id', null) else false
  

  # Resume the current ticker using the existing payload
  #
  resume: -> @tick()
  

  # Jumps the remaining interval to execute the payload immediately, then 
  # resumes if the ticker was running.
  #
  nudge: (payload) -> 
    payload ?= @executePayload
    if @isBlocked()
      @enqueue(payload)
    else if @isRunning()
      @executeWithCompletionCallback(payload) if @pause()
    else
      payload()
  

  # Schedule a tick and set the process id to the id variable.
  #
  tick: (options = {}) -> @set 'id', @scheduleTick(), options
  

  # Schedules the next tick at the interval, returning the process id
  #
  scheduleTick: -> setTimeout (=> @executePayload()), @get('interval')
  

  # Combines the payload with a call to schedule the next tick
  #
  executePayload: -> 
    @set('id', null) # wipes the id momentarily. Permanently if the ticker stalls.
    @block() # block any stacked calls until this has completed, e.g. through a nudge
    @executeWithCompletionCallback(@get('payload'))
    

  # Executes any function, passing a callback to cue up the next call
  #
  executeWithCompletionCallback: (_function) -> 
    _function => @unblock() and @workOrTick()


  # Work through the next in the queue or schedule a tick
  #
  workOrTick: -> @workNext() or @tick({silent: true})


  # Execute the next payload in the queue.
  #
  workNext: -> 
    nextPayload = nextQueuedPayload()

    @work(nextPayload) unless @queueEmpty()


  # Work a given payload
  #
  work: (payload) -> 
    @block() and @unqueue(payload) and @executeWithCompletionCallback(payload)
  

  # A default noop payload that simply passes the complete callback
  # through to queue the next tick.
  #
  defaultPayload: (complete) -> complete()
    

  # Make sure only one setTimeout process is scheduled at a time by clearing old 
  # processes when the id changes. 
  #
  clearOldProcess: -> !clearTimeout(@previous('id')) unless not @previous('id')
  

  # The ticker is running if it has an ID, which is assigned by setTimeout.
  #
  isRunning: -> !!@get('id')
  

  # Is the ticker prevented from executing payloads?
  #
  isBlocked: -> @get('blocked')
  

  # Set blocked status to true, preventing payloads from being executed.
  #
  block: -> @set("blocked", true)
  

  # Unblock and allow payloads to be executed again.
  #
  unblock: -> @set("blocked", false)
  

  # Methods to manage the queue of payloads. Payloads are placed into the queue
  # instead of being called over the top of each other - e.g. when nudging 
  # during a scheduled tick.

  # Place a payload in the queue.
  #
  enqueue: (payload) -> @set('queue', @get('queue').concat([payload])) 
  

  # Remove a payload from the queue.
  #
  unqueue: (payload) -> @set('queue', _.without(@get('queue'), payload))


  # Are there any payloads in the queue?
  #
  queueEmpty: -> @get('queue').length is 0
  

  # Return the next payload to be executed.
  #
  nextQueuedPayload: -> _.first(@get('queue'))
