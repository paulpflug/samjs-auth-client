(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  module.exports = function(samjs) {
    var Auth;
    return samjs.auth = new (Auth = (function() {
      function Auth() {
        this.login = bind(this.login, this);
        this.logout = bind(this.logout, this);
        this.onceLoaded = samjs.io.onceLoaded.then(function(nsp) {
          return nsp("/auth");
        });
        this.authenticated = false;
        this.token = typeof localStorage !== "undefined" && localStorage !== null ? typeof localStorage.getItem === "function" ? localStorage.getItem("token") : void 0 : void 0;
        samjs.events(this);
        return this;
      }

      Auth.prototype.createRoot = function(userobj) {
        return samjs.install.set("users", [userobj]);
      };

      Auth.prototype.logout = function() {
        this.token = null;
        if (typeof localStorage !== "undefined" && localStorage !== null) {
          if (typeof localStorage.setItem === "function") {
            localStorage.setItem("token", null);
          }
        }
        this.authenticated = false;
        this.user = null;
        return this.emit("logout");
      };

      Auth.prototype.login = function(user) {
        return new samjs.Promise((function(_this) {
          return function(resolve, reject) {
            if (_this.authenticated) {
              resolve();
            }
            if (user) {
              return _this.onceLoaded.then(function(socket) {
                return socket.getter("auth", user).then(function(result) {
                  _this.authenticated = true;
                  _this.user = result;
                  _this.token = result.token;
                  _this.emit("login");
                  if (typeof localStorage !== "undefined" && localStorage !== null) {
                    if (typeof localStorage.setItem === "function") {
                      localStorage.setItem("token", _this.token);
                    }
                  }
                  delete result.token;
                  return resolve(result);
                })["catch"](reject);
              });
            } else if (_this.token != null) {
              return _this.onceLoaded.then(function(socket) {
                return socket.getter("auth.byToken", _this.token).then(function(result) {
                  _this.authenticated = true;
                  _this.user = result;
                  _this.emit("login");
                  return resolve(result);
                })["catch"](reject);
              });
            } else {
              return reject();
            }
          };
        })(this));
      };

      return Auth;

    })());
  };

}).call(this);
