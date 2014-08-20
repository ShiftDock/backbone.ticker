backbone.ticker
===============

A simple, small ticker for backbone that runs a payload at a given interval.

Calling setTimeout recursively can create a few tricky problems; including silent stalls and accumulation of multiple 
processes that can quickly get out of control. Backbone.Ticker uses Backbone's powerful MVC structure and dirty 
attributes to tame this behaviour by recording setTimeout process numbers and killing unused processes.

At ShiftDock we needed a ticker that was flexible enough to run both quick native processes and asynchronous updates
to our server without falling over.We couldn't find something out there that did exactly what we wanted so we created 
Backbone.Ticker instead.

## Usage

Include `backbone.ticker.js` anywhere after you link `backbone.js`. Creating a simple ticker that calls an empty function
every second is as easy as initializing a new ticker and starting it:

    ticker = new Backbone.Ticker()
    ticker.start()

Possible options are simply `interval` and `payload`, and these can even be changed while the ticker is running and they'll take effect on the next trigger.

__interval:__ Specified in milliseconds (ms), the time between each tick. Default is 1000ms (1 second).

__payload:__ A function to be run on each tick. Default is an empty function that simply schedules the next tick.

For example:

```js

    // sets the interval to 10,000ms (10 seconds)
    ticker.set("interval", 10000)

    // set a new anonymous function as the payload
    ticker.set("payload", function(complete) { alert("Tick!"); complete()})

    // change the payload and interval at once
    ticker.set({
        payload: function(complete) {
            console.log("Hello!"); 
            complete();
        }, 
        interval: 4000
    })
    
    // Initialize a new ticker with these options
    ticker = new Backbone.Ticker({
        payload: function(complete) {
            console.log("Hello!"); 
            complete();
        }, 
        interval: 4000
    })

```
    
## Actions

Start the ticker using the existing options. Takes an optional function argument that overrides any previously
specified payload:

    ticker.start()

Stop the ticker and wipe the payload. Effectively a reset:

    ticker.stop()

Pause the ticker, retaining options:

    ticker.pause()

Resume the ticker using the existing configuration:

    ticker.resume()

Interrupt the ticker to execute the payload immediately then resume:

    ticker.nudge()
    
Check if the ticker is running. Useful to check if it has stalled:

    ticker.isRunning()
    
## Customising the Payload

You can have the payload do anything you want but it is really important to remember that the ticker needs to know when
your process has completed in order to schedule the next tick. If you're not using the ticker for long-polling this may 
seem like overkill but it makes sense.

Say you want to run a process 5 seconds apart. Your process may take 500ms to complete, so it makes sense to wait until
it's done to schedule it again, otherwise the next will happen 4.5s after the last rather than 5s.

This becomes a problem when performing asynchronous POST or PUT requests to your server. If the request takes longer than
your interval then there's a risk it would be run multiple times.

Instead, Backbone.Ticker sends a callback as the first argument of your payload that you should use to indicate that your
process has completed execution. It's important to do this at every point that your process may exit, unless you want 
the ticker to stall at certain points.

#### Payload Example - JS

```js

var ticker = new Backbone.Ticker({interval: 4000});

var saveIfChanged = function(complete) {
  if (appointment.hasChanged()) {
    appointment.save({
      success: function() {
        console.log("Saved successfully!");
        complete()
      },
      error: function() {
        // No complete(); Stops ticking if save fails
        console.log("Save failed!");
      }
    });
  } else {
    console.log("Nothing to see here!");
    complete();
  }
}

ticker.set('payload', saveIfChanged)

```

#### Payload Example - CoffeeScript

```coffee

ticker = new Backbone.Ticker({interval: 4000});

saveIfChanged = (complete) ->
  if appointment.hasChanged()
    appointment.save
      success: (complete) ->
        console.log "Saved successfully!"
        complete()
      error: (complete) ->
        # No complete(); Stops ticking if save fails
        console.log "Save failed!"
  else
    console.log "Nothing to see here!"
    complete()

ticker.set('payload', saveIfChanged)

```





