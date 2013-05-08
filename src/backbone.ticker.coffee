# Backbone.Ticker.js
#
# A simple, drop-in Backbone.js ticker that runs a given payload at a specified interval. Useful for
# implementing a solid long-poller; it comes with start, stop, pause and resume built in, as well
# as a handy `nudge` function, to run the payload immediately before resuming again. 
# 
# Used at ShiftDock. © 2013 John M Hope, released under MIT License. 

class Backbone.Ticker extends Backbone.Model
	defaults: ->
		interval: 1000
		id: null
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
	
	# Jumps the remaining interval to execute the payload immediately, then resumes
	nudge: -> @payloadWithNextTick() if @isRunning() and @pause()
	
	# Silently sets the next tick process id to the id variable
	tick: (options = {}) -> @set 'id', @scheduleTick(), options
	
	# Schedules the next tick, returning the process id
	scheduleTick: -> setTimeout (=> @payloadWithNextTick()), @get('interval')
	
	# Combines the payload with a call to schedule the next tick
	payloadWithNextTick: -> 
		console.log "Calling payload and adding tick"
		@get('payload')(=> @tick({silent: true}))
	
	defaultPayload: (complete) -> complete()
		
	# Make sure only one process is scheduled at a time by clearing old processes
	# when the id changes. 
	clearOldProcess: -> !clearTimeout(@previous('id'))
	
	isRunning: -> !!@get('id')
	
