function refreshPOUVarSS(pouBlock)



    if strcmpi(slplc.utils.getModelGenerationStatus(pouBlock),...
        'ModelUpdate')
        return
    end

    [varSSVarList,varSSBlock]=slplc.utils.getVariableList(pouBlock,'VariableSS');
    if isempty(varSSBlock)

        return
    end

    varList=slplc.utils.getVariableList(pouBlock);

    if isequal(varList,varSSVarList),return,end

    if isempty(varList)&&~isempty(varSSVarList)

        maskObj=Simulink.Mask.get(varSSBlock);
        maskObj.removeAllParameters;
        slplc.utils.setVariableList(pouBlock,varList,'VariableSS');
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

        pouType=slplc.utils.getParam(pouBlock,'PLCPOUType');
        if strcmpi(pouType,'Function Block')
            defaultPortStartIdx=2;
            scopeOptions={'Local';'Input';'Output';'InOut'};
        else

            defaultPortStartIdx=1;
            scopeOptions={'Local';'External'};
        end
        maskObj.removeAllParameters;
        for varCount=1:numel(varList)
            add_varSS_params(maskObj,varList(varCount),varCount,defaultPortStartIdx,scopeOptions);
        end
        updatePortIndexOnMask(maskObj,varList,defaultPortStartIdx);
    end

    slplc.utils.setVariableList(pouBlock,varList,'VariableSS');
end

function update_varSS_params(maskObj,varInfo,varSSVarInfo)
    updateVarFieldNames={'Scope','PortType','PortIndex','DataType','Size','InitialValue','IsUsed'};
    for varFieldNameCount=1:numel(updateVarFieldNames)
        curentFieldName=updateVarFieldNames{varFieldNameCount};
        if isequal(varInfo.(curentFieldName),varSSVarInfo.(curentFieldName))
            continue
        end
        if strcmpi(curentFieldName,'IsUsed')
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

function add_varSS_params(maskObj,varInfo,varIdx,defaultPortStartIdx,scopeOptions)
    isProgramVarSS=false;
    if defaultPortStartIdx==1
        isProgramVarSS=true;
    end

    UIVarPropertymNames={'Name','Scope','PortType','PortIndex','DataType','Size','InitialValue','ToDelete'};
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
    'Type','popup',...
    'TypeOptions',scopeOptions,...
    'Name',[varParamStr,'Scope'],...
    'Value',varInfo.Scope,...
    'Callback','slplc.callbacks.updatePOUVarSS(gcb);',...
    'Evaluate','off',...
    'Tunable','off',...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'Scope']);
    dlg.Row='current';

    visibilityInfo=slplc.utils.getVarPropertyVisibility(varInfo.Scope,varInfo.PortType);

    if isProgramVarSS
        isHidden='on';
        isHorizontalStretch='off';
    else
        isHidden='off';
        isHorizontalStretch='on';
    end

    portTypeOptions={'Hidden';'Inport';'Outport'};
    maskObj.addParameter(...
    'Type','popup',...
    'TypeOptions',portTypeOptions,...
    'Name',[varParamStr,'PortType'],...
    'Value',varInfo.PortType,...
    'Visible',visibilityInfo.PortType,...
    'Callback','slplc.callbacks.updatePOUVarSS(gcb);',...
    'Evaluate','off',...
    'Tunable','off',...
    'Hidden',isHidden,...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'PortType']);
    dlg.Row='current';
    dlg.HorizontalStretch=isHorizontalStretch;

    startIdx=defaultPortStartIdx;
    if ismember(varName,{'EnableIn','EnableOut'})
        startIdx=1;
    end
    portIndexOptions=transpose(strsplit(num2str(startIdx:str2double(varInfo.PortIndex))));
    maskObj.addParameter(...
    'Type','popup',...
    'TypeOptions',portIndexOptions,...
    'Name',[varParamStr,'PortIndex'],...
    'Value',varInfo.PortIndex,...
    'Visible',visibilityInfo.PortIndex,...
    'Evaluate','off',...
    'Tunable','off',...
    'Hidden',isHidden,...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'PortIndex']);
    dlg.Row='current';
    dlg.HorizontalStretch=isHorizontalStretch;

    dtIdxStr=num2str((varIdx-1)*propertyNumInUI+5);
    typeStr=sprintf('unidt({a=%s|||}{b=boolean|int8|uint8|int16|uint16|int32|uint32|single|double}{u=enum|bus})',dtIdxStr);
    maskObj.addParameter(...
    'Type',typeStr,...
    'Name',[varParamStr,'DataType'],...
    'Value',varInfo.DataType,...
    'Visible',visibilityInfo.DataType,...
    'Tunable','off',...
    'ReadOnly',slplc.utils.logical2OnOff(varInfo.IsFBInstance),...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'DataType']);
    dlg.Row='current';

    maskObj.addParameter(...
    'Type','edit',...
    'Name',[varParamStr,'Size'],...
    'Value',varInfo.Size,...
    'Visible',visibilityInfo.DataSize,...
    'Evaluate','off',...
    'Tunable','off',...
    'Container',containerName);
    dlg=maskObj.getDialogControl([varParamStr,'Size']);
    dlg.Row='current';

    maskObj.addParameter(...
    'Type','edit',...
    'Name',[varParamStr,'InitialValue'],...
    'Value',varInfo.InitialValue,...
    'Visible',visibilityInfo.InitialValue,...
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

function updatePortIndexOnMask(maskObj,varList,defaultPortStartIdx)
    for varCount=1:numel(varList)
        varName=varList(varCount).Name;
        startIdx=defaultPortStartIdx;
        if ismember(varName,{'EnableIn','EnableOut'})
            startIdx=1;
        end
        portTypeOptions=transpose(strsplit(num2str(startIdx:numel(varList))));
        portParam=maskObj.getParameter(['PLCVar',varName,'PortIndex']);
        portParam.TypeOptions=portTypeOptions;
    end
end


