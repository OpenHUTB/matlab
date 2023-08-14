function signaldatavalues=getTabularData(item)





    rootID=Simulink.stawebscope.servermanager.util.getRootAndSigID(item);


    aManager=slwebwidgets.tableeditor.messagemanager.MessageManager.getMessageManager(rootID);

    [msgOut,errMsg]=constructMessage(aManager,rootID);

    if~isempty(errMsg)
        rethrow(errMsg);
    end

    signaldatavalues=msgOut.signaldatavalues;

end

