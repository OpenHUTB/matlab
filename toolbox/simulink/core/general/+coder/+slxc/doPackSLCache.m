function doPackSLCache(tSlxcMasterData,okToThrow,packType)




    import Simulink.packagedmodel.pack.*
    switch(packType)
    case 'SERIAL_BUILD'
        handler=PackUsingMaster(tSlxcMasterData,okToThrow);
    case 'PARALLEL_BUILD'
        handler=PackUsingWorkers(tSlxcMasterData,okToThrow);
    case 'PARALLEL_BUILD_TESTING'
        handler=PackForParTestingMode(tSlxcMasterData,okToThrow);
    otherwise
        DAStudio.error('Simulink:cache:unknownType',packType,mfilename);
    end
    handler.execute();
end
