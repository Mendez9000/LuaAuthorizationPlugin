local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local https = require 'ssl.https'

local req_get_headers = ngx.req.get_headers

local EchoHandler = BasePlugin:extend()

EchoHandler.PRIORITY = 2000
EchoHandler.VERSION = "0.1.0"

function EchoHandler:new()
  EchoHandler.super.new(self, "kong-plugin-header-echo")
  self.echo_string = ""
end

function EchoHandler:access(conf)
  EchoHandler.super.access(self)
  
  local authorization = req_get_headers()["Authorization"]

  local t = {}
    local r, c, h, s = https.request{
        url = "https://auth.dev.peja.co:443/v1/info?token="..authorization,
        sink = ltn12.sink.table(t),
        protocol = "tlsv1",
        verify_host = false
    }

    if (c ~= 200) then
        responses.send(c, s)
    end
end

return EchoHandler
