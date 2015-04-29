-- [boundary.com] Varnish Cache Lua Plugin
-- [author] Ivano Picco <ivano.picco@pianobit.com>

-- Common requires.
local utils = require('utils')
local timer = require('timer')
local fs = require('fs')
local json = require('json')
local os = require ('os')
local tools = require ('tools')

local success, boundary = pcall(require,'boundary')
if (not success) then
  boundary = nil 
end

-- Business requires.
local childProcess = require ('childprocess')

-- Default parameters.
local pollInterval = 10000
local source       = nil

-- Configuration.
local _parameters = (boundary and boundary.param ) or json.parse(fs.readFileSync('param.json')) or {}

_parameters.pollInterval = 
  (_parameters.pollInterval and tonumber(_parameters.pollInterval)>0  and tonumber(_parameters.pollInterval)) or
  pollInterval;

_parameters.source =
  (type(_parameters.source) == 'string' and _parameters.source:gsub('%s+', '') ~= '' and _parameters.source ~= nil and _parameters.source) or
  os.hostname()

-- Back-trail.
local previousValues={}
local currentValues={}

-- Get difference between current and previous value.
function diffvalues(source,name)
  local cur  = currentValues[source][name] or 0
  local last = previousValues[source][name] or cur or 0
  previousValues[source][name] = cur
  return  (tonumber(cur) - tonumber(last))
end

-- Parse line (i.e. line: "connected_clients : <value>").
function parseEachLine(source,line)
  local t = tools.split(line,' ')
  if (#t >= 2) then
    currentValues[source][t[1]]=t[2];
  end
end

-- print results
function outputs(source)

  utils.print('VARNISH_CACHE_ACCEPT_FAIL', diffvalues(source, 'accept_fail'), source)
  utils.print('VARNISH_CACHE_BACKEND_BUSY', diffvalues(source, 'backend_busy'), source)
  utils.print('VARNISH_CACHE_BACKEND_CONN', diffvalues(source, 'backend_conn'), source)
  utils.print('VARNISH_CACHE_BACKEND_FAIL', diffvalues(source, 'backend_fail'), source)
  utils.print('VARNISH_CACHE_BACKEND_RECYCLE', diffvalues(source, 'backend_recycle'), source)
  utils.print('VARNISH_CACHE_BACKEND_REQ', diffvalues(source, 'backend_req'), source)
  utils.print('VARNISH_CACHE_BACKEND_RETRY', diffvalues(source, 'backend_retry'), source)
  utils.print('VARNISH_CACHE_BACKEND_REUSE', diffvalues(source, 'backend_reuse'), source)
  utils.print('VARNISH_CACHE_BACKEND_TOOLATE', diffvalues(source, 'backend_toolate'), source)
  utils.print('VARNISH_CACHE_BACKEND_UNHEALTHY', diffvalues(source, 'backend_unhealthy'), source)
  utils.print('VARNISH_CACHE_CACHE_HIT', diffvalues(source, 'cache_hit'), source)
  utils.print('VARNISH_CACHE_CACHE_HITPASS', diffvalues(source, 'cache_hitpass'), source)
  utils.print('VARNISH_CACHE_CACHE_MISS', diffvalues(source, 'cache_miss'), source)
  utils.print('VARNISH_CACHE_CLIENT_CONN', diffvalues(source, 'client_conn'), source)
  utils.print('VARNISH_CACHE_CLIENT_DROP', diffvalues(source, 'client_drop'), source)
  utils.print('VARNISH_CACHE_CLIENT_DROP_LATE', diffvalues(source, 'client_drop_late'), source)
  utils.print('VARNISH_CACHE_CLIENT_REQ', diffvalues(source, 'client_req'), source)
  utils.print('VARNISH_CACHE_FETCH_1XX', diffvalues(source, 'fetch_1xx'), source)
  utils.print('VARNISH_CACHE_FETCH_204', diffvalues(source, 'fetch_204'), source)
  utils.print('VARNISH_CACHE_FETCH_304', diffvalues(source, 'fetch_304'), source)
  utils.print('VARNISH_CACHE_FETCH_FAILED', diffvalues(source, 'fetch_failed'), source)
  utils.print('VARNISH_CACHE_FETCH_HEAD', diffvalues(source, 'fetch_head'), source)
  utils.print('VARNISH_CACHE_LOSTHDR', diffvalues(source, 'losthdr'), source)
  utils.print('VARNISH_CACHE_S_BODYBYTES', diffvalues(source, 's_bodybytes'), source)
  utils.print('VARNISH_CACHE_S_FETCH', diffvalues(source, 's_fetch'), source)
  utils.print('VARNISH_CACHE_S_HDRBYTES', diffvalues(source, 's_hdrbytes'), source)
  utils.print('VARNISH_CACHE_S_PASS', diffvalues(source, 's_pass'), source)
  utils.print('VARNISH_CACHE_S_PIPE', diffvalues(source, 's_pipe'), source)
  utils.print('VARNISH_CACHE_S_REQ', diffvalues(source, 's_req'), source)
  utils.print('VARNISH_CACHE_S_SESS', diffvalues(source, 's_sess'), source)

end

-- Get current values.
function poll(source)

  childProcess.execFile("varnishstat", {"-1", "-n"..source} , {},
    function ( err, stdout, stderr )
      if (err or #stderr>0) then 
        --print errors to stderr
        utils.debug(err or stderr)
        return
      end

      -- call func with each word in a string
      stdout:gsub("[^\r\n]+", function(line)
        parseEachLine(source,line)
      end)


      outputs(source)
    end
  )

end

-- Ready, go.
if (#_parameters.items >0 ) then
  for _,item in ipairs(_parameters.items) do 
    local source = item.instance_name and item.instance_name or _parameters.source --default hostname
    currentValues[source]={};
    previousValues[source]={};
    timer.setInterval(_parameters.pollInterval,poll,source)
  end
else
  local source = _parameters.source --default hostname
  currentValues[source]={};
  previousValues[source]={};
  timer.setInterval(_parameters.pollInterval,poll,source)
end

