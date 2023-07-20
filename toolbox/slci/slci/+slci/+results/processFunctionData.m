function processFunctionData(datamgr)


    ProfileInterface=slci.internal.Profiler('SLCI',...
    'ProcessInterfaceResults',...
    '','');


    functionInterfaceReader=datamgr.getFunctionInterfaceReader();
    funcKeys=functionInterfaceReader.getKeys();


    for k=1:numel(funcKeys)

        funcKey=funcKeys{k};
        fObject=functionInterfaceReader.getObject(funcKey);
        fObject.computeStatus();
        functionInterfaceReader.replaceObject(funcKey,fObject);
    end

    ProfileInterface.stop();
