function result=construct_modelref_message(coderMsgID,simMsgID,targetType,varargin)


    switch(targetType)
    case 'RTW'
        msgID=coderMsgID;
    case 'SIM'
        msgID=simMsgID;
    otherwise
        assert(false,'Should not be here!');
    end
    result=DAStudio.message(msgID,varargin{:});
end