function me=msgSafeException(msgID,varargin)


    if~isa(msgID,'message')
        msg=message(msgID,varargin{:});
    else
        msg=msgID;
    end
    me=MException(msg.Identifier,'%s',msg.getString());
