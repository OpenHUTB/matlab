function setPrefPanelFeatures()

    prefPropObj=PreferencePanelProperties.getOrResetInstance();

    imaqmex('feature','-gigeCommandPacketRetries',prefPropObj.getGigeCommandPacketRetries);
    imaqmex('feature','-gigeHeartbeatTimeout',prefPropObj.getGigeHeartbeatTimeout);
    imaqmex('feature','-gigePacketAckTimeout',prefPropObj.getGigePacketAckTimeout);
    imaqmex('feature','-gigeDisableForceIP',prefPropObj.getGigeDisableForceIP);
    imaqmex('feature','-macvideoFramegrabDuringDeviceDiscoveryTimeout',prefPropObj.getMacvideoDiscoveryTimeout);

end

