function sigH=hGetSigHFromBusObject(this,busObjName,busObjHandleMap,portSignalName)




    sigH.SignalName=portSignalName;
    sigH.BusObject='';
    sigH.Children=[];
    busObjName=this.hCleanBusName(busObjName);

    if~busObjHandleMap.isKey(busObjName)
        return;
    end

    sigH.BusObject=busObjName;
    busObj=busObjHandleMap.getDataByKey(busObjName).busObj;
    chVec=[];
    for i=1:length(busObj.Elements)
        ele=busObj.Elements(i);
        eleDT=this.hCleanBusName(ele.DataType);
        chVec=[chVec,this.hGetSigHFromBusObject(eleDT,busObjHandleMap,ele.Name)];%#ok<AGROW>
    end
    sigH.Children=chVec;
