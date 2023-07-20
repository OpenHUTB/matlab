






function success=convertSignalDescriptorToBusObjectAndRegister(sdObj,blockPath)

    if isempty(blockPath)
        dataAccessor=Simulink.data.DataAccessor.createWithNoContext();
    else
        blockHandle=get_param(blockPath,'handle');
        dataAccessor=Simulink.data.DataAccessor.createForExternalData(bdroot(blockHandle));
    end
    if sdObj.isBus()
        success=l_ConversionSigDescToBusObj_helper(sdObj,blockPath,dataAccessor);
    else

    end
end


function success=l_ConversionSigDescToBusObj_helper(sdObj,blockPath,dataAccessor)
    assert(~sdObj.isPartial());

    datatype=sdObj.getDataTypeName();

    if isempty(datatype)
        DAStudio.error('Simulink:Bus:DynamicBusMustHaveNamesAtEachLevel',blockPath);
    end



    tempBusObj=sl('slbus_get_object_from_name_withDataAccessor',datatype,false,dataAccessor);
    if~isempty(tempBusObj)
        success=true;
        return;
    end


    retBO=Simulink.Bus;
    numChildren=sdObj.getNumElements();
    for idx=1:numChildren
        curChild=sdObj.getElement(idx);
        curChildDataType=curChild.getDataTypeName();
        numChildrenCurChild=curChild.getNumElements();


        if numChildrenCurChild>0

            if isempty(curChildDataType)
                DAStudio.error('Simulink:Bus:DynamicBusMustHaveNamesAtEachLevel',blockPath);
            end


            tempBusObj=sl('slbus_get_object_from_name_withDataAccessor',curChildDataType,false,dataAccessor);


            if isempty(tempBusObj)
                if~l_ConversionSigDescToBusObj_helper(curChild,blockPath,dataAccessor)
                    success=false;
                    return;
                end
            end


            curElem=Simulink.BusElement;
            curElem.DataType=['Bus: ',curChildDataType];
            curElem.Name=sdObj.getElementName(idx);


            curElem.Dimensions=curChild.getDimensions();
            retBO.Elements=[retBO.Elements;curElem];
        else

            curElem=l_getBusElementFromNonBusSigDesc_helper(curChild,blockPath,dataAccessor);
            if~isempty(curElem)
                curElem.Name=sdObj.getElementName(idx);
                retBO.Elements=[retBO.Elements;curElem];
            else
                success=false;
                return;
            end
        end
    end


    Simulink.Bus.register(datatype,retBO,true,'alterDims',false);
    success=true;
end






function retBusElem=l_getBusElementFromNonBusSigDesc_helper(sdObj,blockPath,dataAccessor)

    if sdObj.isPartial()
        retBusElem=[];
        return;
    end

    [parentBusName,idxInParent]=sdObj.getParentInfo();

    if~isempty(parentBusName)


        busObj=sl('slbus_get_object_from_name_withDataAccessor',parentBusName,false,dataAccessor);
        retBusElem=busObj.Elements(idxInParent);
    elseif isempty(sdObj.getInportIdx())

        retBusElem=Simulink.BusElement;
        retBusElem.Complexity=sdObj.getComplexity();
        retBusElem.Dimensions=sdObj.getDimensions();
        retBusElem.DataType=sdObj.getDataTypeName();
    else


        DAStudio.error('Simulink:Bus:DynamicBusCannotUseNonBusInputs',blockPath);
    end
end


