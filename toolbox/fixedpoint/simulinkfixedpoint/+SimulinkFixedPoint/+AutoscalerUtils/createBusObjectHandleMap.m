function busObjHandleMap=createBusObjectHandleMap(modelName)










    busObjHandleMap=SimulinkFixedPoint.BusObjectHandleMap;

    wksObjFinder=SimulinkFixedPoint.AutoscalerUtils.WorkspaceObjectFinder...
    (modelName,'Simulink.Bus');
    busNameList=wksObjFinder.getNameListFromGlobalWks();

    reservedBusTypes=SimulinkFixedPoint.AutoscalerUtils.ReservedBusTypes.getInstance();
    busNameList=[busNameList;reservedBusTypes.getReservedNames()];

    for i_busName=1:length(busNameList)
        busName=busNameList{i_busName};
        if~busObjHandleMap.isKey(busName)
            busObjHandleMap.insert(busName,...
            SimulinkFixedPoint.BusObjectHandle(busName,modelName,busNameList));
        end
    end

