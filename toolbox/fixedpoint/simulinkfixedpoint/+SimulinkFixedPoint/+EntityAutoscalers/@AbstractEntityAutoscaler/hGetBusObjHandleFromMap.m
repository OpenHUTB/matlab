function busObjHandle=hGetBusObjHandleFromMap(h,busObjName,busObjHandleMap)%#ok







    if busObjHandleMap.isKey(busObjName)
        busObjHandle=busObjHandleMap.getDataByKey(busObjName);
    else
        errorID='SimulinkFixedPoint:autoscaling:BusObjectHandleNotFoundInMap';
        DAStudio.error(errorID,busObjName);
    end





