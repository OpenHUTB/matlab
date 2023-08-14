



function result=convertSignalHierarchyToSignalDescriptor(blockPath,inportIdx)

    ph=get_param(blockPath,'portHandles');
    signalHierarchy=get_param(ph.Inport(inportIdx),'SignalHierarchy');

    blockHandle=get_param(blockPath,'handle');
    dataAccessor=Simulink.data.DataAccessor.createForExternalData(bdroot(blockHandle));
    result=l_SigHierToSigDescHelper(signalHierarchy,[],[],dataAccessor);


    if~isempty(result)&&~result.isBus()
        result.setInportIdx(inportIdx);
    end
end




function result=l_SigHierToSigDescHelper(shInfo,parentBusName,idxInParent,dataAccessor)
    busObjectName=shInfo.BusObject;
    children=shInfo.Children;
    result=Simulink.SignalDescriptor;


    result.setParentInfo(parentBusName,idxInParent);


    result.setComplete();


    if~isempty(busObjectName)
        result.setDataTypeName(busObjectName);

        busObject=sl('slbus_get_object_from_name_withDataAccessor',busObjectName,false,dataAccessor);



        if isempty(busObject)||...
            ~isequal(length(busObject.Elements),length(children))
            result=Simulink.SignalDescriptor;
            return;
        end

        for idx=1:length(children)
            childSigHierInfo=children(idx);
            childSigDesc=l_SigHierToSigDescHelper(childSigHierInfo,busObjectName,idx,dataAccessor);

            childSigDesc.setDimensions(busObject.Elements(idx).Dimensions);


            if isempty(childSigHierInfo.BusObject)
                childSigDesc.setAttributes(busObject.Elements(idx));
            end

            result.addElement(childSigDesc,busObject.Elements(idx).Name);
        end
    end
end


