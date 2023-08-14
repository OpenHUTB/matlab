


function buildStruct=CRCSBuildModel(modelPath,inportBusObjNames,outportBusObjNames,inportBusData,outportBusData,sampleTimeHexStr,timeOut,modelArgs,logArgs,simMode,serverAddress,openForDebug,openWrapperModel,reuseArtifacts)
    try
        buildStruct=struct('handle','','isError',false,'errorMsg','');

        [~,modelName,~]=fileparts(modelPath);

        wrapperModel=['cosim__wrapper__',modelName];

        hdl=inf;
        if reuseArtifacts
            hdl=cosimcompileutils.CRCSArtifactsMgr.getInstance().getCachedHarnessModel(wrapperModel);
        end

        submdlh=load_system(modelPath);


        inports=find_system(modelName,'SearchDepth',1,'BlockType','Inport');
        inportBusObjNames_cell=eval(inportBusObjNames);
        busNames=inportBusObjNames_cell;
        hasVirtualBus=false;
        for i=1:length(busNames)
            busName=busNames{i};
            if~isempty(busName)
                port_hdl=get_param(inports{i},'Handle');
                isNV=get_param(port_hdl,'BusOutputAsStruct');
                if strcmp(isNV,'off')

                    inportBusData{i}=getBusElements(busName,'');
                    n=length(inportBusData{i});
                    inportBusData{end}{1}=num2str(str2double(inportBusData{end}{1})+n-1);

                    inportBusObjNames_cell(i:i+n-1)={''};
                    inportBusObjNames_cell(i+n:length(busNames)+n-1)=busNames(i+1:end);
                    hasVirtualBus=true;
                end
            end
        end
        if hasVirtualBus
            inportBusObjNames=convertCellToString(inportBusObjNames_cell);
        end

        if isinf(hdl)||isnan(hdl)
            hdl=doBuildHarnessModel(modelName,wrapperModel,submdlh,inportBusObjNames,outportBusObjNames,inportBusData,outportBusData,sampleTimeHexStr,timeOut,serverAddress,reuseArtifacts);
        end

        refreshModelSettings(wrapperModel,modelArgs,simMode,logArgs,inportBusObjNames,outportBusObjNames,inportBusData,outportBusData,sampleTimeHexStr,timeOut,serverAddress);

        if openWrapperModel
            open_system(wrapperModel);
        end

        if openForDebug
            open_system(modelName);
        end

        buildStruct.handle=hdl;

    catch eCause
        buildStruct.isError=true;
        if ismethod(eCause,'json')
            buildStruct.errorMsg=eCause.json;
        else
            buildStruct.errorMsg=jsonencode(eCause);
        end
    end

end

function refreshModelSettings(wrapperModel,modelArgs,simMode,logArgs,inportBusObjNames,outportBusObjNames,inportBusData,outportBusData,sampleTimeHexStr,timeOut,serverAddress)
    setupModelBlockParameters(wrapperModel,modelArgs,simMode);

    updateHarnessModelLoggingConfig(wrapperModel,logArgs);

    updateSFcnParameters(wrapperModel,inportBusObjNames,outportBusObjNames,inportBusData,outportBusData,sampleTimeHexStr,timeOut,serverAddress);
end

function setupModelBlockParameters(wrapperModel,modelArgs,simMode)
    modelBlockName='CosimMdl';
    modelBlkHdl=get_param([wrapperModel,'/',modelBlockName],'handle');

    if(~isempty(modelArgs))
        set_param(modelBlkHdl,'ParameterArgumentValues',modelArgs);
    end


    set_param(modelBlkHdl,'SimulationMode',simMode);

end

function updateHarnessModelLoggingConfig(wrapperModel,logArgs)
    cs=getActiveConfigSet(wrapperModel);
    logArgNames=fieldnames(logArgs);
    for idx=1:numel(logArgNames)
        cs.set_param(logArgNames{idx},logArgs.(logArgNames{idx}));
    end
end

