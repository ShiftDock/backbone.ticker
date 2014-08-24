backbone.ticker
===============

A simple utility for Backbone.js projects that executes a function at a set interval.

Besides being stopped and started, tickers can be paused, restarted and __nudged__.

## Usage

Include `backbone.ticker.js` anywhere after you link `backbone.js`. Creating a simple ticker is as easy as initializing it and and starting it.

    ticker = new Backbone.Ticker()
    ticker.start()

Options:

__interval:__ Specified in milliseconds (ms), the time between each tick. Default is 1000ms (1 second).

__payload:__ A function to be run on each tick. Default is an empty function that simply schedules the next tick.

### Example: Save a Collection every five seconds

```js
  // Create a `todoList` collection
  var todoList = new Collections.TodoList()
    
  // Create a new ticker
  var todoListSaver = new Backbone.Ticker({
    payload: function(complete) {
      todoList.save()
      complete();
    },
    interval: 5000
  })

```

You could also mix the ticker into the Collection constructor directly.
    
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

You can have the payload do anything you want but it is important to remember that the ticker needs to know when
your process has completed in order to schedule the next tick. This ensures that long-running functions, such as requests to a server, do not accumulate if they exceed the interval length.

Backbone.Ticker includes a callback as the first argument to the payload function that you should use to indicate that your function has completed execution. It's important to do this at every point that your process may exit, unless you want the ticker to stall at certain points.

### Example: Conditionally save a model every four seconds

Notice the call to `complete()` at every possible point of return.

#### Javascript:

```js

var appointment = new Models.Appointment()

var saveIfChanged = function(complete) {
  if (appointment.hasChanged()) {
    appointment.save({
      success: function() {
        console.log("Saved successfully!");
        complete()
      },
      error: function() {
        console.log("Save failed!");
        complete()
      }
    });
  } else {
    console.log("Nothing to see here!");
    complete();
  }
}

var ticker = new Backbone.Ticker({
  interval: 4000,
  payload: saveIfChanged
});

ticker.start()

```

#### CoffeeScript:

```coffee

appointment = new Models.Appointment()

saveIfChanged = (complete) ->
  if appointment.hasChanged()
    appointment.save
      success: (complete) ->
        console.log "Saved successfully!"
        complete()
      error: (complete) ->
        console.log "Save failed!"
        complete()
  else
    console.log "Nothing to see here!"
    complete()

ticker = new Backbone.Ticker({
  interval: 4000,
  payload:  saveIfChanged
});

```





