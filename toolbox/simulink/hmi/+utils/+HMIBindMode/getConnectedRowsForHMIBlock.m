

function[connectedRows,updateDiagramNeeded]=getConnectedRowsForHMIBlock(HMIBlockHandle,modelName)




    orig_state=warning('off','all');
    oc=onCleanup(@()warning(orig_state));

    isCoreWebBlock=get_param(HMIBlockHandle,'isCoreWebBlock');
    if(strcmp(isCoreWebBlock,'on'))
        Simulink.HMI.applyRebindingRules(HMIBlockHandle);
    else
        modelHandle=get_param(modelName,'handle');
        simStatus=get_param(modelName,'SimulationStatus');
        webhmi=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
        if~isempty(webhmi)&&~webhmi.IsInModelReference&&strcmpi(simStatus,'stopped')
            widgetId=utils.getInstanceId(get_param(HMIBlockHandle,'Object'));
            webhmi.applyRebindingRulesForWidget(widgetId);
        end
    end

    widgetBindingType=utils.getWidgetBindingType(HMIBlockHandle);
    if(strcmp(widgetBindingType,'ParameterOrVariable'))
        boundElemData=utils.HMIBindMode.getBoundElementInfo(HMIBlockHandle,modelName);
        if(numel(boundElemData)==0)
            return;
        end

        blockNames=boundElemData{1,4};
        blockHandles=boundElemData{1,5};
        allTunableParams=boundElemData{1,6};
        allVarWorkspaceType=boundElemData{1,7};
        allIsParams=boundElemData{1,11};
        isUpdateDiagramButtonRequired=boundElemData{1,13};
        allElements=boundElemData{1,15};
        allIsComposite=boundElemData{1,16};


        totalNumRows=0;
        for idx=1:numel(blockNames)
            tunableParams=allTunableParams{idx};
            for k=1:numel(tunableParams)
                totalNumRows=totalNumRows+1;
            end
        end


        connectionStatus=cell(1,totalNumRows);
        bindableType=cell(1,totalNumRows);
        bindableName=cell(1,totalNumRows);
        paramName=cell(1,totalNumRows);
        blockHandle=cell(1,totalNumRows);
        varWorkspaceType=cell(1,totalNumRows);
        elements=cell(1,totalNumRows);
        isComposite=cell(1,totalNumRows);



        rowCount=1;
        for idx=1:numel(blockNames)
            tunableParams=allTunableParams{idx};
            isParams=allIsParams{idx};
            workspaceType=allVarWorkspaceType{idx};
            blockElements=allElements{idx};
            blockIsComponsite=allIsComposite{idx};
            for k=1:numel(tunableParams)
                blockHandle{rowCount}=blockHandles{idx};
                connectionStatus{rowCount}=true;
                if(isParams{k})
                    bindableType{rowCount}=BindMode.BindableTypeEnum.SLPARAMETER;
                    bindableName{rowCount}=[blockNames{idx},':',tunableParams{k}];
                    paramName{rowCount}=tunableParams{k};
                    varWorkspaceType{rowCount}='';
                else
                    bindableType{rowCount}=BindMode.BindableTypeEnum.VARIABLE;
                    bindableName{rowCount}=tunableParams{k};
                    paramName{rowCount}=tunableParams{k};
                    varWorkspaceType{rowCount}=workspaceType{k};
                end
                elements{rowCount}=blockElements{k};
                isComposite{rowCount}=blockIsComponsite{k};
                rowCount=rowCount+1;
            end
        end


        numRows=numel(connectionStatus);
        boundRows=cell(1,numRows);
        for idx=1:numRows
            metaDataStruct.name=paramName{idx};
            metaDataStruct.blockPathStr=getfullname(str2double(blockHandle{idx}));
            metaDataStruct.hierarchicalPathArr=BindMode.utils.getHierarchicalPathUsingBindModeSource(metaDataStruct.blockPathStr);
            metaDataStruct.enableInputField=logical(isComposite{idx});
            metaDataStruct.inputValue=elements{idx};
            if(bindableType{idx}==BindMode.BindableTypeEnum.SLPARAMETER)
                metaData=BindMode.utils.getBindableMetaDataFromStruct(BindMode.BindableTypeEnum.SLPARAMETER,metaDataStruct);
                boundRows{idx}=BindMode.BindableRow(connectionStatus{idx},BindMode.BindableTypeEnum.SLPARAMETER,...
                bindableName{idx},metaData);
            elseif(bindableType{idx}==BindMode.BindableTypeEnum.VARIABLE)
                metaDataStruct.workspaceTypeStr=varWorkspaceType{idx};
                metaData=BindMode.utils.getBindableMetaDataFromStruct(BindMode.BindableTypeEnum.VARIABLE,metaDataStruct);
                boundRows{idx}=BindMode.BindableRow(connectionStatus{idx},BindMode.BindableTypeEnum.VARIABLE,...
                bindableName{idx},metaData);
            end
        end
        updateDiagramNeeded=isUpdateDiagramButtonRequired;
        connectedRows=boundRows;

    elseif(strcmp(widgetBindingType,'SingleSignal')||...
        strcmp(widgetBindingType,'MultipleSignal'))
        bindings=get_param(HMIBlockHandle,'Binding');
        if(numel(bindings)==1&&~iscell(bindings))
            bindings={bindings};
        end
        boundRows=cell(1,numel(bindings));
        for idx=1:numel(bindings)
            binding=bindings{idx};
            if~utils.isValidBinding(binding)

                boundRows(idx)=[];
                continue
            end
            if(Simulink.HMI.SignalSpecification.isSFSignal(binding))

                if strcmp(binding.DomainType_,'sf_chart')
                    chartHandle=Simulink.ID.getHandle(binding.SID_);
                    objId=sfprivate('block2chart',chartHandle);
                    obj=sf('IdToHandle',objId);
                    objSid=binding.SID_;
                    bindableType=BindMode.BindableTypeEnum.SFCHART;
                    metaDataStruct.name=obj.Name;
                    activity=binding.DomainParams_.Activity;
                elseif strcmp(binding.DomainType_,'sf_data')
                    objSid=[binding.SID_,':',binding.DomainParams_.SSID];
                    obj=Simulink.ID.getHandle(objSid);
                    bindableType=BindMode.BindableTypeEnum.SFDATA;
                    metaDataStruct.name=obj.Name;
                    metaDataStruct.scope=obj.Scope;
                    activity=binding.DomainParams_.Activity;
                else
                    objSid=[binding.SID_,':',binding.DomainParams_.SSID];
                    obj=Simulink.ID.getHandle(objSid);
                    bindableType=BindMode.BindableTypeEnum.SFSTATE;
                    metaDataStruct.name=obj.LoggingInfo.LoggingName;
                    activity=binding.DomainParams_.Activity;
                end


                if strcmp(activity,'Self')
                    activity='self activity';
                elseif strcmp(activity,'Child')
                    activity='child activity';
                elseif strcmp(activity,'Leaf')
                    activity='leaf activity';
                end
                metaDataStruct.activityType=activity;
                metaDataStruct.sid=objSid;
                metaDataStruct.localPath=obj.Path;
                metaDataStruct.hierarchicalPathArr=BindMode.utils.getHierarchicalPathUsingBindModeSource(metaDataStruct.localPath);
                metaData=BindMode.utils.getBindableMetaDataFromStruct(bindableType,metaDataStruct);
                boundRows{idx}=BindMode.BindableRow(true,bindableType,metaDataStruct.name,metaData);
            else

                metaDataStruct.name=utils.getBoundSignalDisplayName(binding);
                metaDataStruct.blockPathStr=binding.BlockPath.getBlock(1);
                metaDataStruct.hierarchicalPathArr=BindMode.utils.getHierarchicalPathUsingBindModeSource(metaDataStruct.blockPathStr);
                metaDataStruct.outputPortNumber=binding.OutputPortIndex;
                metaData=BindMode.utils.getBindableMetaDataFromStruct(BindMode.BindableTypeEnum.SLSIGNAL,metaDataStruct);
                boundRows{idx}=BindMode.BindableRow(true,BindMode.BindableTypeEnum.SLSIGNAL,metaDataStruct.name,metaData);
            end
        end
        updateDiagramNeeded=false;
        connectedRows=boundRows;
    else
        updateDiagramNeeded=false;
        connectedRows={};
    end
end