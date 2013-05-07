backbone.ticker
===============

A simple, small ticker for backbone that runs a payload at a given interval.

At ShiftDock we needed a discrete ticker that was flexible enough to run our long-polling function whilst allowing
us to force an action outside of the timed poller without causing a stall or spinning off more than one process. Calling
setTimeout recursively can create a few tricky bugs so it made sense use Backbone's powerful MVC structure and dirty 
attributes to tame this behaviour.

We couldn't find something out there that did exactly what we wanted so we created backbone.ticker instead.

## Usage

Include `backbone.ticker.js` anywhere after you link `backbone.js`. Creating a simple ticker that calls an empty function
every second is as easy as initializing a new ticker and starting it:

    ticker = new Backbone.Ticker()
    ticker.start()

Possible options are simply `interval` and `payload`, and these can even be changed while the ticker is running and they'll take effect on the next trigger.

__interval:__ Specified in milliseconds (ms), the time between each tick. Default is 1000ms (1 second).

__payload:__ A function to be run on each tick. Default is an empty function.

For example:

    // sets the interval to 10,000ms (10 seconds)
    ticker.set("interval", 10000)

    // set a new anonymous function as the payload
    ticker.set("payload", function() { alert("Tick!")})

    // change the payload and interval at once
    ticker.set({payload: function() {console.log("Hello!")}, interval: 4000})
    
    // Initialize a new ticker with these options
    ticker = new Backbone.Ticker({payload: function() {console.log("Hello!")}, interval: 4000})
    
## Actions

__ticker.start():__ Start the ticker using the existing options. Takes an optional function argument that overrides any previously
specified payload.

__ticker.stop():__ Stop the ticker and wipe the payload. Effectively a reset.

__ticker.pause():__ Pauses the ticker, retaining options.

__ticker.resume():__ Resume the ticker using the existing configuration.

__ticker.nudge():__ Interrupts the ticker to execute the payload immediately then resumes.
    



