


function clearDynamicBusNameCacheForRootIOPort()
    busDict=Simulink.BusDictionary.getInstance();
    busDict.clearDBusNameSetForRootIOPort();
end

