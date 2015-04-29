local framework = require('framework')
local Plugin = framework.Plugin
local CommandOutputDataSource = framework.CommandOutputDataSource
local Accumulator = framework.Accumulator
local os = require('os')
local split = framework.string.split
local isEmpty = framework.string.isEmpty

local params = framework.params
params.pollInterval = params.pollInterval and tonumber(params.pollInterval)*1000 or 10000
params.instance_name = params.instance_name or os.hostname() 
-- TODO: Handle params.items with instance_name each
-- TODO: Create an accumulator for each item
params.name = 'Boundary Plugin Varnish Cache'
params.version = '1.2' 
params.tags = 'varnish'

local cmd = {
  path = 'varnishstat',
  args = { '-1'} -- -n <instance_name>
}

local boundary_metrics = {
  accept_fail = 'VARNISH_CACHE_ACCEPT_FAIL',
  ubackend_busy = 'VARNISH_CACHE_BACKEND_BUSY',
  ubackend_con = 'VARNISH_CACHE_BACKEND_CONN',
  backend_fail = 'VARNISH_CACHE_BACKEND_FAIL',
  ubackend_recycl = 'VARNISH_CACHE_BACKEND_RECYCLE',
  ubackend_re = 'VARNISH_CACHE_BACKEND_REQ',
  backend_retry = 'VARNISH_CACHE_BACKEND_RETRY', 
  ubackend_reus = 'VARNISH_CACHE_BACKEND_REUSE',
  ubackend_toolat = 'VARNISH_CACHE_BACKEND_TOOLATE',
  backend_unhealthy = 'VARNISH_CACHE_BACKEND_UNHEALTHY',
  cache_hit = 'VARNISH_CACHE_CACHE_HIT', 
  cache_hitpass = 'VARNISH_CACHE_CACHE_HITPASS',
  cache_miss = 'VARNISH_CACHE_CACHE_MISS',
  client_conn = 'VARNISH_CACHE_CLIENT_CONN',
  client_drop = 'VARNISH_CACHE_CLIENT_DROP',
  client_drop_late = 'VARNISH_CACHE_CLIENT_DROP_LATE',
  client_req = 'VARNISH_CACHE_CLIENT_REQ',
  fetch_1xx = 'VARNISH_CACHE_FETCH_1XX',
  fetch_204 = 'VARNISH_CACHE_FETCH_204',
  fetch_304 = 'VARNISH_CACHE_FETCH_304',
  fetch_failed = 'VARNISH_CACHE_FETCH_FAILED',
  fetch_head  = 'VARNISH_CACHE_FETCH_HEAD',
  losthdr = 'VARNISH_CACHE_LOSTHDR',
  s_bodybytes = 'VARNISH_CACHE_S_BODYBYTES',
  s_fetch = 'VARNISH_CACHE_S_FETCH',
  s_hdrbytes = 'VARNISH_CACHE_S_HDRBYTES',
  s_pass = 'VARNISH_CACHE_S_PASS',
  s_pipe = 'VARNISH_CACHE_S_PIPE',
  s_req = 'VARNISH_CACHE_S_REQ',
  s_sess = 'VARNISH_CACHE_S_SESS',
}

local ds = CommandOutputDataSource:new(cmd)

local function parsemetric(source,line)
  local t = tools.split(line,' ')
  if (#t >= 2) then
    currentValues[source][t[1]]=t[2];
  end
end

local acc = Accumulator:new()
local plugin = Plugin:new(params, ds)
function plugin:onParseValues(data)
  local result = {}
  local lines = split(data.output, '\n') 
  for _,  line in ipairs(lines) do
    local metric, value = string.match(line, '([^%s]+)%s+([%d+])')
    if metric then
      local bm = boundary_metrics[metric] 
      if bm then
        result[bm] = acc:accumulate(bm, tonumber(value))
      end
    end
  end
  return result
end

plugin:run()
