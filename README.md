backbone.ticker
===============

A simple, small ticker for backbone that runs a payload at a given interval.

## Usage

Include `backbone.ticker.js` anywhere after you link backbone.js, then it's as simple as creating a new ticker with the
options you want:

    ticker = new Backbone.Ticker({ticker: function() { console.debug("Hello world!") }}

Possible options are simply `interval` and `payload`, and these can even be changed while the ticker is running and they'll take effect on the next trigger.

__interval:__ Specified in milliseconds (ms), the time between each tick. Default is 1000ms (1 second).
__payload:__ A function to be run on each tick. Default is an empty function.

For example:

    ticker.set("interval", 10000)    // sets the interval to 10,000ms (10 seconds)

    ticker.set("payload", function() { alert("Tick!")})

    ticker.set({payload: function() {console.log("Hello!")}, interval: 4000})



