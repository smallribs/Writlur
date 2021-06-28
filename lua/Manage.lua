manage = {}

function manage.login()

    local helper = require(".Common.Helper")

    if helper.is_post() then

        local cjson = require "cjson"

        local data = cjson.decode(helper.get_post())
        local username = data.username
        local password = data.password
        local MysqlUtil = require(".Utils.MysqlUtil")
        mysql_util = MysqlUtil:new()
        mysql_util.connect()
        local sql = "SELECT '" .. username .."' FROM manager WHERE password = '" .. password .. "'"
        res, err, errcode, sqlstate = mysql_util.query(mysql_util, sql, 1)
        
        if err then
            --ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
            return
        end
    
        if #res == 0 then
            content = {status_code = '400', status = 'login fail'}
            helper.echo_json(content)
            ngx.exit(500)
            return
        end

        local JWTUtil = require('.Utils.JWTUtil')
        local JWT_Token = JWTUtil.generate(username)

        ngx.header["Set-Cookie"] = "JWT_Token=" .. JWT_Token.. "; path=/; Expires=" .. ngx.cookie_time(ngx.time() + 60 * 60) 
        local cjson = require "cjson"
        --ngx.say("result: ", cjson.encode(res))
    end
end

function manage.index()
    local helper = require("Common.Helper")
    if not helper.is_login() then
        return
    end

    local MysqlUtil = require(".Utils.MysqlUtil")
    mysql_util = MysqlUtil:new()
    mysql_util.connect()

    local sql = string.format("SELECT id, title, create_at FROM blogs")
    res, err, errcode, sqlstate = mysql_util.query(mysql_util, sql, 10)
    content = {result = res}
    helper.echo_json(content)


end

function manage.create()
    local helper = require("Common.Helper")
    if not helper.is_login() then
        return
    end

    if helper.is_post() then
        local cjson = require "cjson"
        local data = cjson.decode(helper.get_post())
        local title = data.title
        local tag = data.tag
        local markdown = data.markdown
        local html = data.html
        local create_at = tostring(os.time())

        content = {
            title = title,
            tag = tag,
            markdwon = markdown,
            html = html, 
            create_at = create_at,
            update_at = ''
        }

        helper.echo_json(content)

        local MysqlUtil = require(".Utils.MysqlUtil")
        mysql_util = MysqlUtil:new()
        mysql_util.connect()

        local sql = string.format("INSERT INTO blogs (title, tag, markdown, html, create_at, update_at) VALUES ('%s', '%s', '%s', '%s', '%s', '%s')", title, tag, markdown, html, create_at, '')
        res, err, errcode, sqlstate = mysql_util.execute(mysql_util, sql)
    end

end

function manage.edit()
    local helper = require("Common.Helper")
    if not helper.is_login() then
        return
    end
end

function manage.destroy()
    local helper = require("Common.Helper")
    if not helper.is_login() then
        return
    end
end

function manage.logout()
    local helper = require("Common.Helper")
    ngx.header['Set-Cookie'] = 'JWT_Token=; Expires=' .. ngx.cookie_time(ngx.time() + 60 * 30)
    local content = {status_code="200", status="退出成功"}
    helper.echo_json(content)
end

return manage

