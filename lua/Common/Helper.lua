helper = {}

function helper.echo_json(content)
    local json = require "cjson"
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'
    ngx.say(json.encode(content))
end

function helper.is_post()
    local method = ngx.req.get_method()
    if method == "POST" then
        return true
    else
        return false
    end
end

function helper.get_post()
    ngx.req.read_body()  
    local post_args = ngx.req.get_body_data()
    return post_args
end

function helper.is_login()
    local JWT_Token = ngx.var.cookie_JWT_Token
    if #JWT_Token == 0 then
        local json = require "cjson"
        ngx.header['Content-Type'] = 'application/json; charset=utf-8'
        local content = {status_code='400', status='Token验证失败,请重新登陆!'}
        ngx.say(json.encode(content))
        return 
    end
    local JWT = require('.Utils.JWTUtil')
    if JWT.verify(JWT_Token) then
        return true
    else
        local json = require "cjson"
        ngx.header['Content-Type'] = 'application/json; charset=utf-8'
        local content = {status_code='400', status='Token验证失败,请重新登陆!'}
        ngx.say(json.encode(content))
        return false
    end
end

return helper