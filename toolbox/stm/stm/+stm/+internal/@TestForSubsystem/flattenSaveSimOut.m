function emptySigs=flattenSaveSimOut(obj,outputData,updateScenario)




























    emptySigs=[];
    if any(strcmp(outputData.who,'sltlogsout'))
        loggedData=outputData.get('sltlogsout');
    else
        loggedData.numElements=0;
    end
    dataToWrite=(loggedData.numElements~=0);


    for m=1:loggedData.numElements
        data=loggedData.get(m);
        sigName=data.Name;


        sigHier=char;
        if obj.sigHierInfo.isKey(sigName)
            sigHier=obj.sigHierInfo(sigName);
        end
        signalToPortConnectionInfo=[];
        if obj.sigNameBlkInfoMap.isKey(sigName)

            signalToPortConnectionInfo=obj.sigNameBlkInfoMap(sigName);
        end


        for k=1:numel(signalToPortConnectionInfo)
            connectedPortInfo=signalToPortConnectionInfo(k);
            copyOfSigData=data;
            simSaver=obj.simOutSaver(connectedPortInfo.ComponentIndex);
            if strcmp(connectedPortInfo.DatasetType,'outputs')
                if strcmp(connectedPortInfo.PortType,'goto')
                    copyOfSigData.Name=connectedPortInfo.GotoBlockName;
                end
                simSaver.addElement(copyOfSigData,connectedPortInfo.DatasetType);
            else

                copyOfSigData.Values=fixBusElementNames(copyOfSigData.Values,sigHier,copyOfSigData.Name,obj.subModel(connectedPortInfo.ComponentIndex));
                expandVirtualBusAndSetVariable(simSaver,connectedPortInfo.DatasetType,connectedPortInfo.sigBlkNameMap,copyOfSigData,sigHier);
            end








        end
    end


    if any(strcmp('sltdsmout',outputData.who()))
        dsmData=outputData.get('sltdsmout');
    else
        dsmData.numElements=0;
    end

    numElements=dsmData.numElements;
    if~dataToWrite
        dataToWrite=numElements>0;
    end

    for i=1:numElements
        data=dsmData.get(i);
        sigName=data.Name;
        dsmConnectivityInfo=[];
        if obj.dataStoreLoggingInfo.isKey(sigName)
            dsmConnectivityInfo=obj.dataStoreLoggingInfo(sigName);





            data.Name=dsmConnectivityInfo(1).DataStoreName;
        end
        for dsmConnection=dsmConnectivityInfo
            if isempty(data.Values)
                emptySigs=[emptySigs,string(sigName)];%#ok<AGROW>
            else
                simSaver=obj.simOutSaver(dsmConnection.ComponentIndex);
                simSaver.addElementAsSignal(data,dsmConnection.DatasetType);
            end
        end
    end

    obj=saveSimSaverDSToFilesForAllCUTs(obj,updateScenario,dataToWrite);
end

function fixValues=fixBusElementNames(values,sigHierInfo,name,model)



    if isempty(sigHierInfo)||isempty(sigHierInfo.Children)
        fixValues=values;
        if~isempty(fixValues)&&isa(fixValues,'timeseries')
            fixValues.Name=name;
        end
    else
        fixValues=[];
        busElements=fieldnames(values);

        if isempty(sigHierInfo.BusObject)
            for i=1:length(busElements)
                valuesElement=values.(busElements{i});
                fixValues.(busElements{i})=fixBusElementNames(valuesElement,sigHierInfo.Children(i),busElements{i},model);
            end
        else
            busObj=getBusObject(model,sigHierInfo.BusObject);
            busObjElements=busObj.Elements;
            assert(length(busObjElements)==length(busElements));
            for i=1:length(busElements)
                valuesElement=values.(busElements{i});
                fixValues.(busObjElements(i).Name)=fixBusElementNames(valuesElement,sigHierInfo.Children(i),busObjElements(i).Name,model);
            end
        end
    end
end


