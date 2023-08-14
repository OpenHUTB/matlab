



function throwError(msgId,varargin)

    msg=message(msgId,varargin{:});
    ex=MException(msgId,msg.getString());
    throw(ex);
