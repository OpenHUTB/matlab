function msgStr=getString(msgId,varargin)




    if(stm.internal.MRT.utility.getMRTEnvironment())
        msgStr=getString(message(msgId,varargin{:}));
    else
        pool=stm.internal.MRT.mrtpool.getInstance;
        msg=pool.getMessage(msgId,varargin);
        msgStr=msg.message;
    end
end
