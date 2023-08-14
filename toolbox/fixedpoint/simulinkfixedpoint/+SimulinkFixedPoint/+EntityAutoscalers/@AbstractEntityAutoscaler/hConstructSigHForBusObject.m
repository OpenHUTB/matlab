function sigH=hConstructSigHForBusObject(h,busObjName,busObjHandleMap)






    sigH.SignalName=busObjName;
    sigH.BusObject=busObjName;
    sigH.Children=getChildrenSigH(h,busObjName,busObjHandleMap);


    function sigHier=getChildrenSigH(h,parentbusName,busObjHandleMap)

        parentBusObjHandle=busObjHandleMap.getDataByKey(parentbusName);


        for i=1:length(parentBusObjHandle.elementNames)

            sigH.SignalName=parentBusObjHandle.elementNames{i};
            elementDT=h.hCleanBusName(parentBusObjHandle.specifiedDTs{i});
            if busObjHandleMap.isKey(elementDT)
                childBusObjName=elementDT;
                sigH.BusObject=childBusObjName;
                sigH.Children=getChildrenSigH(h,childBusObjName,busObjHandleMap);
            else
                sigH.BusObject='';
                sigH.Children=[];
            end
            sigHier(i)=sigH;%#ok

        end
