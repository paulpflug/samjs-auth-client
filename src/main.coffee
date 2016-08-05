# out: ../lib/main.js
module.exports = (samjs) ->
  samjs.auth = new class Auth
    constructor: ->
      @onceLoaded = samjs.io.onceLoaded
        .then (nsp) -> return nsp("/auth")
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
      @emit "logout"
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
              @emit "login"
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
              @emit "login"
              resolve(result)
            .catch reject
        else
          reject()
