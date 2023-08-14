function warning(msgId,varargin)




    if(stm.internal.MRT.utility.getMRTEnvironment())
        warning(message(msgId,varargin{:}));
    else
        pool=stm.internal.MRT.mrtpool.getInstance;
        msg=pool.getMessage(msgId,varargin);
        warning(msg.identifier,msg.message);
    end
end
