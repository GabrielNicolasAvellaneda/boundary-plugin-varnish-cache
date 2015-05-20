local framework = require('framework')
local Plugin = framework.Plugin
local CommandOutputDataSource = framework.CommandOutputDataSource
local Accumulator = framework.Accumulator
local PollerCollection = framework.PollerCollection
local DataSourcePoller = framework.DataSourcePoller
local Cache = framework.Cache
local os = require('os')
local table = require('table')
local gsplit = framework.string.gsplit
local clone = framework.table.clone
local isEmpty = framework.string.isEmpty
local notEmpty = framework.string.notEmpty

local params = framework.params
params.pollInterval = notEmpty(tonumber(params.pollInterval), 5000)
params.instance_name = notEmpty(params.instance_name, os.hostname()) 
params.name = 'Boundary Plugin Varnish Cache'
params.version = '1.2' 
params.tags = 'varnish'

local cmd = {
  path = 'varnishstat',
  args = { '-1'} -- -n <instance_name>
}

local function createDataSource(params, cmd) 
  if params.items and #params.items > 0 then
    local pollers = PollerCollection:new() 
    for _, item in ipairs(params.items) do
      local item_cmd = clone(cmd)
      item_cmd.info = notEmpty(item.instance_name, params.instance_name)
      table.insert(item_cmd.args, string.format('-n%s', item_cmd.info))
      local poll_interval = notEmpty(tonumber(item.pollInterval), params.pollInterval)
      local poller = DataSourcePoller:new(poll_interval, CommandOutputDataSource:new(item_cmd))
      pollers:add(poller)
    end
    return pollers
  end

  cmd.info = params.instance_name
  return CommandOutputDataSource:new(cmd)
end

local cache = Cache:new(function () return Accumulator:new() end)

local ds = createDataSource(params, cmd)

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

local plugin = Plugin:new(params, ds)
function plugin:onParseValues(data)
  local result = {}
  for line in gsplit(data.output, '\n') do
    local metric, value = string.match(line, '([^%s]+)%s+(%d+)')
    if metric then
      local bm = boundary_metrics[metric] 
      if bm then
        local acc = cache:get(data.info)
        value = acc:accumulate(bm, tonumber(value))
        result[bm] = { value = value, source = data.info }
      end
    end
  end
  return result
end

plugin:run()
