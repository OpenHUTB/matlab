function sharedList=gatherSharedDTWithBusObj(this,variableIdentifier,~,busObjHandleMap)




    sharedList={};
    mlBlock=variableIdentifier.getMATLABFunctionBlock;
    if isempty(mlBlock)||~variableIdentifier.isStruct
        return;
    end

    sfDataObject=this.hGetRelatedSFData(variableIdentifier);

    if~isempty(sfDataObject)&&variableIdentifier.IsArgin&&sfDataObject.Port>0
        portNum=sfDataObject.Port;
        inputPort=mlBlock.PortHandles.Inport(portNum);
        if hIsNonVirtualBus(this,inputPort)


            hidSrc=hGetHiddenNonVirBusSrc(this,get_param(inputPort,'Object'),false);
            if~isempty(hidSrc)
                sharedList=this.hAppendToSharedLists(sharedList,{hidSrc});
            end
        end
    end

    sharedList=AppendDueToBusObjSharing(this,sfDataObject,variableIdentifier,sharedList,busObjHandleMap);


    function sharedList=AppendDueToBusObjSharing(h,sfDataObject,variableIdentifier,sharedList,busObjHandleMap)

        if~isempty(sfDataObject)
            busName=h.hCleanBusName(sfDataObject.CompiledType);
            if busObjHandleMap.isKey(busName)
                busObjectHandle=busObjHandleMap.getDataByKey(busName);

                busObjID=h.hGetLeafBusObjElementID(variableIdentifier.VariableName,busObjectHandle,busObjHandleMap);

                paramRec.blkObj=variableIdentifier;
                paramRec.pathItem=variableIdentifier.VariableName;

                oneList={busObjID,paramRec};
                sharedList=h.hAppendToSharedLists(sharedList,oneList);
            end
        end
