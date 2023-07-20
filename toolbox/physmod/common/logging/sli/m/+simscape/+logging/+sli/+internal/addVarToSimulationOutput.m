function addVarToSimulationOutput(modelName,varName,logData)







    obj=get_param(modelName,'Object');
    msg=lGetMessage('physmod:common:logging2:sli:kernel:SimscapeLog');

    if nargin==2
        obj.addVarToSimulationOutput(varName,msg,'SDICompatible',true);
    else
        obj.addVarToSimulationOutput(varName,msg,logData);
        loggingListener=...
        simscape.logging.sli.internal.loggingListeners(modelName);
        if~isempty(loggingListener)
            loggingListener(modelName,varName,logData);
        end
    end

end

function msg=lGetMessage(msgId)
    msg=message(msgId).getString();
end






