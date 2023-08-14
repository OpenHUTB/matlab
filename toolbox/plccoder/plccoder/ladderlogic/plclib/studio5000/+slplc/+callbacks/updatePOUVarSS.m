function updatePOUVarSS(varSSBlock)




    if~strcmpi(get_param(bdroot(varSSBlock),'SimulationStatus'),'stopped')
        return
    end

    maskObj=Simulink.Mask.get(varSSBlock);
    propertyNum=8;
    varNum=round(numel(maskObj.Parameters)/propertyNum);

    for varCount=1:varNum
        nameParamIdx=(varCount-1)*propertyNum+1;

        scopeIdx=nameParamIdx+1;
        portTypeIdx=nameParamIdx+2;
        portIndexIdx=nameParamIdx+3;
        dataTypeIdx=nameParamIdx+4;
        dataSizeIdx=nameParamIdx+5;
        initValueIdx=nameParamIdx+6;
        toDeleteIdx=nameParamIdx+7;

        varName=maskObj.Parameters(nameParamIdx).Value;
        varHeader=['PLCVar',varName];


        varScope=get_param(varSSBlock,[varHeader,'Scope']);
        varPortType=get_param(varSSBlock,[varHeader,'PortType']);
        visibilityInfo=slplc.utils.getVarPropertyVisibility(varScope,varPortType);
        maskObj.Parameters(portTypeIdx).Visible=visibilityInfo.PortType;
        maskObj.Parameters(portIndexIdx).Visible=visibilityInfo.PortIndex;
        maskObj.Parameters(dataTypeIdx).Visible=visibilityInfo.DataType;
        maskObj.Parameters(dataSizeIdx).Visible=visibilityInfo.DataSize;
        maskObj.Parameters(initValueIdx).Visible=visibilityInfo.InitialValue;

        if~plcfeature('PLCLadderDataInference')||...
            strcmp(varName,'EnableIn')||strcmp(varName,'EnableOut')
            maskObj.Parameters(scopeIdx).ReadOnly='on';
            maskObj.Parameters(portTypeIdx).ReadOnly='on';
            maskObj.Parameters(portIndexIdx).ReadOnly='on';
            maskObj.Parameters(dataTypeIdx).ReadOnly='on';
            maskObj.Parameters(dataSizeIdx).ReadOnly='on';
            maskObj.Parameters(initValueIdx).ReadOnly='on';
            maskObj.Parameters(toDeleteIdx).ReadOnly='on';
            continue
        end
    end
end


