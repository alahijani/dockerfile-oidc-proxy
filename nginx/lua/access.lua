local res = require("lua/auth").authenticate()
ngx.var.id_token = res.id_token
