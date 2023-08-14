function oldState=setGlobalDataStoreLogging(varName,sourceType,enableLogging,model)




    if strcmp(sourceType,'base')||strcmp(sourceType,'base workspace')
        wkSpc='base';
    elseif strcmp(sourceType,'model')||strcmp(sourceType,'model workspace')

        wkSpc=get_param(model,'ModelWorkspace');
    else

        oldState=enableLogging;
        return;
    end


    signalObj=evalin(wkSpc,varName);
    oldState=signalObj.LoggingInfo.DataLogging;
    if(oldState~=enableLogging)
        signalObj.LoggingInfo.DataLogging=enableLogging;
    end
end
