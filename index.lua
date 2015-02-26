-- [boundary.com] Varnish Cache Lua Plugin
-- [author] Ivano Picco <ivano.picco@pianobit.com>

-- Requires.
local utils = require('utils')
local uv_native = require ('uv_native')
local string = require('string')
local split = require('split')
local timer = require('timer')
local ffi = require ('ffi')
local fs = require('fs')
local json = require('json')
local os = require ('os')

local childProcess = require ('childprocess')

local success, boundary = pcall(require,'boundary')
if (not success) then
  boundary = nil 
end

local isWindows = os.type() == 'win32'

-- portable gethostname syscall
ffi.cdef [[
  int gethostname (char *, int);
]]
function gethostname()
  local buf = ffi.new("uint8_t[?]", 256)
  if ( not isWindows ) then 
    ffi.C.gethostname(buf,256)
  else
    local clib = ffi.load('ws2_32')
    clib.gethostname(buf,256)
  end
  return ffi.string(buf)
end

-- Default parameters.
local pollInterval = 10000
local source       = nil

-- Configuration.
local _parameters = (boundary and boundary.param and boundary.param) or json.parse(fs.readFileSync('param.json')) or {}

_parameters.pollInterval = 
  (_parameters.pollInterval and tonumber(_parameters.pollInterval)>0  and tonumber(_parameters.pollInterval)) or
  pollInterval;

_parameters.source =
  (type(_parameters.source) == 'string' and _parameters.source:gsub('%s+', '') ~= '' and _parameters.source ~= nil and _parameters.source) or
  gethostname()

-- Back-trail.
local previousValues={}
local currentValues={}

-- Get difference between current and previous value.
function diffvalues(name)
  local cur  = currentValues[name]
  local last = previousValues[name] or cur
  previousValues[name] = cur
  return  (tonumber(cur) - tonumber(last))
end

-- Parse line (i.e. line: "connected_clients : <value>").
function parseEachLine(line)
  local t = split(line,' ')
  if (#t >= 2) then
    currentValues[t[1]]=t[2];
  end
end

-- print results
function outputs()

  utils.print('VARNISH_CACHE_ACCEPT_FAIL', diffvalues('accept_fail'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_BUSY', diffvalues('backend_busy'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_CONN', diffvalues('backend_conn'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_FAIL', diffvalues('backend_fail'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_RECYCLE', diffvalues('backend_recycle'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_REQ', diffvalues('backend_req'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_RETRY', diffvalues('backend_retry'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_REUSE', diffvalues('backend_reuse'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_TOOLATE', diffvalues('backend_toolate'), _parameters.source)
  utils.print('VARNISH_CACHE_BACKEND_UNHEALTHY', diffvalues('backend_unhealthy'), _parameters.source)
  utils.print('VARNISH_CACHE_CACHE_HIT', diffvalues('cache_hit'), _parameters.source)
  utils.print('VARNISH_CACHE_CACHE_HITPASS', diffvalues('cache_hitpass'), _parameters.source)
  utils.print('VARNISH_CACHE_CACHE_MISS', diffvalues('cache_miss'), _parameters.source)
  utils.print('VARNISH_CACHE_CLIENT_CONN', diffvalues('client_conn'), _parameters.source)
  utils.print('VARNISH_CACHE_CLIENT_DROP', diffvalues('client_drop'), _parameters.source)
  utils.print('VARNISH_CACHE_CLIENT_DROP_LATE', diffvalues('client_drop_late'), _parameters.source)
  utils.print('VARNISH_CACHE_CLIENT_REQ', diffvalues('client_req'), _parameters.source)
  utils.print('VARNISH_CACHE_FETCH_1XX', diffvalues('fetch_1xx'), _parameters.source)
  utils.print('VARNISH_CACHE_FETCH_204', diffvalues('fetch_204'), _parameters.source)
  utils.print('VARNISH_CACHE_FETCH_304', diffvalues('fetch_304'), _parameters.source)
  utils.print('VARNISH_CACHE_FETCH_FAILED', diffvalues('fetch_failed'), _parameters.source)
  utils.print('VARNISH_CACHE_FETCH_HEAD', diffvalues('fetch_head'), _parameters.source)
  utils.print('VARNISH_CACHE_LOSTHDR', diffvalues('losthdr'), _parameters.source)
  utils.print('VARNISH_CACHE_S_BODYBYTES', diffvalues('s_bodybytes'), _parameters.source)
  utils.print('VARNISH_CACHE_S_FETCH', diffvalues('s_fetch'), _parameters.source)
  utils.print('VARNISH_CACHE_S_HDRBYTES', diffvalues('s_hdrbytes'), _parameters.source)
  utils.print('VARNISH_CACHE_S_PASS', diffvalues('s_pass'), _parameters.source)
  utils.print('VARNISH_CACHE_S_PIPE', diffvalues('s_pipe'), _parameters.source)
  utils.print('VARNISH_CACHE_S_REQ', diffvalues('s_req'), _parameters.source)
  utils.print('VARNISH_CACHE_S_SESS', diffvalues('s_sess'), _parameters.source)

end

-- Client initialization

-- Get current values.
function poll()
--  local Process = require('uv').Process
--  Process:new(command, args, options)

  childProcess.execFile("varnishstat", {"-1"} , {},
    function ( err, stdout, stderr )
      
      -- call func with each word in a string
      stdout:gsub("[^\r\n]+", parseEachLine)

      outputs()
    end
  )

end

-- Ready, go.
poll()
timer.setInterval(_parameters.pollInterval,poll)