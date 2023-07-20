function msgOut=getSTASignalDataForMW(signalID,appID,tableID)


    msgOut.signaldatavalues={};

    msgOut=slwebwidgets.tableeditor.messagemanager.MessageManager.sendSignalDataMessage(signalID,appID,tableID);

end