function updateSFcnParameters(wrapperModel,inportBusObjNames,outportBusObjNames,inportBusData,outportBusData,sampleTimeHexStr,timeOut,serverAddress)
    modelBlockName='CosimMdl';
    recBlockName='sfcnRec';
    transBlockName='sfcnTrans';
    modelBlkHdl=get_param([wrapperModel,'/',modelBlockName],'handle');
    recBlkHdl=get_param([wrapperModel,'/',recBlockName],'handle');
    transBlkHdl=get_param([wrapperModel,'/',transBlockName],'handle');

    portNums=get_param(modelBlkHdl,'Ports');

    numIn=portNums(1);
    numOut=portNums(2);


    nInports=numIn;
    nOutports=numOut;
    if size(inportBusData,1)
        nInports=str2double(inportBusData{end}{1});
    end
    if size(outportBusData,1)
        nOutports=str2double(outportBusData{end}{1});
    end


    recParameters=['''receive'',',...
    '''',serverAddress,''',',...
    'uint16([0,0]),',...
    'uint32(0),',...
    'hex2num(''',sampleTimeHexStr,'''),',...
    num2str(timeOut),',',...
    num2str(nInports),',',...
    inportBusObjNames,',',...
    'logical(ones(',num2str(max(nInports,1)),',1))'];
    set_param(recBlkHdl,'Parameters',recParameters);


    transParameters=['''transmit'',',...
    '''',serverAddress,''',',...
    'uint16([0,0]),',...
    'uint32(0),',...
    'hex2num(''',sampleTimeHexStr,'''),',...
    num2str(timeOut),',',...
    num2str(nOutports),',',...
    outportBusObjNames,',',...
    'logical(ones(1,1))'];
    set_param(transBlkHdl,'Parameters',transParameters);
end

function wrapperHandle=doBuildHarnessModel(modelName,wrapperModel,submdlh,inportBusObjNames,outportBusObjNames,inportBusData,outportBusData,sampleTimeHexStr,timeOut,serverAddress,reuseArtifacts)

    modelBlockPath='simulink/Ports & Subsystems/Model';
    sFunctionPath='built-in/S-Function';
    sfcnName='sfcn_gateway';
    recBlockName='sfcnRec';
    transBlockName='sfcnTrans';
    modelBlockName='CosimMdl';
    subsystemPath='simulink/Ports & Subsystems/Subsystem';
    inBEPPath='simulink/Ports & Subsystems/In Bus Element';
    outBEPPath='simulink/Ports & Subsystems/Out Bus Element';
    inportPath='simulink/Sources/In1';
    outportPath='simulink/Sinks/Out1';
    inBEPName='InBusElement';
    outBEPName='OutBusElement';
    inportName='In';
    outportName='Out';

    wrapperHandle=new_system(wrapperModel);


    modelBlkHdl=add_block(modelBlockPath,[wrapperModel,'/',modelBlockName]);

    set_param(modelBlkHdl,'ModelName',modelName);

    portNums=get_param(modelBlkHdl,'Ports');

    numIn=portNums(1);
    numOut=portNums(2);



    nInports=numIn;
    if size(inportBusData,1)
        nInports=str2double(inportBusData{end}{1});
    end


    blockHdl=add_block(sFunctionPath,[wrapperModel,'/',recBlockName]);


    recParameters=['''receive'',',...
    '''',serverAddress,''',',...
    'uint16([0,0]),',...
    'uint32(0),',...
    'hex2num(''',sampleTimeHexStr,'''),',...
    num2str(timeOut),',',...
    num2str(nInports),',',...
    inportBusObjNames,',',...
    'logical(ones(',num2str(max(nInports,1)),',1))'];
    set_param(blockHdl,'FunctionName',sfcnName,'Parameters',recParameters);


    if size(inportBusData,1)
        add_block(subsystemPath,[wrapperModel,'/Subsystem']);
        Simulink.SubSystem.deleteContents([wrapperModel,'/Subsystem']);
    end


    addedInPorts=0;
    nInBEP=0;
    for portIdx=1:numIn
        inBusData=inportBusData{portIdx};
        if~isempty(inBusData)
            nInBEP=nInBEP+1;
            for i=1:size(inBusData,2)
                addedInPorts=addedInPorts+1;

                bepHdl=add_block(outBEPPath,[wrapperModel,'/Subsystem/',outBEPName],'MakeNameUnique','on');
                outName=get_param(bepHdl,'Name');

                elementName=inBusData{i};
                set_param(bepHdl,'Element',elementName);


                if i==size(inBusData,2)
                    set_param(bepHdl,'PortName',['MyOutBus',int2str(portIdx)]);
                end

                inHdl=add_block(inportPath,[wrapperModel,'/Subsystem/',inportName],'MakeNameUnique','on');
                inName=get_param(inHdl,'Name');

                add_line([wrapperModel,'/Subsystem'],[inName,'/1'],[outName,'/1']);

                add_line(wrapperModel,[recBlockName,'/',int2str(portIdx+addedInPorts-1)],['Subsystem/',int2str(nInBEP+addedInPorts-1)]);
            end
            addedInPorts=addedInPorts-1;

            add_line(wrapperModel,['Subsystem/',int2str(nInBEP)],[modelBlockName,'/',int2str(portIdx)]);
        else

            add_line(wrapperModel,[recBlockName,'/',int2str(portIdx+addedInPorts)],[modelBlockName,'/',int2str(portIdx)]);
        end
    end


    nOutports=numOut;
    if size(outportBusData,1)
        nOutports=str2double(outportBusData{end}{1});
    end


    blockTransHdl=add_block(sFunctionPath,[wrapperModel,'/',transBlockName]);

    if numIn==0


        set_param(modelBlkHdl,'Priority','200');

        set_param(blockHdl,'Priority','100');

        set_param(blockTransHdl,'Priority','300');
    end


    transParameters=['''transmit'',',...
    '''',serverAddress,''',',...
    'uint16([0,0]),',...
    'uint32(0),',...
    'hex2num(''',sampleTimeHexStr,'''),',...
    num2str(timeOut),',',...
    num2str(nOutports),',',...
    outportBusObjNames,',',...
    'logical(ones(1,1))'];

    set_param(blockTransHdl,'FunctionName',sfcnName,'Parameters',transParameters);


    if size(outportBusData,1)
        add_block(subsystemPath,[wrapperModel,'/Subsystem1']);
        Simulink.SubSystem.deleteContents([wrapperModel,'/Subsystem1']);
    end


    addedOutPorts=0;
    nOutBEP=0;
    for portIdx=1:numOut
        outBusData=outportBusData{portIdx};
        if~isempty(outBusData)
            nOutBEP=nOutBEP+1;
            for i=1:size(outBusData,2)
                addedOutPorts=addedOutPorts+1;

                bepHdl=add_block(inBEPPath,[wrapperModel,'/Subsystem1/',inBEPName],'MakeNameUnique','on');
                inName=get_param(bepHdl,'Name');

                elementName=outBusData{i};
                set_param(bepHdl,'Element',elementName);


                if i==size(outBusData,2)
                    set_param(bepHdl,'PortName',['MyInBus',int2str(portIdx)]);
                end

                outHdl=add_block(outportPath,[wrapperModel,'/Subsystem1/',outportName],'MakeNameUnique','on');
                outName=get_param(outHdl,'Name');

                add_line([wrapperModel,'/Subsystem1'],[inName,'/1'],[outName,'/1']);

                add_line(wrapperModel,['Subsystem1/',int2str(nOutBEP+addedOutPorts-1)],[transBlockName,'/',int2str(portIdx+addedOutPorts-1)]);
            end
            addedOutPorts=addedOutPorts-1;

            add_line(wrapperModel,[modelBlockName,'/',int2str(portIdx)],['Subsystem1/',int2str(nOutBEP)]);
        else

            add_line(wrapperModel,[modelBlockName,'/',int2str(portIdx)],[transBlockName,'/',int2str(portIdx+addedOutPorts)]);
        end
    end



    dd=get_param(submdlh,'DataDictionary');
    if~isempty(dd)
        hDict=Simulink.data.dictionary.open(dd);
        configset=hDict.getSection('Configurations');
        childNamesList=configset.evalin('who');
        if isempty(childNamesList)
            setActiveConfigSet(wrapperHandle,get_param(attachConfigSetCopy(wrapperHandle,getActiveConfigSet(submdlh),true),'Name'));
        else
            configsetName=get_param(getActiveConfigSet(submdlh),'SourceName');
            hEntry=configset.getEntry(configsetName);
            slConfigSet=hEntry.getValue();

            setActiveConfigSet(wrapperHandle,get_param(attachConfigSetCopy(wrapperHandle,slConfigSet,true),'Name'));
        end
    else
        setActiveConfigSet(wrapperHandle,get_param(attachConfigSetCopy(wrapperHandle,getActiveConfigSet(submdlh),true),'Name'));
    end



    set_param(wrapperHandle,'ReturnWorkspaceOutputs','on');
    set_param(wrapperHandle,'ReturnWorkspaceOutputsName','cosim__output__');

    if reuseArtifacts
        save_system(wrapperModel);
    end
end

function busElements=getBusElements(busName,prefix)
    busObj=evalin('base',busName);
    nElem=length(busObj.Elements);
    busElements={};
    for i=1:nElem
        elem=busObj.Elements(i);
        if~isempty(prefix)
            name=[prefix,'.',elem.Name];
        else
            name=elem.Name;
        end
        if contains(elem.DataType,'Bus:')
            elem_dt=elem.DataType(6:end);
            busElements=[busElements,getBusElements(elem_dt,name)];
        else
            busElements=[busElements,{name}];
        end
    end
end

function str=convertCellToString(names)
    str='{';
    for i=1:length(names)
        if i~=1
            str=[str,','];
        end
        if isempty(names{i})
            str=[str,'''',''''];
        else
            str=[str,'''',names{i},''''];
        end
    end
    str=[str,'}'];
end
