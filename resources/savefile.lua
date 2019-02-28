package.path = '/usr/local/openresty/lualib/resty/?.lua;'
local upload = require "upload"
local chunk_size = 4096
local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
end
form:set_timeout(1000)

local file
local filelen=0
local filename
function get_filename(res)
    local filename = ngx.re.match(res,'(.+)filename="(.+)"(.*)')
    if filename then
        return filename[2]
    end
end

local osfilepath = "/tmp/uploads/"
local i=0
while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        return
    end
    if typ == "header" then
        if res[1] ~= "Content-Type" then
            filename = get_filename(res[2])
            if filename then
                i=i+1
                filepath = osfilepath .. filename
                file = io.open(filepath,"w+")
                if not file then
                    ngx.say("failed to open file!")
                    return
                end
            else
            end
        end
    elseif typ == "body" then
        if file then
            filelen= filelen + tonumber(string.len(res))
            file:write(res)
        else
        end
    elseif typ == "part_end" then
        if file then
            file:close()
            file = nil
            ngx.say("file upload succeed.")
        end
    elseif typ == "eof" then
        break
    else
    end
end
if i==0 then
    ngx.say("please upload at least one file!")
    return
end