function mapStr=expandVirtualBusAndSetVariable(saverObj,type,sigBlkNameMap,data,sigHierInfo)
    mapStr='';
    if isempty(sigHierInfo)||isempty(sigHierInfo.Children)||~isempty(sigHierInfo.BusObject)
        if(strcmp(type,'inputs')&&isKey(sigBlkNameMap,data.Name))
            blkNames=sigBlkNameMap(data.Name);
            data.Name=blkNames;
        end
        if~isstruct(data.Values)&&~isempty(data.Values)&&isa(data.Values,'timeseries')
            data.Values.Name=data.Name;
        end
        saverObj.addElement(data,type);
        mapStr=data.Name;
    else
        assert(isstruct(data.Values));
        busElements=fieldnames(data.Values);
        assert(length(busElements)==length(sigHierInfo.Children));
        for i=1:length(busElements)
            busElementData=data;
            busElementName=sprintf('%s_%d',data.Name,i);
            if strcmp(type,'inputs')
                fltnBusElementName=sprintf('%s_%s',sigBlkNameMap(data.Name),busElements{i});

                sigBlkNameMap(busElementName)=fltnBusElementName;
            end
            busElementData.Name=busElementName;
            busElementData.Values=data.Values.(busElements{i});
            if i>1
                mapStr=[mapStr,','];%#ok<AGROW>
            end
            mapStr=[mapStr,expandVirtualBusAndSetVariable(saverObj,type,sigBlkNameMap,busElementData,sigHierInfo.Children(i))];%#ok<AGROW>
        end
    end
end

function varValue=getBusObject(model,varName)
    varObj=Simulink.findVars(model,'Name',varName,...
    'SearchMethod','cached');
    varStruct=struct('Name',varObj.Name,'SourceType',varObj.SourceType,...
    'Source',varObj.Source,'ModelReference','');


    if strcmp(varStruct.SourceType,'data dictionary')
        varStruct.SourceType=varStruct.Source;
    end
    rdrObj=stm.internal.VariableReader.getReader(varStruct,model);
    varValue=rdrObj.getCurrentValue;
end

function obj=saveSimSaverDSToFilesForAllCUTs(obj,updateScenario,dataToWrite)


    obj.hasInputs=zeros(obj.numOfComps,1);
    obj.hasBaseline=zeros(obj.numOfComps,1);
    obj.activeScenario=strings(obj.numOfComps,1);
    assert(iscell(obj.harnessInfo)&&numel(obj.harnessInfo)==obj.numOfComps,"harness Info array not the right size.");

    for k=1:obj.numOfComps
        try
            if obj.proceedToNextStep(k)
                handle=get_param(obj.subsys(k),'Handle');
                simSaver=obj.simOutSaver(k);
                shouldLoadHarness=~isempty(obj.harnessInfo{k});
                needToCloseHarness=shouldLoadHarness;





                if shouldLoadHarness
                    preserve_dirty=Simulink.PreserveDirtyFlag(get_param(obj.subModel(k),'Handle'),'blockDiagram');
                    Simulink.harness.load(handle,obj.harnessInfo{k}.name);
                end


                [obj.hasInputs(k),obj.hasBaseline(k),obj.activeScenario(k)]=...
                simSaver.save(obj.location1(k).char,obj.location2(k).char,updateScenario);

                if needToCloseHarness
                    if obj.harnessInfo{k}.saveExternally
                        save_system(obj.harnessInfo{k}.name);
                        close_system(obj.harnessInfo{k}.name,0);
                        clear preserve_dirty;
                    else
                        clear preserve_dirty;
                        close_system(obj.harnessInfo{k}.name,0);
                    end
                    needToCloseHarness=false;
                end
                if(~obj.hasInputs(k)&&~obj.hasBaseline(k))&&dataToWrite
                    warning(message('stm:TestForSubsystem:NoDataWrittenForInputOrOutputs'));
                end
            end
        catch me






            if needToCloseHarness
                if obj.harnessInfo{k}.saveExternally
                    save_system(obj.harnessInfo{k}.name);
                end
                handle=get_param(obj.subsys(k),'Handle');
                stm.internal.TestForSubsystem.closeAndDeleteHarness(handle,obj.harnessInfo{k}.name);
                handle=get_param(obj.subsys(k),'Handle');
                clear preserve_dirty;
            end
            obj.populateErrorContainer(me,k);
        end
    end
end

