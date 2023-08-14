function error(msgId,varargin)




    if(stm.internal.MRT.utility.getMRTEnvironment())
        error(message(msgId,varargin{:}));
    else
        pool=stm.internal.MRT.mrtpool.getInstance;
        msg=pool.getMessage(msgId,varargin);
        tmpError=MException(msg.identifier,msg.message);
        throwAsCaller(tmpError);
    end
end
