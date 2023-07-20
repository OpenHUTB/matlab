function tf=setPrefValues(prefName,prefValue)




    tf=true;
    prefObj=PreferencePanelProperties.getOrResetInstance();

    switch prefName
    case '-gigecommandpacketretries'
        prefObj.setGigeCommandPacketRetries(prefValue);
    case '-gigeheartbeattimeout'
        prefObj.setGigeHeartbeatTimeout(prefValue);
    case '-gigepacketacktimeout'
        prefObj.setGigePacketAckTimeout(prefValue);
    case '-gigedisableforceip'
        prefObj.setGigeDisableForceIP(prefValue);
    case '-macvideoframegrabduringdevicediscoverytimeout'
        prefObj.setMacvideoDiscoveryTimeout(prefValue);
    otherwise
        tf=false;
    end
end

