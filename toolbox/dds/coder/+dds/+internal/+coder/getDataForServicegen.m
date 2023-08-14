function data=getDataForServicegen(codeDescriptor,bdir,buildInfo,xmlFiles)






    data=struct;



    data.buildDir=bdir;
    data.xmlFiles=xmlFiles;


    data.mainFileName='main.cpp';
    data.typesFileName=dds.internal.simulink.Util.getDDSTypesHeaderFileName();
    data.modelName=codeDescriptor.ModelName;
    data.typedefPairs=dds.internal.simulink.Util.getDDSTypedefPairs(data.modelName);
    data.namespaces=dds.internal.simulink.Util.getNamespaces(data.modelName);


    internalDatas=codeDescriptor.getFullComponentInterface.InternalData;
    data.modelClassObjectName=internalDatas(1).Implementation.Identifier;
    data.modelClassName=internalDatas(1).Implementation.Type.Identifier;

    schedule=get_param(data.modelName,"Schedule");


    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(data.modelName);
    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
    data.usingShortName=dds.internal.isSystemUsingShortName(ddsMf0Model);


    dataEventInfo=dds.internal.coder.DataEventInfo;


    [data.compName,data.vendorName,data.vendorKey]=...
    dds.internal.simulink.Util.getCurrentMapSetting(data.modelName);
    reg=dds.internal.vendor.DDSRegistry;
    regEnt=reg.getEntryFor(data.vendorKey);
    data.vendorDisplayName=regEnt.DisplayName;
    data.vendorDefaultToolchain=regEnt.DefaultToolchain;
    data.vendorAnnotationKey=regEnt.AnnotationKey;


    inports=codeDescriptor.getDataInterfaces('Inports');
    data.includes={};
    data.inportInfos=[];
    data.outportInfos=[];
    existingPortNames={};
    data.modelConstrArgs={};
    data.participants={};

    for inport=inports
        type=inport.Type.BaseType.Methods(1).Arguments(1).BaseType.Identifier;
        if inport.isMessageDataInterface()

            graphicalName=inport.GraphicalName;
            [participantLibrary,participant,subscriber,ddsReader]=...
            dds.internal.coder.getDDSMapping(...
            data.modelName,strcat(data.modelName,'/',graphicalName),true);
            dataReaderPath=strjoin({participantLibrary,participant,subscriber,ddsReader},'/');
            theReader=dds.internal.simulink.getDataReader(data.modelName,dataReaderPath);
            topicPath=dds.internal.simulink.Util.getTopicPath(ddsMf0Model,theReader.TopicRef);
            [domainLib,domain,topic]=dds.internal.simulink.Util.getDDSPartitionedTopics(topicPath);
            qosPath='';
            if~isempty(theReader.QosRef)
                qosPath=dds.internal.simulink.Util.getQoSPath(ddsMf0Model,theReader.QosRef);
            end
            portName=dds.internal.coder.Util.genCppVarName(strcat(...
            subscriber,'_',ddsReader,'_','RecvData_arg'),existingPortNames);
            existingPortNames{end+1}=portName;%#ok<AGROW>
            data.modelConstrArgs{inport.CorrespondingConstructorArgIndex}=portName;
            inportInfo=struct('graphicalName',graphicalName,...
            'participantLibrary',participantLibrary,...
            'participant',participant,...
            'subscriber',subscriber,...
            'ddsReader',ddsReader,...
            'portName',portName,...
            'type',type,...
            'baseType',inport.Type.BaseType.Identifier,...
            'topicPath',topicPath,...
            'domainLib',domainLib,...
            'domain',domain,...
            'topic',topic,...
            'contentFilter',[],...
            'qosPath',qosPath,...
            'qosIdx',-1);
            if~isempty(theReader.ContentFilter)
                filter=struct('name',theReader.ContentFilter.Name,...
                'kind',char(theReader.ContentFilter.Kind),...
                'expression',theReader.ContentFilter.Expression,...
                'parameterList','');
                if theReader.ContentFilter.ParameterList.Size>0
                    paramList=cell(1,theReader.ContentFilter.ParameterList.Size);
                    for jj=1:theReader.ContentFilter.ParameterList.Size
                        val=theReader.ContentFilter.ParameterList(jj);
                        paramList=val{1};
                    end
                    filter.parameterList=paramList;
                else
                    filter.parameterList={};
                end
                inportInfo.contentFilter=filter;
            end
            if isempty(data.inportInfos)
                data.inportInfos=inportInfo;
            else
                data.inportInfos(end+1)=inportInfo;
            end
            participantPath=[participantLibrary,'::',participant];
            if~ismember(participantPath,data.participants)
                data.participants{end+1}=participantPath;
            end
        end
    end
    outports=codeDescriptor.getDataInterfaces('Outports');
    for outport=outports


        type=outport.Type.BaseType.Methods(1).Arguments(1).BaseType.Identifier;
        if outport.isMessageDataInterface()
            graphicalName=outport.GraphicalName;
            [participantLibrary,participant,publisher,ddsWriter]=...
            dds.internal.coder.getDDSMapping(...
            data.modelName,strcat(data.modelName,'/',graphicalName),false);
            dataWriterPath=strjoin({participantLibrary,participant,publisher,ddsWriter},'/');
            theWriter=dds.internal.simulink.getDataWriter(data.modelName,dataWriterPath);
            topicPath=dds.internal.simulink.Util.getTopicPath(ddsMf0Model,theWriter.TopicRef);
            [domainLib,domain,topic]=dds.internal.simulink.Util.getDDSPartitionedTopics(topicPath);
            qosPath='';
            if~isempty(theWriter.QosRef)
                qosPath=dds.internal.simulink.Util.getQoSPath(ddsMf0Model,theWriter.QosRef);
            end
            portName=dds.internal.coder.Util.genCppVarName(...
            strcat(publisher,'_',ddsWriter,'_','SendData_arg'),existingPortNames);
            existingPortNames{end+1}=portName;%#ok<AGROW>
            data.modelConstrArgs{outport.CorrespondingConstructorArgIndex}=portName;
            outportInfo=struct('graphicalName',graphicalName,...
            'participantLibrary',participantLibrary,...
            'participant',participant,...
            'publisher',publisher,...
            'ddsWriter',ddsWriter,...
            'portName',portName,...
            'type',type,...
            'baseType',outport.Type.BaseType.Identifier,...
            'topicPath',topicPath,...
            'domainLib',domainLib,...
            'domain',domain,...
            'topic',topic,...
            'qosPath',qosPath,...
            'qosIdx',-1);
            if isempty(data.outportInfos)
                data.outportInfos=outportInfo;
            else
                data.outportInfos(end+1)=outportInfo;
            end
            participantPath=[participantLibrary,'::',participant];
            if~ismember(participantPath,data.participants)
                data.participants{end+1}=participantPath;
            end
        end
    end


    functions={codeDescriptor.getFunctionInterfaces('Output'),...
    codeDescriptor.getFunctionInterfaces('Initialize'),...
    codeDescriptor.getFunctionInterfaces('Terminate')};
    headersRemaining=0;
    for ii=1:numel(functions)
        headersRemaining=headersRemaining+length(functions{ii});
    end
    headers=cell(1,headersRemaining);
    for ii=1:numel(functions)
        func=functions{ii};
        for jj=1:numel(func)
            proto=func(jj).Prototype;
            headers{headersRemaining}=proto.HeaderFile;
            headersRemaining=headersRemaining-1;
        end
    end

    if~isempty(headers)
        headers=unique(headers);
        data.includes=[data.includes,headers];
    end


    data.xmlFileName=dds.internal.coder.getXmlFileName(data.modelName,buildInfo);


    if~isempty(data.inportInfos)
        data.intypes=unique({data.inportInfos(:).type});
    else
        data.intypes=[];
    end
    if~isempty(data.outportInfos)
        data.outtypes=unique({data.outportInfos(:).type});
    else
        data.outtypes=[];
    end
    types=unique([data.intypes,data.outtypes]);
    data.registerTypes=[];
    for ii=1:length(types)
        typeName=types{ii};
        ddsType=dds.internal.simulink.Util.getDDSType(data.modelName,typeName);
        registerTypeRefs=ddsType.RegisterTypeRefs;
        for j=1:registerTypeRefs.Size
            registerTypeName=registerTypeRefs(j).Name;
            if~isempty(registerTypeRefs(j).OriginalName)
                registerTypeName=registerTypeRefs(j).OriginalName;
            end
            inportIdx=[];
            if~isempty(data.inportInfos)
                inportIdx=find(strcmp(typeName,{data.inportInfos(:).type}));
            end
            outportIdx=[];
            if~isempty(data.outportInfos)
                outportIdx=find(strcmp(typeName,{data.outportInfos(:).type}));
            end
            origName=typeName;
            if~isempty(data.typedefPairs)

                origIdx=find(strcmp(typeName,{data.typedefPairs(:).destType}));
                if~isempty(origIdx)
                    origName=data.typedefPairs(origIdx).origType;
                end
            end
            if~isempty(inportIdx)
                participantLibs={data.inportInfos(inportIdx).participantLibrary};
                participants={data.inportInfos(inportIdx).participant};
            else
                participantLibs={};
                participants={};
            end
            if~isempty(outportIdx)
                participantLibs=[participantLibs,{data.outportInfos(outportIdx).participantLibrary}];%#ok<AGROW> 
                participants=[participants,{data.outportInfos(outportIdx).participant}];%#ok<AGROW> 
            end

            assert(numel(participantLibs)==numel(participants));
            if~isempty(participantLibs)
                participantLst=cell(1,numel(participantLibs));
                for k=1:numel(participantLibs)
                    participantLst{k}=[participantLibs{k},'::',participants{k}];
                end
                [~,participantLstIdx]=unique(participantLst);
                participantLibs=participantLibs(participantLstIdx);
                participants=participants(participantLstIdx);
            end
            typeInfo=struct('typeName',typeName,...
            'registerType',registerTypeName,...
            'origName',origName,...
            'inportIdx',inportIdx,'outportIdx',outportIdx,...
            'participantLibs','','participants','');
            typeInfo.participantLibs=participantLibs;
            typeInfo.participants=participants;
            if isempty(data.registerTypes)
                data.registerTypes=typeInfo;
            else
                data.registerTypes(end+1)=typeInfo;
            end
        end
    end


    data.subscriberInfos=[];
    data.publisherInfos=[];
    data.intopics=[];
    data.outtopics=[];
    if~isempty(data.inportInfos)
        data.intopics=unique({data.inportInfos(:).topicPath});
        subscribers=unique({data.inportInfos(:).subscriber});


        for ii=1:length(subscribers)
            subscriber=subscribers{ii};
            inportIdx=find(strcmp(subscriber,{data.inportInfos(:).subscriber}));
            subInfo=struct('subscriber',subscriber,'inportIdx',inportIdx);
            if isempty(data.subscriberInfos)
                data.subscriberInfos=subInfo;
            else
                data.subscriberInfos(end+1)=subInfo;
            end
        end
    end
    if~isempty(data.outportInfos)
        data.outtopics=unique({data.outportInfos(:).topicPath});
        publishers=unique({data.outportInfos(:).publisher});
        for ii=1:length(publishers)
            publisher=publishers{ii};
            outportIdx=find(strcmp(publisher,{data.outportInfos(:).publisher}));
            pubInfo=struct('publisher',publisher,'outportIdx',outportIdx);
            if isempty(data.publisherInfos)
                data.publisherInfos=pubInfo;
            else
                data.publisherInfos(end+1)=pubInfo;
            end
        end
    end


    topics=unique([data.intopics,data.outtopics]);
    data.topicInfos=[];
    data.domainInfos=[];
    for ii=1:length(topics)
        topicPath=topics{ii};
        [domainLib,domain,topic]=dds.internal.simulink.Util.getDDSPartitionedTopics(topicPath);
        inportIdx=[];
        if~isempty(data.inportInfos)
            inportIdx=find(strcmp(topicPath,{data.inportInfos(:).topicPath}));
        end
        outportIdx=[];
        if~isempty(data.outportInfos)
            outportIdx=find(strcmp(topicPath,{data.outportInfos(:).topicPath}));
        end
        domainLibs=systemInModel(1).DomainLibraries;
        theDomainLib=domainLibs{domainLib};
        theDomain=theDomainLib.Domains{domain};

        topicInfo=struct('topicPath',topicPath,...
        'domainLib',domainLib,...
        'domain',domain,...
        'topic',topic,...
        'inportIdx',inportIdx,'outportIdx',outportIdx);
        if isempty(data.topicInfos)
            data.topicInfos=topicInfo;
        else
            data.topicInfos(end+1)=topicInfo;
        end

        domainInfo=struct('domainLibraryName',theDomainLib.Name,...
        'domainName',theDomain.Name,...
        'domainID',theDomain.DomainID);
        if isempty(data.domainInfos)
            data.domainInfos=domainInfo;
        else
            data.domainInfos(end+1)=domainInfo;
        end

    end


    data.qosInfos=struct('participant',[],...
    'publisher',[],...
    'subscriber',[],...
    'datareader',[],...
    'datawriter',[],...
    'topic',[]);
    for ii=1:numel(data.inportInfos)
        thePortInfo=data.inportInfos(ii);
        isBuiltIn=dds.internal.simulink.Util.isBuiltInQoS(ddsMf0Model,thePortInfo.qosPath,data.vendorAnnotationKey);
        nameToUse=thePortInfo.qosPath;
        if isBuiltIn
            nameToUse=fileparts(nameToUse);
        end
        nameToUse=strrep(nameToUse,'/','.');
        theQos=dds.internal.simulink.Util.getQoS(data.modelName,thePortInfo.qosPath,true);
        dataReaderInfo=struct('path',thePortInfo.qosPath,...
        'builtIn',isBuiltIn,...
        'nameToUse',nameToUse,...
        'portIdx',ii,...
        'deadline',[],...
        'destination_order',[],...
        'durability',[],...
        'liveliness',[],...
        'history',[],...
        'ownership',[],...
        'reliability',[],...
        'resource_limits',[]);
        dataReaderInfo=fillQosInfo(dataReaderInfo,theQos);
        if isempty(data.qosInfos.datareader)
            data.qosInfos.datareader=dataReaderInfo;
        else
            data.qosInfos.datareader(end+1)=dataReaderInfo;
        end
        data.inportInfos(ii).qosIdx=numel(data.qosInfos.datareader);
    end

    for ii=1:numel(data.outportInfos)
        thePortInfo=data.outportInfos(ii);
        isBuiltIn=dds.internal.simulink.Util.isBuiltInQoS(ddsMf0Model,thePortInfo.qosPath,data.vendorAnnotationKey);
        nameToUse=thePortInfo.qosPath;
        if isBuiltIn
            nameToUse=fileparts(nameToUse);
        end
        nameToUse=strrep(nameToUse,'/','.');
        theQos=dds.internal.simulink.Util.getQoS(data.modelName,thePortInfo.qosPath,false);
        dataWriterInfo=struct('path',thePortInfo.qosPath,...
        'builtIn',isBuiltIn,...
        'nameToUse',nameToUse,...
        'portIdx',ii,...
        'deadline',[],...
        'destination_order',[],...
        'durability',[],...
        'liveliness',[],...
        'history',[],...
        'ownership',[],...
        'reliability',[],...
        'resource_limits',[]);
        dataWriterInfo=fillQosInfo(dataWriterInfo,theQos);
        if isempty(data.qosInfos.datawriter)
            data.qosInfos.datawriter=dataWriterInfo;
        else
            data.qosInfos.datawriter(end+1)=dataWriterInfo;
        end
        data.outportInfos(ii).qosIdx=numel(data.qosInfos.datawriter);
    end



    outputFcns=codeDescriptor.getFunctionInterfaces('Output');
    [periodicIndexes,aperiodicIndexes,asynchronousIndexes,unknownIndexes]=dds.internal.coder.InputEventServiceInfo.findOutputFunctionIndex(outputFcns);

    periodicFunctions=outputFcns(periodicIndexes);
    aperiodicFunctions=outputFcns(aperiodicIndexes);


    data.subRateTicks=[];
    data.periodicFcnInfos=[];
    data.usingDataEvents=false;
    aperiodicTicks=[];
    periodicTicks=[];
    if~isempty(aperiodicFunctions)
        data.baserate=periodicFunctions(1).Timing.SamplePeriod;
        for ii=length(aperiodicFunctions):-1:1
            [aperiodicTicks,data,fcnInfo]=gatherFunctionSchedule(aperiodicFunctions(ii),data,schedule,ii);
            if isempty(data.periodicFcnInfos)
                data.periodicFcnInfos=fcnInfo;
            else
                data.periodicFcnInfos(end+1)=fcnInfo;
            end
        end
    end

    if~isempty(periodicFunctions)
        data.baserate=periodicFunctions(1).Timing.SamplePeriod;
        for ii=length(periodicFunctions):-1:1
            [periodicTicks,data,fcnInfo]=gatherFunctionSchedule(periodicFunctions(ii),data,schedule,ii);
            if isempty(data.periodicFcnInfos)
                data.periodicFcnInfos=fcnInfo;
            else
                data.periodicFcnInfos(end+1)=fcnInfo;
            end
        end
    end


    if isempty(periodicFunctions)&&isempty(aperiodicFunctions)


        data.baserate=0.2000;
    else
        ticks=cat(2,aperiodicTicks,periodicTicks);
        data.tick_lcm=lcms(ticks);

    end

    data.periodicFcnInfos=flip(data.periodicFcnInfos);


    initializeFcns=codeDescriptor.getFunctionInterfaces('Initialize');
    data.initializeFcns=cell(1,numel(initializeFcns));
    for ii=1:numel(initializeFcns)
        data.initializeFcns{ii}=initializeFcns(ii).Prototype.Name;
    end
    asynchronousFcns=outputFcns(asynchronousIndexes);
    data.asynchronousFcns=cell(1,numel(asynchronousFcns));
    for ii=1:numel(asynchronousFcns)
        data.asynchronousFcns{ii}=asynchronousFcns(ii).Prototype.Name;
    end
    unknownFcns=outputFcns(unknownIndexes);
    data.unknownFcns=cell(1,numel(unknownFcns));
    for ii=1:numel(unknownFcns)
        data.unknownFcns{ii}=unknownFcns(ii).Prototype.Name;
    end
    terminateFcns=codeDescriptor.getFunctionInterfaces('Terminate');
    data.terminateFcns=cell(1,numel(terminateFcns));
    for ii=1:numel(terminateFcns)
        data.terminateFcns{ii}=terminateFcns(ii).Prototype.Name;
    end
