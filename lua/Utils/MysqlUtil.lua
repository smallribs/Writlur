MysqlUtil = {
    db = nil,
    db_host = '127.0.0.1',
    db_name = 'Blog',
    db_user = 'root',
    db_pass = '',
    db_port = 3306
}



function MysqlUtil:query(sql, row)
    res, err, errcode, sqlstate = MysqlUtil.db:query(sql, row)
    return res, err, errcode, sqlstate
end

function MysqlUtil:execute(sql)
    res, err, errcode, sqlstate =MysqlUtil.db:query(sql)
    if not res then
        ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        return
    end

    ngx.say(res.affected_rows, " rows inserted into table cats ", "(last insert id: ", res.insert_id, ")")
    return res, err, errcode, sqlstate
end

function MysqlUtil:connect()
    local mysql = require "resty.mysql"
    local db, err = mysql:new()
    if not db then
        ngx.say("failed to instantiate mysql: ", err)
        return
    end

    db:set_timeout(1000)

    local ok, err, errcode, sqlstate = db:connect{
        host = MysqlUtil.db_host,
        port = MysqlUtil.db_port,
        database = MysqlUtil.db_name,
        user =  MysqlUtil.db_user,
        password = MysqlUtil.db_pass,
        charset = "utf8",
        max_packet_size = 1024 * 1024,
    }

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return
    end

    MysqlUtil.db = db

    return
end

function MysqlUtil:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return MysqlUtil