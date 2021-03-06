# out: ../lib/main.js
module.exports = (samjs) ->
  samjs.auth = new class Auth
    constructor: ->
      @onceLoaded = samjs.io.nsp("/auth").onceLoaded
      @authenticated = false
      @token = localStorage?.getItem?("token")
      samjs.events(@)
      return @
    createRoot: (password) ->
      samjs.install.isInConfigMode().then (nsp) ->
        samjs.io.nsp(nsp).getter "auth.getInstallationInfo"
        .then (info) ->
          userobj = {}
          userobj[info.username] = info.rootUser
          userobj[info.password] = password
          samjs.install.set("users",[userobj])
    logout: =>
      @token = null
      localStorage?.setItem?("token",null)
      @authenticated = false
      @user = null
      @emit "authStatusChanged"
    login: (user) =>
      return new samjs.Promise (resolve, reject) =>
        resolve() if @authenticated
        if user
          @onceLoaded.then (socket) =>
            socket.getter "auth", user
            .then (result) =>
              @authenticated = true
              @user = result
              @token = result.token
              @emit "authStatusChanged", result
              localStorage?.setItem?("token",@token)
              delete result.token
              resolve(result)
            .catch reject
        else if @token?
          @onceLoaded.then (socket) =>
            socket.getter "auth.byToken", @token
            .then (result) =>
              @authenticated = true
              @user = result
              @emit "authStatusChanged", result
              resolve(result)
            .catch reject
        else
          reject(new Error "no auto login possible")