end


function result=lcms(rates)
    while(1<length(rates))
        rates=lcm(rates(1),rates(2:end));
    end
    result=rates;
end


function[inportIdx,eventType,eventNotification]=getTriggerInfo(data,schedule,periodicFcn)
    inportIdx=[];
    eventType='';
    eventNotification='';
    if isempty(data.inportInfos)
        return;
    end
    partitionName=periodicFcn.Timing.NonFcnCallPartitionName;
    for ii=1:length(schedule.Events)
        event=schedule.Events(ii);
        for jj=1:length(event.Listeners)
            listener=event.Listeners(jj);
            if listener==partitionName
                eventName=convertStringsToChars(event.Name);
                dei=dds.internal.coder.DataEventInfo;
                [eventType,eventNotification,inportIdx]=dei.getEvent(data.inportInfos,data.modelName,eventName);
            end
        end
    end
end


function[ticks,data,fcnInfo]=gatherFunctionSchedule(functionDescription,data,schedule,ii)
    ticksPerCall=round(functionDescription.Timing.SamplePeriod/data.baserate);
    fcnInfo.name=functionDescription.Prototype.Name;
    subRateTick=struct('name',functionDescription.Prototype.Name,'ticksPerCall',ticksPerCall);
    if isempty(data.subRateTicks)
        data.subRateTicks=subRateTick;
    else
        data.subRateTicks(end+1)=subRateTick;
    end
    ticks(ii)=ticksPerCall;

    fcnInfo.triggered=dds.internal.coder.InputEventServiceInfo.isTriggeredFunction(functionDescription);
    if fcnInfo.triggered
        [fcnInfo.inportIdx,fcnInfo.eventType,fcnInfo.eventNotification]=...
        getTriggerInfo(data,schedule,functionDescription);
        data.usingDataEvents=true;
    else
        fcnInfo.inportIdx=-1;
        fcnInfo.eventType='';
        fcnInfo.eventNotification='';
    end
