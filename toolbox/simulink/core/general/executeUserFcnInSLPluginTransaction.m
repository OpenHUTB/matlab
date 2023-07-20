


function executeUserFcnInSLPluginTransaction(bdHandle,pluginName,transactionContextInfo,userFcn,errorHandlingFcn,commitOnSave)

    try
        pluginMgr=Simulink.PluginMgr;
        pluginTxn=pluginMgr.beginTransaction(bdHandle,pluginName,transactionContextInfo,commitOnSave);
    catch ME


        errorHandlingFcn(ME);
        return;
    end


    try
        userFcn(bdHandle);
    catch ME
        errorHandlingFcn(ME)
    end


    pluginTxn.commitTransaction
end
