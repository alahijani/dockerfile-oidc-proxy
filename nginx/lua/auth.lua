local _module = {}

local opts = {
    redirect_uri_path = os.getenv("OID_REDIRECT_PATH") or "/redirect_uri",
    discovery = os.getenv("OID_DISCOVERY"),
    client_id = os.getenv("OID_CLIENT_ID"),
    client_secret = os.getenv("OID_CLIENT_SECRET"),
    token_endpoint_auth_method = os.getenv("OIDC_AUTH_METHOD") or "client_secret_basic",
    scope = os.getenv("OIDC_AUTH_SCOPE") or "openid",
    iat_slack = 600,
}

function _module.authenticate()
  local session = require("resty.session").start()

  -- call authenticate for OpenID Connect user authentication
  local res, err = require("resty.openidc").authenticate(opts)

  if err then
    ngx.status = 500
    ngx.header.content_type = 'text/html';
    ngx.say("There was an error while logging in: " .. err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end
  
  return {
    client_id =     opts.client_id,
    client_secret = opts.client_secret,
    issuer =        session.data.id_token.iss,
    user =          session.data.id_token.name,
    email =         session.data.id_token.email,
    id_token =      session.data.enc_id_token,
    refresh_token = session.data.refresh_token
  }
end

function _module.__call()
  ngx.var.id_token = self.authenticate().id_token
end

return _module
