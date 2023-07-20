function refreshControllerVarSS(controllerBlock)



    if strcmpi(slplc.utils.getModelGenerationStatus(controllerBlock),...
        'ModelUpdate')
        return
    end

    [varSSVarList,varSSBlock]=slplc.utils.getVariableList(controllerBlock,'VariableSS');
    if isempty(varSSBlock)

        return
    end

    varList=slplc.utils.getVariableList(controllerBlock);
    if isequal(varList,varSSVarList),return,end

    if isempty(varList)&&~isempty(varSSVarList)

        maskObj=Simulink.Mask.get(varSSBlock);
        maskObj.removeAllParameters;
        slplc.utils.setVariableList(controllerBlock,varList,'VariableSS');
        return
    end

    varNames={};
    if~isempty(varList),varNames={varList.Name};end

    varSSVarNames={};
    if~isempty(varSSVarList),varSSVarNames={varSSVarList.Name};end

    maskObj=Simulink.Mask.get(varSSBlock);
    if isequal(varNames,varSSVarNames)

        for varCount=1:numel(varList)
            varInfo=varList(varCount);
            varSSVarInfo=varSSVarList(varCount);
            if isequal(varInfo,varSSVarInfo)
                continue
            end
            update_varSS_params(maskObj,varInfo,varSSVarInfo)
        end
    else

        maskObj.removeAllParameters;
        for varCount=1:numel(varList)
            add_varSS_params(maskObj,varList(varCount),varCount);
        end
        updatePortIndexOnMask(maskObj,varList);
    end

    slplc.utils.setVariableList(controllerBlock,varList,'VariableSS');
end

function update_varSS_params(maskObj,varInfo,varSSVarInfo)
    updateVarFieldNames={'Address','PortType','PortIndex','DataType','Size','InitialValue','IsUsed'};
    for varFieldNameCount=1:numel(updateVarFieldNames)
        curentFieldName=updateVarFieldNames{varFieldNameCount};
        if isequal(varInfo.(curentFieldName),varSSVarInfo.(curentFieldName))
            continue
        end
        if strcmpi(curentFieldName,'PortType')
            varParamName=['PLCVar',varInfo.Name,'Mapping'];
            maskParam=maskObj.getParameter(varParamName);
            maskParam.Value=getMappingStr();
        elseif strcmpi(curentFieldName,'IsUsed')
            varParamName=['PLCVar',varInfo.Name,'ToDelete'];
            maskParam=maskObj.getParameter(varParamName);
            maskParam.Visible=slplc.utils.logical2OnOff(~varInfo.IsUsed);
        else
            varParamName=['PLCVar',varInfo.Name,curentFieldName];
            maskParam=maskObj.getParameter(varParamName);
            originalReadOnlySetting=maskParam.ReadOnly;
            maskParam.ReadOnly='off';
            maskParam.Enabled='on';
            maskParam.Value=slplc.utils.logical2OnOff(varInfo.(curentFieldName));
            if strcmpi(curentFieldName,'DataType')
                maskParam.ReadOnly=slplc.utils.logical2OnOff(varInfo.IsFBInstance);
            else
                maskParam.ReadOnly=originalReadOnlySetting;
            end
        end
    end
end

function add_varSS_params(maskObj,varInfo,varIdx)
    UIVarPropertymNames={'Name','Address','Mapping','PortIndex','DataType','Size','InitialValue','ToDelete'};
    propertyNumInUI=numel(UIVarPropertymNames);
    containerName='PLCBlockTitle';

    varName=varInfo.Name;
    if~isvarname(varName)
        error('slplc:invalidOperandTag',...
        'Operand variable %s is not valid',varName);
    end
    varParamStr=['PLCVar',varName];

    maskObj.addParameter(...
    'Type','edit',...
    'Name',[varParamStr,'Name'],...
    'Value',varName,...
    'Evaluate','off',...
    'Tunable','off',...
    'ReadOnly','on',...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'Name']);
    dlg.Row='new';


    maskObj.addParameter(...
    'Type','edit',...
    'Name',[varParamStr,'Address'],...
    'Value',varInfo.Address,...
    'Evaluate','off',...
    'Tunable','off',...
    'Enabled','off',...
    'Visible','off',...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'Address']);
    dlg.Row='current';
    dlg.HorizontalStretch='off';

    mappingOptions={'Global Variable';'Input Symbol';'Output Symbol'};
    mappingValue=getMappingStr(varInfo.PortType);
    maskObj.addParameter(...
    'Type','popup',...
    'TypeOptions',mappingOptions,...
    'Name',[varParamStr,'Mapping'],...
    'Value',mappingValue,...
    'Callback','slplc.callbacks.updateControllerVarSS(gcb);',...
    'Evaluate','off',...
    'Tunable','off',...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'Mapping']);
    dlg.Row='current';

    visibilityInfo=slplc.utils.getVarPropertyVisibility(mappingValue,mappingValue);

    portOptions=transpose(strsplit(num2str(1:str2double(varInfo.PortIndex))));
    maskObj.addParameter(...
    'Type','popup',...
    'TypeOptions',portOptions,...
    'Name',[varParamStr,'PortIndex'],...
    'Value',varInfo.PortIndex,...
    'Visible',visibilityInfo.PortIndex,...
    'Evaluate','off',...
    'Tunable','off',...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'PortIndex']);
    dlg.Row='current';

    dtIdxStr=num2str((varIdx-1)*propertyNumInUI+5);
    typeStr=sprintf('unidt({a=%s|||}{b=boolean|int8|uint8|int16|uint16|int32|uint32|single|double}{u=enum|bus})',dtIdxStr);
    maskObj.addParameter(...
    'Type',typeStr,...
    'Name',[varParamStr,'DataType'],...
    'Value',varInfo.DataType,...
    'Tunable','off',...
    'ReadOnly',slplc.utils.logical2OnOff(varInfo.IsFBInstance),...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'DataType']);
    dlg.Row='current';

    maskObj.addParameter(...
    'Type','edit',...
    'Name',[varParamStr,'Size'],...
    'Value',varInfo.Size,...
    'Evaluate','off',...
    'Tunable','off',...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'Size']);
    dlg.Row='current';

    maskObj.addParameter(...
    'Type','edit',...
    'Name',[varParamStr,'InitialValue'],...
    'Value',varInfo.InitialValue,...
    'Evaluate','off',...
    'Tunable','off',...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'InitialValue']);
    dlg.Row='current';

    maskObj.addParameter(...
    'Type','checkbox',...
    'Name',[varParamStr,'ToDelete'],...
    'Value','off',...
    'Evaluate','off',...
    'Tunable','off',...
    'Visible',slplc.utils.logical2OnOff(~varInfo.IsUsed),...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'ToDelete']);
    dlg.Row='current';

end

function updatePortIndexOnMask(maskObj,varList)
    portTypeOptions=transpose(strsplit(num2str(1:numel(varList))));
    for varCount=1:numel(varList)
        varName=varList(varCount).Name;
        varParamStr=['PLCVar',varName];
        portParam=maskObj.getParameter([varParamStr,'PortIndex']);
        portParam.TypeOptions=portTypeOptions;
    end
end

function mappingStr=getMappingStr(portType)
    if strcmpi(portType,'inport')
        mappingStr='Input Symbol';
    elseif strcmpi(portType,'outport')
        mappingStr='Output Symbol';
    else
        mappingStr='Global Variable';
    end
end
