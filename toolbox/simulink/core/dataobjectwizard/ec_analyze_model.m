function[dataList,rejected,foundData]=ec_analyze_model(modelName,DialogFlag)

























    if(nargin==1)
        DialogFlag=false;
    end

    rejected=emptyStruct;
    init_flag=false;
    numWaitbarSteps=10;


    restoreDirtyFlag=Simulink.PreserveDirtyFlag(modelName);
    restoreConfigSetRef=[];
    restoreBlockReduction=[];
    restoreEnableReplacementTypes=[];

    try
        progressBar=waitbar(0,DAStudio.message('Simulink:dow:AnalyzingModel'));


        cs=getActiveConfigSet(modelName);
        if isa(cs,'Simulink.ConfigSetRef')
            originActiveCSRefName=cs.Name;

            [activeCSName,namelistOfOriginCS]=...
            setActiveConfigSetFromConfigSetRef(modelName,cs);
            restoreConfigSetRef=onCleanup(@()restoreOriginalConfigSetRef(modelName,activeCSName,originActiveCSRefName,namelistOfOriginCS));
            cs=getActiveConfigSet(modelName);
        end


        i_waitbar(1/numWaitbarSteps,progressBar);


        refWSVars=get_param(modelName,'ReferencedWSVars');


        modelObject=get_param(modelName,'Object');
        restoreBlockReduction=configset.internal.util.TemporarySetParam(cs,'BlockReduction','off','Enable','on');

        if strcmp(get_param(cs,'IsERTTarget'),'on')
            restoreEnableReplacementTypes=configset.internal.util.TemporarySetParam(cs,'EnableUserReplacementTypes','off','Enable','on');
        end
        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

        update_diagram(modelName);

        init_flag=true;


        i_waitbar(2/numWaitbarSteps,progressBar);


        [signalList,invalidSig,foundSig,rejectedDelta]=get_model_SignalList(modelName);
        rejected=[rejected,rejectedDelta];


        i_waitbar(3/numWaitbarSteps,progressBar);


        [stateList,invalidState,foundState,rejectedDelta]=get_model_StateList(modelName);
        rejected=[rejected,rejectedDelta];


        i_waitbar(4/numWaitbarSteps,progressBar);


        [dataStoreList,invalidDataStore,foundDataStore,rejectedDelta]=get_model_DataStoreList(modelName);
        rejected=[rejected,rejectedDelta];


        i_waitbar(5/numWaitbarSteps,progressBar);


        [sfdataList,invalidSFData,foundSFData,rejectedDelta]=get_Stateflow_LocalDataList(modelName);
        rejected=[rejected,rejectedDelta];


        i_waitbar(6/numWaitbarSteps,progressBar);


        allSignals=[signalList,stateList,dataStoreList,sfdataList];
        invalidData=[invalidSig,invalidState,invalidDataStore,invalidSFData];
        foundData=[foundSig,foundState,foundDataStore,foundSFData];

        if~isempty(allSignals)

            if~isempty(invalidData)

                for q=length(allSignals):-1:1
                    if ismember(allSignals{q}.name,invalidData)
                        allSignals(q)=[];
                    end
                end
            end


            [allSignals,invalidDelta,rejectedDelta]=validate_all_signals(allSignals);
            invalidData=[invalidData,invalidDelta];
            rejected=[rejected,rejectedDelta];


            if strcmp(get_param(modelName,'SignalResolutionControl'),'None')
                [allSignals,rejectedDelta]=rejectSignals(allSignals);
                invalidData=[invalidData,{rejectedDelta(:).Name}];
                rejected=[rejected,rejectedDelta];
            end
        end


        assert(isequal(invalidData,{rejected(:).Name}));


        i_waitbar(7/numWaitbarSteps,progressBar);


        [allParams,invalidParam,foundParam,rejectedDelta]=get_model_ParamList(modelName,refWSVars);
        rejected=[rejected,rejectedDelta];


        assert(isequal(invalidParam,{rejectedDelta(:).Name}));


        i_waitbar(8/numWaitbarSteps,progressBar);


        dataList=[allSignals,allParams];
        invalidData=[invalidData,invalidParam];
        foundData=[foundData,foundParam];

        foundData=unique(foundData);


        assert(isequal(invalidData,{rejected(:).Name}));


        i_waitbar(9/numWaitbarSteps,progressBar);


        errorObject=[];

    catch e
        errorObject=MSLException(get_param(modelName,'Handle'),'Simulink:dow:AnalyzingModelFails',...
        DAStudio.message('Simulink:dow:AnalyzingModelFails'));
        errorObject=errorObject.addCause(e);


        dataList=-1;
        foundData={};
        rejected=emptyStruct;
    end


    if init_flag
        modelObject.term;
    end

    delete(restoreEnableReplacementTypes);
    delete(restoreBlockReduction);
    delete(restoreConfigSetRef);
    delete(restoreDirtyFlag);


    i_waitbar(1,progressBar);
    if ishghandle(progressBar);close(progressBar);end


    if~isempty(errorObject)
        if DialogFlag
            err_disp(errorObject);
        else
            throw(errorObject);
        end
    end


    function[activeConfigSetName,namelistOfOriginCS]=setActiveConfigSetFromConfigSetRef(modelName,originActiveCSRef)



        originActiveCSRef.refresh(true);
        csName=originActiveCSRef.WSVarName;
        csVar=originActiveCSRef.getResolvedConfigSetCopy();

        if isa(csVar,'Simulink.ConfigSet')
            namelistOfOriginCS=getConfigSets(modelName);
            copied_cs=attachConfigSetCopy(modelName,csVar,true);
            activeConfigSetName=copied_cs.Name;
            setActiveConfigSet(modelName,activeConfigSetName);
        else
            DAStudio.error('Simulink:ConfigSet:ConfigSetRef_SourceNameNotInBaseWorkspace',...
            originActiveCSRef.Name,csName);
        end


        function restoreOriginalConfigSetRef(modelName,activeCSName,originActiveCSName,namelistOfOriginCS)

            setActiveConfigSet(modelName,originActiveCSName);
            detachConfigSet(modelName,activeCSName);

            assert(isequal(getConfigSets(modelName),namelistOfOriginCS));


            function result=get_reject_struct_name(name,block,datasource)
                if(nargin==2)
                    datasource='State';
                end
                refInfo.datasource=datasource;
                refInfo.reasonID='SignalLabelInvalid';
                refInfo.reason=l_reasonFromID(refInfo.reasonID);
                obj=get_param(block,'Object');
                refInfo.sourceblock=string(obj.getFullName);
                result=struct('Name',name,'Info',refInfo);


                function result=get_reject_struct_sc(name,block,datasource)
                    if(nargin==2)
                        datasource='State';
                    end
                    refInfo.datasource=datasource;
                    switch datasource
                    case 'State'
                        refInfo.reasonID='StateStorageClassSpecified';
                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                    case 'DataStore'
                        refInfo.reasonID='DataStoreStorageClassSpecified';
                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                    otherwise
                        assert(false,'Unexpected data source');
                    end
                    obj=get_param(block,'Object');
                    refInfo.sourceblock=string(obj.getFullName);
                    result=struct('Name',name,'Info',refInfo);


                    function result=get_reject_struct_exists(name,block,datasource)
                        if(nargin==2)
                            datasource='State';
                        end
                        refInfo.datasource=datasource;
                        refInfo.reasonID='SignalLabelMatchesExistingVariable';
                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                        obj=get_param(block,'Object');
                        refInfo.sourceblock=string(obj.getFullName);
                        result=struct('Name',name,'Info',refInfo);


                        function[stateList,invalidList,foundList,rejected]=get_model_StateList(modelName)





























                            stateList={};%#ok
                            invalidList={};
                            foundList={};
                            rejected=emptyStruct;

                            delayBlks=l_find_block_with_state(modelName,'BlockType','UnitDelay');
                            delayBlkList={};
                            for delayIdx=1:length(delayBlks)
                                block=delayBlks{delayIdx};
                                stateName=get_param(block,'StateName');


                                if isempty(stateName)
                                    continue;
                                end


                                if~isValidVarName(stateName,modelName)
                                    invalidList{end+1}=stateName;%#ok
                                    rejected(end+1)=get_reject_struct_name(stateName,block);%#ok
                                    continue;
                                end


                                if~strcmp(get_param(block,'RTWStateStorageClass'),'Auto')
                                    invalidList{end+1}=stateName;%#ok
                                    rejected(end+1)=get_reject_struct_sc(stateName,block);%#ok
                                    continue;
                                end


                                [found,isSignal]=findVariable(stateName,block);
                                if found
                                    if isSignal
                                        foundList{end+1}=stateName;%#ok
                                        continue;
                                    else
                                        invalidList{end+1}=stateName;%#ok
                                        rejected(end+1)=get_reject_struct_exists(stateName,block);%#ok
                                        continue;
                                    end
                                end

                                [type,dims]=get_port_typedims(block);
                                stateInfo.name=stateName;
                                stateInfo.type='Signal';
                                stateInfo.datatype=type;
                                stateInfo.dimensions=dims;
                                stateInfo.initialvalue=get_param(block,'InitialCondition');
                                stateInfo.sampletime=get_param(block,'SampleTime');
                                stateInfo.datasource='State';
                                stateInfo.dataclass='Variable';
                                stateInfo.sourceblock=string(getfullname(block));

                                delayBlkList{end+1}=stateInfo;%#ok
                            end


                            discBlkList={};
                            discBlks=l_find_block_with_state(modelName,...
                            'RegExp','on',...
                            'BlockType','Discrete');

                            for discIdx=1:length(discBlks)
                                block=discBlks{discIdx};
                                dlgProps=get_param(block,'IntrinsicDialogParameters');
                                if~isfield(dlgProps,'StateName')
                                    continue;
                                end
                                stateName=get_param(block,'StateName');


                                if isempty(stateName)
                                    continue;
                                end


                                if~isValidVarName(stateName,modelName)
                                    invalidList{end+1}=stateName;%#ok
                                    rejected(end+1)=get_reject_struct_name(stateName,block);%#ok
                                    continue;
                                end


                                if~strcmp(get_param(block,'RTWStateStorageClass'),'Auto')
                                    invalidList{end+1}=stateName;%#ok
                                    rejected(end+1)=get_reject_struct_sc(stateName,block);%#ok
                                    continue;
                                end


                                [found,isSignal]=findVariable(stateName,block);
                                if found
                                    if isSignal
                                        foundList{end+1}=stateName;%#ok
                                        continue;
                                    else
                                        invalidList{end+1}=stateName;%#ok
                                        rejected(end+1)=get_reject_struct_exists(stateName,block);%#ok
                                        continue;
                                    end
                                end

                                [type,dims]=get_port_typedims(block);
                                stateInfo.name=stateName;
                                stateInfo.type='Signal';
                                stateInfo.datatype=type;
                                stateInfo.dimensions=dims;
                                stateInfo.sampletime=get_param(block,'SampleTime');
                                stateInfo.datasource='State';
                                stateInfo.dataclass='Variable';
                                stateInfo.sourceblock=string(getfullname(block));

                                discBlkList{end+1}=stateInfo;%#ok
                            end

                            memBlkList={};

                            memBlks=l_find_block_with_state(modelName,'BlockType','Memory');

                            for memIdx=1:length(memBlks)
                                block=memBlks{memIdx};
                                stateName=get_param(block,'StateName');


                                if isempty(stateName)
                                    continue;
                                end


                                if~isValidVarName(stateName,modelName)
                                    invalidList{end+1}=stateName;%#ok
                                    rejected(end+1)=get_reject_struct_name(stateName,block);%#ok
                                    continue;
                                end


                                if~strcmp(get_param(block,'RTWStateStorageClass'),'Auto')
                                    invalidList{end+1}=stateName;%#ok
                                    rejected(end+1)=get_reject_struct_sc(stateName,block);%#ok
                                    continue;
                                end


                                [found,isSignal]=findVariable(stateName,block);
                                if found
                                    if isSignal
                                        foundList{end+1}=stateName;%#ok
                                        continue;
                                    else
                                        invalidList{end+1}=stateName;%#ok
                                        rejected(end+1)=get_reject_struct_exists(stateName,block);%#ok
                                        continue;
                                    end
                                end

                                [type,dims]=get_port_typedims(block);
                                stateInfo.name=stateName;
                                stateInfo.type='Signal';
                                stateInfo.datatype=type;
                                stateInfo.dimensions=dims;
                                stateInfo.initialvalue=get_param(block,'InitialCondition');
                                stateInfo.sampletime='-1';
                                stateInfo.datasource='State';
                                stateInfo.dataclass='Variable';
                                stateInfo.sourceblock=string(getfullname(block));

                                memBlkList{end+1}=stateInfo;%#ok
                            end

                            stateList=[delayBlkList,discBlkList,memBlkList];


                            function[type,dimensions]=get_port_typedims(block)
                                typeInfo=get_param(block,'CompiledPortDataTypes');
                                dimsInfo=get_param(block,'CompiledPortDimensions');
                                assert(isscalar(typeInfo.Inport));
                                assert(isequal(typeInfo.Inport,typeInfo.Outport));
                                assert(isequal(dimsInfo.Inport,dimsInfo.Outport));
                                type=typeInfo.Inport{1};
                                dimensions=l_process_port_dimensions(dimsInfo.Inport);


                                function[dataStoreList,invalidList,foundList,rejected]=get_model_DataStoreList(modelName)


















                                    dataStoreList={};
                                    invalidList={};
                                    foundList={};
                                    rejected=emptyStruct;

                                    dataStoreBlks=l_find_block_with_state(modelName,'BlockType','DataStoreMemory');

                                    for dataStoreIdx=1:length(dataStoreBlks)
                                        block=dataStoreBlks{dataStoreIdx};
                                        stateName=get_param(block,'DataStoreName');


                                        if~isValidVarName(stateName,modelName)
                                            invalidList{end+1}=stateName;%#ok
                                            rejected(end+1)=get_reject_struct_name(stateName,block,'DataStore');%#ok
                                            continue;
                                        end


                                        if~strcmp(get_param(block,'RTWStateStorageClass'),'Auto')
                                            invalidList{end+1}=stateName;%#ok
                                            rejected(end+1)=get_reject_struct_sc(stateName,block,'DataStore');%#ok
                                            continue;
                                        end


                                        [found,isSignal]=findVariable(stateName,block);
                                        if found
                                            if isSignal
                                                foundList{end+1}=stateName;%#ok
                                                continue;
                                            else
                                                invalidList{end+1}=stateName;%#ok
                                                rejected(end+1)=get_reject_struct_exists(stateName,block);%#ok
                                                continue;
                                            end
                                        end





                                        dataStoreReadBlks=l_find_block(modelName,...
                                        'BlockType','DataStoreRead',...
                                        'DataStoreName',stateName,...
                                        'DataStoreElements','');
                                        if~isempty(dataStoreReadBlks)

                                            portHandles=get_param(dataStoreReadBlks{1},'PortHandles');
                                            portObj=get_param(portHandles.Outport,'Object');
                                            dType=portObj.CompiledPortDataType;
                                            dimensions=l_process_port_dimensions(portObj.CompiledPortDimensions);
                                        else

                                            dataStoreWriteBlks=l_find_block(modelName,...
                                            'BlockType','DataStoreWrite',...
                                            'DataStoreName',stateName,...
                                            'DataStoreElements','');
                                            if~isempty(dataStoreWriteBlks)

                                                portHandles=get_param(dataStoreWriteBlks{1},'PortHandles');
                                                portObj=get_param(portHandles.Inport,'Object');
                                                dType=portObj.CompiledPortDataType;
                                                dimensions=l_process_port_dimensions(portObj.CompiledPortDimensions);
                                            else



                                                dType=get_param(block,'OutDataTypeStr');
                                                if strcmp(dType,'Inherit: auto')
                                                    dType='double';
                                                end

                                                icValue=slResolve(get_param(block,'InitialValue'),block);
                                                if isvector(icValue)
                                                    dimensions=length(icValue);
                                                else
                                                    dimensions=size(icValue);
                                                end
                                                clear icValue;
                                            end
                                        end

                                        stateInfo.name=stateName;
                                        stateInfo.type='Signal';
                                        stateInfo.datatype=dType;
                                        stateInfo.dimensions=dimensions;
                                        stateInfo.complexity=get_param(block,'SignalType');
                                        stateInfo.initialvalue=get_param(block,'InitialValue');
                                        stateInfo.datasource='DataStore';
                                        stateInfo.dataclass='Variable';
                                        stateInfo.sourceblock=string(getfullname(block));

                                        dataStoreList{end+1}=stateInfo;%#ok
                                    end


                                    dataStoreRWBlks=[l_find_block(modelName,'BlockType','DataStoreRead');
                                    l_find_block(modelName,'BlockType','DataStoreWrite')];
                                    dsmNames=unique([get_param(dataStoreRWBlks,'DataStoreName');...
                                    getStateflowDataStoreMemoryNames(modelName)]);

                                    for idx=1:length(dsmNames)
                                        dataStoreName=dsmNames{idx};

                                        if isempty(l_find_block(modelName,...
                                            'BlockType','DataStoreMemory',...
                                            'DataStoreName',dataStoreName))
                                            [found,isSignal]=findVariable(dataStoreName,modelName);
                                            assert(found&&isSignal);
                                            foundList{end+1}=dataStoreName;%#ok
                                        end
                                    end



                                    function[sfdataList,invalidList,foundList,rejected]=get_Stateflow_LocalDataList(modelName)
















                                        sfdataList={};
                                        invalidList={};
                                        foundList={};
                                        rejected=emptyStruct;


                                        rt=sfroot;
                                        m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',modelName);
                                        if~isempty(m)
                                            charts=m.find('-isa','Stateflow.Chart');
                                            LinkCharts=m.find('-isa','Stateflow.LinkChart');
                                            allCharts=[charts;LinkCharts];
                                            for k=1:length(allCharts)
                                                chart=allCharts(k);
                                                if(chart.isa('Stateflow.LinkChart'))


                                                    chartId=sfprivate('block2chart',chart.Path);
                                                    chart=idToHandle(rt,chartId);
                                                end
                                                data=chart.find('-isa','Stateflow.Data','-and','Scope','Local');
                                                for i=1:length(data)
                                                    sfdataName=data(i).Name;


                                                    if~isValidVarName(sfdataName,modelName)
                                                        invalidList{end+1}=sfdataName;%#ok
                                                        rejected(end+1)=get_reject_struct_name(sfdataName,chart.Path,'Stateflow');%#ok
                                                        continue;
                                                    end


                                                    [found,isSignal]=findVariable(sfdataName,chart.Path);
                                                    if found
                                                        if isSignal
                                                            foundList{end+1}=sfdataName;%#ok
                                                            continue;
                                                        else
                                                            invalidList{end+1}=sfdataName;%#ok
                                                            rejected(end+1)=get_reject_struct_exists(sfdataName,chart.Path,'Stateflow');%#ok
                                                            continue;
                                                        end
                                                    end

                                                    sfdataList{end+1}.name=sfdataName;%#ok
                                                    sfdataList{end}.type='Signal';
                                                    sfdataList{end}.datatype=data(i).CompiledType;
                                                    sfdataList{end}.dimensions=str2num(data(i).CompiledSize);%#ok
                                                    sfdataList{end}.datasource='Stateflow';
                                                    sfdataList{end}.dataclass='Variable';
                                                    sfdataList{end}.sourceblock=string(chart.Path);
                                                end
                                            end
                                        end


                                        function dsmNames=getStateflowDataStoreMemoryNames(modelName)



                                            dsmNames={};

                                            rt=sfroot;
                                            model=rt.find('-isa','Simulink.BlockDiagram','-and','Name',modelName);
                                            if~isempty(model)
                                                chart=model.find('-isa','Stateflow.Chart');
                                                for k=1:length(chart)
                                                    data=chart.find('-isa','Stateflow.Data');
                                                    for i=1:length(data)
                                                        if strcmp(data(i).Scope,'Data Store Memory')
                                                            dsmNames{end+1,1}=data(i).Name;%#ok
                                                        end
                                                    end
                                                end
                                            end


                                            function result=isValidVarName(varName,modelName)


                                                cKeywords={'asm','auto','break','case','char','const','continue',...
                                                'default','do','double','else','entry','enum','extern',...
                                                'float','for','fortran','goto','if','int','long',...
                                                'register','return','short','signed','sizeof','static',...
                                                'struct','switch','typedef','union','unsigned','void',...
                                                'volatile','while'};

                                                result=(isvarname(varName)&&...
                                                iscvar(varName)&&...
                                                (length(varName)<=get_param(modelName,'MaxIdLength'))&&...
                                                ~iskeyword(varName)&&...
                                                ~ismember(varName,cKeywords));


                                                function[found,isSignal]=findVariable(varName,block)


                                                    [var,found]=slResolve(varName,block,'variable');

                                                    if found
                                                        isSignal=isa(var,'Simulink.Signal');
                                                    else
                                                        isSignal=false;
                                                    end


                                                    function[dataList,invalidList,foundList,rejected]=get_model_SignalList(modelName)


                                                        dataList={};
                                                        foundList={};

                                                        try










                                                            [actualSource,rejected]=find_all_line_s_and_d(modelName);
                                                            invalidList={rejected(:).Name};














                                                            actSrcPortHandles=actualSource.actSrcPortHandle;
                                                            for i=1:length(actualSource.actSrcPortHandle)
                                                                if isempty(actualSource.actSrcPortHandle(i))
                                                                    actSrcPortHandles(i)=0;
                                                                end
                                                            end

                                                            arsc=[];
                                                            arsc.name={};
                                                            arsc.srcBlkHandle=[];
                                                            arsc.actSrcBlkHandle=[];
                                                            arsc.actSrcPortHandle=[];
                                                            arsc.actDestHandle={};
                                                            arsc.portInfo={};




                                                            for i=1:length(actSrcPortHandles)
                                                                name=actualSource.name{i};
                                                                linesWithSameSrcPort=(actSrcPortHandles(i)==actSrcPortHandles);
                                                                idxOfSignalsWithSameSrc=find(linesWithSameSrcPort);
                                                                if length(idxOfSignalsWithSameSrc)>1
                                                                    if isempty(actualSource.actDestHandle{i})

                                                                        foundConnectedLine=false;


                                                                        destOfLinesWithSameSrc=actualSource.actDestHandle(idxOfSignalsWithSameSrc);
                                                                        for k=1:length(destOfLinesWithSameSrc)
                                                                            if~isempty(destOfLinesWithSameSrc{k})
                                                                                foundConnectedLine=true;
                                                                                break;
                                                                            end
                                                                        end

                                                                        if foundConnectedLine


                                                                            continue;
                                                                        end
                                                                    end




                                                                    assert(actSrcPortHandles(i)>0);
                                                                    if actSrcPortHandles(i)>0
                                                                        namesOfSignalsWithSameSrc=actualSource.name(idxOfSignalsWithSameSrc);
                                                                        if length(unique(namesOfSignalsWithSameSrc))>1


                                                                            if~strcmp(name,namesOfSignalsWithSameSrc{end})
                                                                                refInfo.datasource='Signal';
                                                                                refInfo.reasonID='SignalWithMultipleNames';
                                                                                refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                refInfo.sourceblock=string(getfullname(actualSource.actSrcBlkHandle(i)));


                                                                                parent=get_parent(actualSource.actSrcBlkHandle(i));
                                                                                if(strcmp(get_param(parent,'Type'),'block')&&...
                                                                                    strcmp(get_param(parent,'BlockType'),'SubSystem')&&...
                                                                                    strcmp(get_param(parent,'SFBlockType'),'Chart'))
                                                                                    refInfo.sourceblock=string(parent);
                                                                                end

                                                                                invalidList{end+1}=name;%#ok
                                                                                rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                continue;
                                                                            end
                                                                        end
                                                                    end
                                                                end

                                                                arsc.name{end+1}=actualSource.name{i};
                                                                arsc.srcBlkHandle(end+1)=actualSource.srcBlkHandle(i);
                                                                arsc.actSrcBlkHandle(end+1)=actualSource.actSrcBlkHandle(i);
                                                                arsc.actSrcPortHandle(end+1)=actualSource.actSrcPortHandle(i);
                                                                arsc.actDestHandle{end+1}=actualSource.actDestHandle{i};
                                                                arsc.portInfo{end+1}=actualSource.portInfo{i};
                                                            end

                                                            actualSource=arsc;
                                                            signalNames=actualSource.name;
                                                            uniqueNames=unique(signalNames);









                                                            duplicates={};
                                                            extraIgnoreIndex=[];
                                                            for i=1:length(uniqueNames)
                                                                name=uniqueNames{i};
                                                                linesWithSameName=strcmp(name,signalNames);
                                                                idxOfLinesWithSameName=find(linesWithSameName);
                                                                handles=actualSource.actSrcPortHandle(idxOfLinesWithSameName);
                                                                uHandles=unique(handles);
                                                                if length(uHandles)>1
                                                                    duplicates{end+1}=name;%#ok
                                                                else
                                                                    extraIgnoreIndex=[extraIgnoreIndex,idxOfLinesWithSameName(2:end)];%#ok
                                                                end
                                                            end
                                                            ignoreList=[];
                                                            validdup={};


                                                            invaliddupIndex={};
                                                            ignoreListIndex={};
                                                            for i=1:length(duplicates)
                                                                dindex=find(strcmp(duplicates(i),signalNames));
                                                                dhand=actualSource.actSrcPortHandle(dindex(1));
                                                                invaliddup=false;
                                                                for j=2:length(dindex)





                                                                    if dhand~=actualSource.actSrcPortHandle(dindex(j))
                                                                        invaliddup=true;
                                                                        invaliddupIndex{end+1}=i;%#ok
                                                                    else
                                                                        validdup{end+1}=i;%#ok
                                                                    end

                                                                end
                                                                if~invaliddup
                                                                    ignoreListIndex{end+1}=dindex(2:end);%#ok
                                                                end
                                                            end

                                                            newDupList={};
                                                            for i=1:length(invaliddupIndex)
                                                                newDupList(i)=duplicates(invaliddupIndex{i});%#ok
                                                            end

                                                            for i=1:length(validdup)
                                                                newDupList(end+1)=duplicates(validdup{i});%#ok
                                                            end

                                                            for i=1:length(ignoreListIndex)
                                                                ignoreList=[ignoreList,ignoreListIndex{i}];%#ok
                                                            end

                                                            ignoreList=[ignoreList,extraIgnoreIndex];
                                                            duplicates=newDupList;
                                                            [b,I,J]=unique(actualSource.actSrcPortHandle);%#ok

                                                            index=1;

                                                            for i=1:length(signalNames)
                                                                signalName=signalNames{i};
                                                                if isempty(find(ignoreList==i,1))

                                                                    [found,isSignal]=findVariable(signalName,actualSource.srcBlkHandle(i));
                                                                    if found
                                                                        if isSignal
                                                                            foundList{end+1}=signalName;%#ok
                                                                            continue;
                                                                        else
                                                                            invalidList{end+1}=signalName;%#ok
                                                                            rejected(end+1)=get_reject_struct_exists(signalName,actualSource.srcBlkHandle(i),'Signal');%#ok
                                                                            continue;
                                                                        end
                                                                    end



                                                                    if ismember(signalName,duplicates)
                                                                        invalidList{end+1}=signalName;%#ok
                                                                        refInfo.datasource='Signal';
                                                                        refInfo.reasonID='SignalLabelForMultipleSources';
                                                                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                        refInfo.sourceblock=string(getfullname(actualSource.srcBlkHandle(i)));
                                                                        rejected(end+1)=struct('Name',signalName,'Info',refInfo);%#ok
                                                                        continue;
                                                                    end

                                                                    actualPortInfo=actualSource.portInfo{i};
                                                                    if~strcmp(actualPortInfo.destCompiledPortDataType,'fcn_call')
                                                                        if strcmp(actualPortInfo.compiledRTWStorageClass,'Auto')

                                                                            temp=actualSource.actDestHandle(i);
                                                                            tempX=temp{1};
                                                                            if isempty(tempX)
                                                                                destFound=false;
                                                                                tempX=1;
                                                                            else
                                                                                destFound=true;
                                                                            end

                                                                            if~isempty(tempX)


                                                                                sh=actualSource.actSrcBlkHandle(i);




                                                                                if destFound
                                                                                    [filterStatus,rejectedDelta]=filter_signal(actualSource.actDestHandle{i},sh,signalName);
                                                                                else
                                                                                    [filterStatus,rejectedDelta]=filter_signal([],sh,signalName);
                                                                                end

                                                                                if filterStatus
                                                                                    invalidList{end+1}=signalName;%#ok
                                                                                    rejected=[rejected,rejectedDelta];%#ok
                                                                                    continue;
                                                                                end

                                                                                dataList{index}.name=signalName;%#ok
                                                                                dataList{index}.type='Signal';%#ok
                                                                                dataList{index}.datatype=actualPortInfo.CompiledPortDataType;%#ok
                                                                                dataList{index}.dimensions=l_process_port_dimensions(actualPortInfo.CompiledPortDimensions);%#ok
                                                                                dataList{index}.datasource='';%#ok
                                                                                dataList{index}.dataclass='Variable';%#ok
                                                                                dataList{index}.sourceblock=string(getfullname(sh));%#ok
                                                                                switch(get_param(sh,'blocktype'))
                                                                                case 'Inport'
                                                                                    parent=get_parent(sh);
                                                                                    if strcmp(parent,modelName)
                                                                                        dataList{index}.datasource='RootInput';%#ok
                                                                                    else
                                                                                        dataList{index}.datasource='Internal';%#ok
                                                                                    end
                                                                                case 'Outport'
                                                                                    parent=get_parent(sh);
                                                                                    if strcmp(parent,modelName)
                                                                                        dataList{index}.datasource='RootOutput';%#ok
                                                                                    else
                                                                                        dataList{index}.datasource='Internal';%#ok
                                                                                    end
                                                                                otherwise



                                                                                    if destFound
                                                                                        dHandles=actualSource.actDestHandle{i};
                                                                                    else
                                                                                        dHandles=[];
                                                                                    end
                                                                                    dataList{index}.datasource='Internal';%#ok
                                                                                    for qi=1:length(dHandles)
                                                                                        blockH=get_parent(dHandles(qi));
                                                                                        parent=get_parent(blockH);
                                                                                        if strcmp(get_param(blockH,'BlockType'),'Outport')&&strcmp(parent,modelName)
                                                                                            dataList{index}.datasource='RootOutput';
                                                                                            break;
                                                                                        end
                                                                                    end

                                                                                    parent=get_parent(sh);
                                                                                    if(strcmp(get_param(parent,'Type'),'block')&&...
                                                                                        strcmp(get_param(parent,'BlockType'),'SubSystem')&&...
                                                                                        strcmp(get_param(parent,'SFBlockType'),'Chart'))
                                                                                        dataList{index}.sourceblock=string(parent);%#ok
                                                                                    end
                                                                                end
                                                                                index=index+1;
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        catch e
                                                            errorObject=MSLException(get_param(modelName,'Handle'),'Simulink:dow:ErrorCompilingListOfObjects',...
                                                            DAStudio.message('Simulink:dow:ErrorCompilingListOfObjects'));
                                                            errorObject.addCause(e);
                                                            throw(errorObject);
                                                        end


                                                        function[paramList,invalidList,foundList,rejected]=get_model_ParamList(modelName,refWSVars)

                                                            paramList={};
                                                            invalidList={};
                                                            foundList={};
                                                            rejected=emptyStruct;


                                                            globalScope=get_param(modelName,'DataDictionary');
                                                            numericVars=slGetSpecifiedWSData(globalScope,1,0,0);
                                                            if slfeature('SLModelAllowedBaseWorkspaceAccess')>0&&~isempty(globalScope)&&...
                                                                strcmp(get_param(modelName,'HasAccessToBaseWorkspace'),'on')

                                                                varBWS=slGetSpecifiedWSData('',1,0,0);
                                                                numericVars=cat(1,numericVars,varBWS);
                                                            end


                                                            tunableVars=get_tunable_info(modelName);

                                                            try
                                                                for i=1:length(refWSVars)
                                                                    name=refWSVars(i).Name;
                                                                    varValue=evalinGlobalScope(modelName,name);

                                                                    if isa(varValue,'Simulink.Parameter')
                                                                        foundList{end+1}=name;%#ok
                                                                        continue;
                                                                    end

                                                                    if(isa(varValue,'Simulink.Signal')||...
                                                                        isa(varValue,'Simulink.DataType')||...
                                                                        isa(varValue,'Simulink.LookupTable')||...
                                                                        isa(varValue,'Simulink.Breakpoint')||...
                                                                        isa(varValue,'Simulink.ConfigSetRoot'))

                                                                        continue;
                                                                    end


                                                                    if~ismember(name,numericVars)
                                                                        invalidList{end+1}=name;%#ok
                                                                        refInfo.datasource='Parameter';
                                                                        refInfo.reasonID='CannotConvertVariableToParameter';
                                                                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                        refInfo.sourceblock=string(getfullname([refWSVars(i).ReferencedBy]));
                                                                        rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                        continue;
                                                                    end


                                                                    if ismember(name,tunableVars)
                                                                        invalidList{end+1}=name;%#ok
                                                                        refInfo.datasource='Parameter';
                                                                        refInfo.reasonID='ParameterStorageClassSpecified';
                                                                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                        refInfo.sourceblock=string(getfullname([refWSVars(i).ReferencedBy]));
                                                                        rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                        continue;
                                                                    end

                                                                    paramList{end+1}.name=name;%#ok
                                                                    paramList{end}.type='Parameter';
                                                                    paramList{end}.datatype=get_param_data_type(varValue);
                                                                    paramList{end}.dimensions=size(varValue);
                                                                    paramList{end}.datasource='Parameter';
                                                                    paramList{end}.sourceblock=string(getfullname([refWSVars(i).ReferencedBy]));
                                                                    paramList{end}.dataclass='Const';
                                                                    clear varValue;
                                                                end
                                                            catch e
                                                                errorObject=MSLException(get_param(modelName,'Handle'),'Simulink:dow:ErrorCompilingListOfObjects',...
                                                                DAStudio.message('Simulink:dow:ErrorCompilingListOfObjects'));
                                                                errorObject.addCause(e);
                                                                throw(errorObject);
                                                            end


                                                            function tunableVars=get_tunable_info(modelName)
                                                                tunableVars={};
                                                                modelObject=get_param(modelName,'Object');

                                                                if~isempty(modelObject.TunableVars)
                                                                    tunableVars=textscan(modelObject.TunableVars,'%s','Delimiter',',');
                                                                    tunableVars=tunableVars{1};
                                                                end


                                                                function dataType=get_param_data_type(varValue)

                                                                    if isa(varValue,'embedded.fi')
                                                                        dataType=varValue.numerictype.tostringInternalFixdt;
                                                                        return;
                                                                    elseif islogical(varValue)
                                                                        dataType='boolean';
                                                                    else
                                                                        dataType=class(varValue);


                                                                        assert(ismember(dataType,Simulink.DataTypePrmWidget.getBuiltinList('NumBool'))||...
                                                                        Simulink.data.isSupportedEnumObject(varValue)||...
                                                                        isstruct(varValue));
                                                                    end


                                                                    function[actualSource,rejected]=find_all_line_s_and_d(modelName)
































                                                                        rejected=emptyStruct;
                                                                        actualSource=[];

                                                                        try

                                                                            lines=l_find_lines(modelName);
                                                                            index=0;
                                                                            signalName=[];
                                                                            srcBlkHandle=[];
                                                                            actSrcBlkHandle=[];
                                                                            actSrcPortHandle=[];
                                                                            actualDestHandle=[];
                                                                            actualPortInfo=[];





                                                                            for lineIdx=1:length(lines)
                                                                                lineObj=get_param(lines(lineIdx),'Object');
                                                                                name=lineObj.Name;


                                                                                if isempty(strtrim(name))
                                                                                    continue;
                                                                                end



                                                                                if(lineObj.SrcPortHandle<0)
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SignalWithoutSrcBlk';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock="";
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end

                                                                                srcPortObj=get_param(lineObj.SrcPortHandle,'Object');



                                                                                if length(name)>=2&&strcmp(name(1),'<')&&strcmp(name(end),'>')
                                                                                    refInfo.datasource='Signal';
                                                                                    if strcmp(get_param(srcPortObj.Parent,'BlockType'),'BusSelector')
                                                                                        refInfo.reasonID='SignalLabelNamePropagationForBusSelector';
                                                                                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    else
                                                                                        refInfo.reasonID='SignalLabelNamePropagation';
                                                                                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    end
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end


                                                                                if~isValidVarName(name,modelName)
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SignalLabelInvalid';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end



                                                                                if~strcmp(get_param(srcPortObj.Parent,'Commented'),'off')
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SourceBlockCommentedOut';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end



                                                                                if strcmp(get_param(srcPortObj.Parent,'CompiledIsActive'),'off')
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SourceBlockDisabled';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end


                                                                                if strcmp(get_param(srcPortObj.Parent,'BlockType'),'Demux')
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SignalFeedingMux';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end


                                                                                dstPortHdl=lineObj.DstPortHandle;

                                                                                if length(dstPortHdl)>1


                                                                                    continue;
                                                                                end




                                                                                clear portInfo;




                                                                                if((dstPortHdl<0)||...
                                                                                    (strcmp(get_param(get_param(dstPortHdl,'Parent'),'Commented'),'on'))||...
                                                                                    ((strcmp(get_param(get_param(dstPortHdl,'Parent'),'CompiledIsActive'),'off'))&&~(strcmp(get_param(get_param(dstPortHdl,'Parent'),'Commented'),'through'))))


                                                                                    baseLineObj=get_param(srcPortObj.Line,'Object');
                                                                                    dstPortHandles=baseLineObj.DstPortHandle;
                                                                                    if any(dstPortHandles>0)


                                                                                        foundConnectedDstPort=false;
                                                                                        for dstIdx=1:length(dstPortHandles)
                                                                                            if((dstPortHandles(dstIdx)>0)&&...
                                                                                                (~strcmp(get_param(get_param(dstPortHandles(dstIdx),'Parent'),'Commented'),'on')))
                                                                                                foundConnectedDstPort=true;
                                                                                                break;
                                                                                            end
                                                                                        end
                                                                                        if foundConnectedDstPort
                                                                                            continue;
                                                                                        end
                                                                                    end






                                                                                    srcCompiledPortDataType=srcPortObj.CompiledPortDataType;
                                                                                    portInfo.compiledRTWStorageClass=srcPortObj.compiledRTWStorageClass;
                                                                                    portInfo.destCompiledPortDataType=srcCompiledPortDataType;
                                                                                    portInfo.CompiledPortDataType=srcCompiledPortDataType;
                                                                                    portInfo.CompiledPortDimensions=srcPortObj.CompiledPortDimensions;
                                                                                    actualPortInfo{end+1}=portInfo;%#ok

                                                                                    signalName{end+1}=name;%#ok
                                                                                    srcBlkHandle(end+1)=get_param(srcPortObj.Parent,'Handle');%#ok
                                                                                    actSrcBlkHandle(end+1)=get_param(srcPortObj.Parent,'Handle');%#ok
                                                                                    actSrcPortHandle(end+1)=srcPortObj.Handle;%#ok
                                                                                    actualDestHandle{end+1}=[];%#ok
                                                                                    index=index+1;
                                                                                    continue;
                                                                                end

                                                                                dstPortObj=get_param(dstPortHdl,'Object');
                                                                                dstBlkObj=get_param(dstPortObj.ParentHandle,'Object');



                                                                                if strcmp(dstBlkObj.Commented,'through')
                                                                                    assert(isempty(l_getActualSrc(dstPortObj)));


                                                                                    actDstInfo=srcPortObj.getActualDst;
                                                                                    if isempty(actDstInfo)
                                                                                        srcCompiledPortDataType=srcPortObj.CompiledPortDataType;
                                                                                        portInfo.compiledRTWStorageClass=srcPortObj.compiledRTWStorageClass;
                                                                                        portInfo.destCompiledPortDataType=srcCompiledPortDataType;
                                                                                        portInfo.CompiledPortDataType=srcCompiledPortDataType;
                                                                                        portInfo.CompiledPortDimensions=srcPortObj.CompiledPortDimensions;
                                                                                        actualPortInfo{end+1}=portInfo;%#ok

                                                                                        signalName{end+1}=name;%#ok
                                                                                        srcBlkHandle(end+1)=get_param(srcPortObj.Parent,'Handle');%#ok
                                                                                        actSrcBlkHandle(end+1)=get_param(srcPortObj.Parent,'Handle');%#ok
                                                                                        actSrcPortHandle(end+1)=srcPortObj.Handle;%#ok
                                                                                        actualDestHandle{end+1}=[];%#ok
                                                                                        index=index+1;
                                                                                        continue;
                                                                                    end


                                                                                    dstPortObj=get_param(actDstInfo(1),'Object');
                                                                                    dstPortHdl=dstPortObj.Handle;
                                                                                end


                                                                                destCompiledPortDataType=dstPortObj.CompiledPortDataType;


                                                                                if(strcmp(destCompiledPortDataType,'fcn_call')||...
                                                                                    strcmp(destCompiledPortDataType,'action'))
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SignalFeedingActionPort';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end


                                                                                actSrcInfo=l_getActualSrc(dstPortObj);


                                                                                nActSrcPorts=size(actSrcInfo,1);
                                                                                if(nActSrcPorts>1)
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SignalIsVirtualBus';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end

                                                                                assert(nActSrcPorts==1);

                                                                                actSrcPortHdl=actSrcInfo(1);
                                                                                actSrcPortObj=get_param(actSrcPortHdl,'Object');
                                                                                srcPortObj=get_param(lineObj.SrcPortHandle,'Object');
                                                                                srcCompiledPortDataType=srcPortObj.CompiledPortDataType;

                                                                                assert(~isempty(destCompiledPortDataType));
                                                                                assert(~isempty(srcCompiledPortDataType));




                                                                                srcAliasThruDT=srcPortObj.CompiledPortAliasedThruDataType;
                                                                                actSrcAliasThruDT=actSrcPortObj.CompiledPortAliasedThruDataType;
                                                                                if~strcmp(srcAliasThruDT,actSrcAliasThruDT)
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SignalDataTypeDifferentFromSource';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end



                                                                                dstAliasThruDT=dstPortObj.CompiledPortAliasedThruDataType;
                                                                                if~strcmp(srcAliasThruDT,dstAliasThruDT)
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SignalIsVirtualBus';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end



                                                                                if(get_param(dstPortHdl,'CompiledPortWidth')<...
                                                                                    get_param(actSrcPortHdl,'CompiledPortWidth'))
                                                                                    refInfo.datasource='Signal';
                                                                                    refInfo.reasonID='SignalFromDemux';
                                                                                    refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                    refInfo.sourceblock=string(srcPortObj.Parent);
                                                                                    rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                    continue;
                                                                                end






                                                                                signalName{end+1}=name;%#ok
                                                                                srcBlkHandle(end+1)=get_param(srcPortObj.Parent,'Handle');%#ok


                                                                                portInfo.compiledRTWStorageClass=actSrcPortObj.CompiledRTWStorageClass;
                                                                                portInfo.destCompiledPortDataType=destCompiledPortDataType;
                                                                                portInfo.CompiledPortDataType=actSrcPortObj.CompiledPortDataType;
                                                                                portInfo.CompiledPortDimensions=actSrcPortObj.CompiledPortDimensions;
                                                                                actualPortInfo{end+1}=portInfo;%#ok


                                                                                [actSrcBlkHandle(end+1),actSrcPortHandle(end+1)]=l_get_valid_handles(actSrcPortObj);%#ok


                                                                                actDstInfo=actSrcPortObj.getActualDst;
                                                                                if isempty(actDstInfo)
                                                                                    actualDestHandle{end+1}=[];%#ok
                                                                                else
                                                                                    actualDestHandle{end+1}=actDstInfo(:,1);%#ok
                                                                                end

                                                                                index=index+1;
                                                                            end
                                                                        catch e %#ok
                                                                            MSLDiagnostic('Simulink:dow:ErrorAnalyzingSignals',name).reportAsWarning;
                                                                        end

                                                                        assert(index==length(signalName));
                                                                        assert(index==length(srcBlkHandle));
                                                                        assert(index==length(actSrcBlkHandle));
                                                                        assert(index==length(actSrcPortHandle));
                                                                        assert(index==length(actualDestHandle));
                                                                        assert(index==length(actualPortInfo));

                                                                        actualSource.name=signalName;
                                                                        actualSource.srcBlkHandle=srcBlkHandle;
                                                                        actualSource.actSrcBlkHandle=actSrcBlkHandle;
                                                                        actualSource.actSrcPortHandle=actSrcPortHandle;
                                                                        actualSource.actDestHandle=actualDestHandle;
                                                                        actualSource.portInfo=actualPortInfo;






                                                                        function h_srcPort=l_getActualSrc(obj)

                                                                            h_srcPort=obj.getActualSrc;
                                                                            if~isempty(h_srcPort)
                                                                                num_nonvirtual_src=size(h_srcPort,1);

                                                                                for k=1:num_nonvirtual_src


                                                                                    hPort=h_srcPort(k,1);
                                                                                    blkPath=get_param(hPort,'Parent');
                                                                                    assert(~isempty(blkPath))

                                                                                    try
                                                                                        blkObj=get_param(blkPath,'Object');
                                                                                    catch e %#ok



                                                                                        hBlk=get_param(hPort,'ParentHandle');
                                                                                        blkObj=get_param(hBlk,'Object');
                                                                                        assert(blkObj.isSynthesized);
                                                                                        return;
                                                                                    end


                                                                                    if ismember(blkObj.BlockType,{'ModelReference','VariantMerge'})
                                                                                        return;
                                                                                    end


                                                                                    if blkObj.isSynthesized

                                                                                        hPorts=blkObj.PortHandles;
                                                                                        if~isempty(hPorts.Inport)


                                                                                            assert(numel(hPorts.Inport)==1);
                                                                                            assert(numel(hPorts.Outport)==1);
                                                                                            portObj=get_param(hPorts.Inport,'Object');
                                                                                            if~isempty(portObj)


                                                                                                h_srcPortSynth=l_getActualSrc(portObj);

                                                                                                h_srcPort(k,:)=h_srcPortSynth(1,:);

                                                                                                for idx2=2:size(h_srcPortSynth,1)
                                                                                                    h_srcPort(end+1,:)=h_srcPortSynth(idx2,:);%#ok
                                                                                                end
                                                                                            end
                                                                                        end
                                                                                    end
                                                                                end
                                                                            end


                                                                            function update_diagram(modelName)

                                                                                obj=get_param(modelName,'Object');


                                                                                tmp=methods(obj);%#ok


                                                                                currWarn=warning('backtrace','off');
                                                                                cleanup1=onCleanup(@()warning(currWarn));

                                                                                try
                                                                                    if(slfeature('AutoMigrationIM')==0)
                                                                                        obj.init('COMMAND_LINE','UpdateBDOnly',true);
                                                                                    else

                                                                                        portBlocks=[find_system(modelName,'SearchDepth',1,'BlockType','EnablePort');...
                                                                                        find_system(modelName,'SearchDepth',1,'BlockType','TriggerPort')];

                                                                                        if isempty(portBlocks)

                                                                                            init(obj,'RTW','UpdateBDOnly',true);
                                                                                        else

                                                                                            init(obj,'MDLREF_RTW');
                                                                                        end
                                                                                    end
                                                                                catch e
                                                                                    rethrow(e);
                                                                                end


                                                                                function[signalList,badList,rejected]=validate_all_signals(signalList)



                                                                                    rejected=emptyStruct;


                                                                                    signalNames={};
                                                                                    for idx=1:length(signalList)
                                                                                        signalNames{end+1}=signalList{idx}.name;%#ok
                                                                                    end


                                                                                    duplicateSignalIds=[];
                                                                                    for i=1:(length(signalNames)-1)
                                                                                        name=signalNames{i};
                                                                                        if isempty(name)
                                                                                            continue;
                                                                                        end


                                                                                        matchingIds=(i+find(strcmp(name,signalNames(i+1:end))));
                                                                                        if isempty(matchingIds)
                                                                                            continue;
                                                                                        end


                                                                                        sourceBlocks=signalList{i}.sourceblock;
                                                                                        for j=matchingIds
                                                                                            sourceBlocks=[sourceBlocks,signalList{j}.sourceblock];%#ok

                                                                                            signalNames{j}='';%#ok
                                                                                        end
                                                                                        refInfo.datasource='Signal';
                                                                                        refInfo.reasonID='SignalLabelForMultipleSources';
                                                                                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                        refInfo.sourceblock=unique(sourceBlocks);
                                                                                        rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok


                                                                                        duplicateSignalIds=[duplicateSignalIds,matchingIds];%#ok
                                                                                    end


                                                                                    signalList(duplicateSignalIds)=[];
                                                                                    signalNames(duplicateSignalIds)=[];


                                                                                    [~,signalOrder]=sort(signalNames);
                                                                                    signalList=signalList(signalOrder);

                                                                                    badList={rejected(:).Name};


                                                                                    function[goodList,rejected]=rejectSignals(goodList)


                                                                                        rejected=emptyStruct;


                                                                                        for idx=length(goodList):-1:1
                                                                                            if strcmp(goodList{idx}.type,'Signal')
                                                                                                refInfo.datasource='Signal';
                                                                                                refInfo.reasonID='SignalResolutionDisabled';
                                                                                                refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                                refInfo.sourceblock=goodList{idx}.sourceblock;
                                                                                                rejected(end+1)=struct('Name',goodList{idx}.name,'Info',refInfo);%#ok
                                                                                                goodList{idx}=[];
                                                                                            end
                                                                                        end


                                                                                        function err_disp(errorObject)

                                                                                            sldiagviewer.reportError(errorObject);
                                                                                            return


                                                                                            function[filterStatus,rejected]=filter_signal(dh,sh,name)



















                                                                                                filterStatus=false;
                                                                                                rejected=emptyStruct;
                                                                                                for i=1:length(dh)
                                                                                                    dhp=get_parent(dh);
                                                                                                    btype=get_param(dhp,'blocktype');
                                                                                                    if strcmp(btype,'Merge')
                                                                                                        filterStatus=true;

                                                                                                        obj=get_param(sh,'Object');
                                                                                                        refInfo.sourceblock=string(obj.getFullName);
                                                                                                        refInfo.datasource='Signal';
                                                                                                        refInfo.reasonID='SignalFeedingMergeBlock';
                                                                                                        refInfo.reason=l_reasonFromID(refInfo.reasonID);
                                                                                                        rejected(end+1)=struct('Name',name,'Info',refInfo);%#ok
                                                                                                    end
                                                                                                end


                                                                                                function parent=get_parent(child)

                                                                                                    parent=get_param(child,'Parent');
                                                                                                    num=size(parent,1);
                                                                                                    if(num==1)
                                                                                                        parent={parent};
                                                                                                    end

                                                                                                    for i=1:num
                                                                                                        try

                                                                                                            hParent=get_param(parent{i},'Handle');%#ok
                                                                                                        catch e %#ok




                                                                                                            assert(isequal(get_param(child(i),'Type'),'port'));


                                                                                                            hParent=get_param(child(i),'ParentHandle');
                                                                                                            parentObj=get_param(hParent,'Object');
                                                                                                            assert(parentObj.isSynthesized);


                                                                                                            grandparent=parentObj.Parent;
                                                                                                            parent{i}=grandparent;
                                                                                                        end
                                                                                                    end

                                                                                                    if(num==1)
                                                                                                        parent=parent{1};
                                                                                                    end





                                                                                                    function[hBlk,hPort]=l_get_valid_handles(portObj)

                                                                                                        portNo=portObj.PortNumber;
                                                                                                        blkPath=portObj.Parent;
                                                                                                        assert(~isempty(blkPath));

                                                                                                        try
                                                                                                            hBlk=get_param(blkPath,'Handle');
                                                                                                            hPorts=get_param(hBlk,'PortHandles');
                                                                                                            hPort=hPorts.Outport(portNo);
                                                                                                        catch e %#ok



                                                                                                            hBlk=portObj.ParentHandle;
                                                                                                            blkObj=get_param(hBlk,'Object');
                                                                                                            assert(blkObj.isSynthesized);

                                                                                                            if strcmp(blkObj.BlockType,'ModelReference')

                                                                                                                originalBlkObj=blkObj;
                                                                                                            else
                                                                                                                originalBlkObj=get_param(blkObj.getOriginalBlock,'Object');
                                                                                                                assert(portNo==1);
                                                                                                                assert(length(originalBlkObj.PortHandles.Outport)==1);
                                                                                                            end
                                                                                                            hBlk=originalBlkObj.Handle;
                                                                                                            hPort=originalBlkObj.PortHandles.Outport(portNo);
                                                                                                        end


                                                                                                        function i_waitbar(value,handle)

                                                                                                            if ishghandle(handle)
                                                                                                                waitbar(value,handle);
                                                                                                            end


                                                                                                            function results=l_find_block(modelName,varargin)

                                                                                                                results=find_system(modelName,...
                                                                                                                'FollowLinks','on',...
                                                                                                                'LookUnderMasks','all',...
                                                                                                                'Commented','off',...
                                                                                                                'CompiledIsActive','on',...
                                                                                                                varargin{:});


                                                                                                                function results=l_find_block_with_state(modelName,varargin)

                                                                                                                    if strcmp(get_param(modelName,'SignalResolutionControl'),'UseLocalSettings')
                                                                                                                        args={};
                                                                                                                    else
                                                                                                                        args={'FollowLinks','on'};
                                                                                                                    end
                                                                                                                    args=[args,{'LookUnderMasks','all'},varargin,{'Commented','off','CompiledIsActive','on'}];

                                                                                                                    results=find_system(modelName,args{:});


                                                                                                                    function results=l_find_lines(modelName,varargin)

                                                                                                                        if strcmp(get_param(modelName,'SignalResolutionControl'),'UseLocalSettings')
                                                                                                                            args={};
                                                                                                                        else
                                                                                                                            args={'FollowLinks','on'};
                                                                                                                        end
                                                                                                                        args=[args,{'LookUnderMasks','on','FindAll','on','Type','line'},varargin];

                                                                                                                        results=find_system(modelName,args{:});


                                                                                                                        function dimensions=l_process_port_dimensions(dimensions)

                                                                                                                            assert(dimensions(1)>0);
                                                                                                                            if(length(dimensions)==2)

                                                                                                                                assert(dimensions(1)==1);
                                                                                                                                dimensions=dimensions(2);
                                                                                                                            else

                                                                                                                                assert(dimensions(1)==(length(dimensions)-1));
                                                                                                                                dimensions=dimensions(2:end);
                                                                                                                            end


                                                                                                                            function result=l_reasonFromID(messageID)
                                                                                                                                result=DAStudio.message(['Simulink:dow:',messageID]);


                                                                                                                                function result=emptyStruct
                                                                                                                                    result=struct('Name','','Info',[]);
                                                                                                                                    result(1)=[];


