// Generated by CoffeeScript 1.4.0
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Backbone.Ticker = (function(_super) {

    __extends(Ticker, _super);

    function Ticker() {
      return Ticker.__super__.constructor.apply(this, arguments);
    }

    Ticker.prototype.defaults = function() {
      var _this = this;
      return {
        blocked: false,
        interval: 1000,
        id: null,
        queue: [],
        payload: function(complete) {
          return _this.defaultPayload(complete);
        }
      };
    };

    Ticker.prototype.initialize = function() {
      this.on('change:id', this.clearOldProcess, this);
      return this;
    };

    Ticker.prototype.validate = function(attrs, options) {
      if (typeof attrs.payload !== 'function') {
        return "Payload must be a function";
      }
    };

    Ticker.prototype.start = function(payload) {
      if (!!payload) {
        this.set('payload', payload, {
          validate: true
        });
      }
      return this.tick();
    };

    Ticker.prototype.stop = function() {
      if (this.pause()) {
        return this.set('payload', (function() {}));
      }
    };

    Ticker.prototype.pause = function() {
      if (this.isRunning()) {
        return !!this.set('id', null);
      } else {
        return false;
      }
    };

    Ticker.prototype.resume = function() {
      return this.tick();
    };

    Ticker.prototype.nudge = function(payload) {
      if (payload == null) {
        payload = this.executePayload;
      }
      if (this.isBlocked()) {
        return this.enqueue(payload);
      } else if (this.isRunning()) {
        if (this.pause()) {
          return this.executeWithCompletionCallback(payload);
        }
      } else {
        return payload();
      }
    };

    Ticker.prototype.tick = function(options) {
      if (options == null) {
        options = {};
      }
      return this.set('id', this.scheduleTick(), options);
    };

    Ticker.prototype.scheduleTick = function() {
      var _this = this;
      return setTimeout((function() {
        return _this.executePayload();
      }), this.get('interval'));
    };

    Ticker.prototype.executePayload = function() {
      this.set('id', null);
      this.block();
      return this.executeWithCompletionCallback(this.get('payload'));
    };

    Ticker.prototype.executeWithCompletionCallback = function(_function) {
      var _this = this;
      return _function(function() {
        return _this.unblock() && _this.workOrTick();
      });
    };

    Ticker.prototype.workOrTick = function() {
      return this.workNext() || this.tick({
        silent: true
      });
    };

    Ticker.prototype.workNext = function() {
      console.log("Will work next? " + (this.queued()));
      if (!!this.queued()) {
        return this.work(this.nextQueued());
      }
    };

    Ticker.prototype.work = function(payload) {
      return this.block() && this.unqueue(payload) && this.executeWithCompletionCallback(payload);
    };

    Ticker.prototype.defaultPayload = function(complete) {
      return complete();
    };

    Ticker.prototype.clearOldProcess = function() {
      if (!!this.previous('id')) {
        return !clearTimeout(this.previous('id'));
      }
    };

    Ticker.prototype.isRunning = function() {
      return !!this.get('id');
    };

    Ticker.prototype.isBlocked = function() {
      return this.get('blocked');
    };

    Ticker.prototype.block = function() {
      return this.set("blocked", true);
    };

    Ticker.prototype.unblock = function() {
      return this.set("blocked", false);
    };

    Ticker.prototype.enqueue = function(payload) {
      return this.set('queue', this.get('queue').concat([payload]));
    };

    Ticker.prototype.unqueue = function(payload) {
      return this.set('queue', _.without(this.get('queue'), payload));
    };

    Ticker.prototype.queued = function() {
      return this.get('queue').length !== 0;
    };

    Ticker.prototype.nextQueued = function() {
      return _.first(this.get('queue'));
    };

    return Ticker;

  })(Backbone.Model);

}).call(this);