end




function qosInfo=fillQosInfo(qosInfo,theQos)
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    function secAndNano=getDuration(element)
        if isempty(element)
            secAndNano=[];
        else
            secAndNano=struct('sec','','nanosec','');
            if element.Sec.Unlimited
                secAndNano.sec='DURATION_INFINITE_SEC';
            else
                secAndNano.sec=sprintf('%d',element.Sec.Value);
            end
            if element.NanoSec.Unlimited
                secAndNano.nanosec='DURATION_INFINITE_NSEC';
            else
                secAndNano.nanosec=sprintf('%d',element.NanoSec.Value);
            end
        end
    end
    function len=getPostiveLen(element)
        if isempty(element)
            len=[];
        else
            if element.Unlimited
                len='LENGTH_UNLIMITED';
            else
                len=sprintf('%d',element.Value);
            end
        end
    end

    if isempty(theQos)
        return;
    end
    if~isempty(theQos.Deadline)
        qosInfo.deadline.period=getDuration(theQos.Deadline.Period);
    end
    if~isempty(theQos.DestinationOrder)
        qosInfo.destination_order.kind=char(theQos.DestinationOrder.Kind);
    end
    if~isempty(theQos.Durability)
        qosInfo.durability.kind=char(theQos.Durability.Kind);
    end
    if~isempty(theQos.Liveliness)
        qosInfo.liveliness.kind=char(theQos.Liveliness.Kind);
        qosInfo.liveliness.lease_duration=getDuration(theQos.Liveliness.LeaseDuration);
    end
    if~isempty(theQos.History)
        qosInfo.history.kind=char(theQos.History.Kind);
        qosInfo.history.depth=theQos.History.Depth;
    end
    if~isempty(theQos.Ownership)
        qosInfo.ownership.kind=char(theQos.Ownership.Kind);
    end
    if~isempty(theQos.Reliability)
        qosInfo.reliability.kind=char(theQos.Reliability.Kind);
        qosInfo.reliability.max_blocking_time=getDuration(theQos.Reliability.MaxBlockingTime);
    end
    if~isempty(theQos.ResourceLimits)
        qosInfo.resource_limits.max_samples=getPostiveLen(theQos.ResourceLimits.MaxSamples);
        qosInfo.resource_limits.max_instances=getPostiveLen(theQos.ResourceLimits.MaxInstances);
        qosInfo.resource_limits.max_samples_per_instance=getPostiveLen(theQos.ResourceLimits.MaxSamplesPerInstance);
    end
end
