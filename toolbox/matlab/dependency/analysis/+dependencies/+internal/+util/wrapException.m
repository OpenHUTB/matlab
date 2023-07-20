function me=wrapException(cause,msgid,varargin)




    msg=message(msgid,varargin{:});
    me=MException(msgid,'%s',string(msg));
    me=me.addCause(cause);

end

