homepage = {}


function homepage.test()
end

function homepage.blog()

    ngx.header['Access-Control-Allow-Origin'] = '*'
    ngx.header['Access-Control-Allow-Headers'] = 'content-type'
    ngx.header['Access-Control-Request-Method'] = 'GET,POST'

    local heplper = require(".Common.Helper")
    local MysqlUtil = require(".Utils.MysqlUtil")

    mysql_util = MysqlUtil:new()
    mysql_util.connect()

    local id = tostring(tonumber(ngx.var.arg_id))
    local sql = string.format("SELECT id, title, tag, html, create_at FROM blogs WHERE id = %s", id)
    res, err, errcode, sqlstate = mysql_util.query(mysql_util, sql)

    local content = {status_code = 200, status = "success", result = res}
    heplper.echo_json(content)

end

function homepage.blogs()

    ngx.header['Access-Control-Allow-Origin'] = '*'
    ngx.header['Access-Control-Allow-Headers'] = 'content-type'
    ngx.header['Access-Control-Request-Method'] = 'GET,POST'

    local heplper = require(".Common.Helper")
    local MysqlUtil = require(".Utils.MysqlUtil")

    mysql_util = MysqlUtil:new()
    mysql_util.connect()

    local page = tostring(0)
    local sql = string.format("SELECT id, title, create_at FROM blogs limit %s, 10", page)
    res, err, errcode, sqlstate = mysql_util.query(mysql_util, sql)
    if err then
        local content = {status_code = 400, status = "error"}
        heplper.echo_json(content)
        return
    end

    local content = {status_code = 200, status = "success", result = res}
    heplper.echo_json(content)

end

return homepage