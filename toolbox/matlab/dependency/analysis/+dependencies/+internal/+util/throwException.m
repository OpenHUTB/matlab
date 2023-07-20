function throwException(msgid,varargin)




    msg=message(msgid,varargin{:});
    error(msgid,'%s',string(msg));

end

