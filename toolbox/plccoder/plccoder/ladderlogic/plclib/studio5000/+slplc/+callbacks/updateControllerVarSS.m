function updateControllerVarSS(varSSBlock)




    if~strcmpi(get_param(bdroot(varSSBlock),'SimulationStatus'),'stopped')
        return
    end

    maskObj=Simulink.Mask.get(varSSBlock);
    propertyNum=8;
    varNum=round(numel(maskObj.Parameters)/propertyNum);

    for varCount=1:varNum
        nameParamIdx=(varCount-1)*propertyNum+1;
        mappingIdx=nameParamIdx+1;
        addressIdx=nameParamIdx+2;
        portIndexIdx=nameParamIdx+3;
        dataTypeIdx=nameParamIdx+4;
        dataSizeIdx=nameParamIdx+5;
        initValueIdx=nameParamIdx+6;
        toDeleteIdx=nameParamIdx+7;

        varName=maskObj.Parameters(nameParamIdx).Value;
        varHeader=['PLCVar',varName];



        varMapping=get_param(varSSBlock,[varHeader,'Mapping']);
        visibilityInfo=slplc.utils.getVarPropertyVisibility(varMapping,varMapping);
        maskObj.Parameters(portIndexIdx).Visible=visibilityInfo.PortIndex;

        if~plcfeature('PLCLadderDataInference')
            maskObj.Parameters(mappingIdx).ReadOnly='on';
            maskObj.Parameters(addressIdx).ReadOnly='on';
            maskObj.Parameters(portIndexIdx).ReadOnly='on';
            maskObj.Parameters(dataTypeIdx).ReadOnly='on';
            maskObj.Parameters(dataSizeIdx).ReadOnly='on';
            maskObj.Parameters(initValueIdx).ReadOnly='on';
            maskObj.Parameters(toDeleteIdx).ReadOnly='on';
            continue
        end
    end
end
