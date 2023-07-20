function exportToXMLBasedOnModel(xmlFilePath,modelName)%#ok<INUSL>





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


    profiles=struct();
    profiles.participant=[];
    [profiles.publisher,profiles.participant]=getPublisherList(modelName,profiles.participant);
    [profiles.subscriber,profiles.participant]=getSubscriberList(modelName,profiles.participant);


    dds=struct();
    dds.profiles=profiles;


    writestruct(dds,xmlFilePath,...
    'StructNodeName','dds',...
    'AttributeSuffix',getAttrExt());

end


function[publisherList,participantList]=getPublisherList(modelName,participantList)
    publisherList=[];


    dataWriterPaths=slrealtime.internal.dds.utils.BlockProperties.getParametersFromAllBlocks(modelName,...
    'send',...
    'DataWriterPath');
    uniqueDataWriterPaths=unique(dataWriterPaths);

    for k=1:length(uniqueDataWriterPaths)
        dataWriterPath=uniqueDataWriterPaths{k};
        dataWriter=dds.internal.simulink.getDataWriter(modelName,dataWriterPath);
        participantName=dds.internal.getFullNameUpto(dataWriter.Container.Container,'dds.datamodel.system.System');
        participantList=checkAndAddParticipantForDomain(participantList,participantName,dataWriter.TopicRef.Container.DomainID);
        publisherName=dds.internal.getFullNameUpto(dataWriter,'dds.datamodel.domainparticipant.DomainParticipant');
        publisherList=checkAndTopicAndQosEnt(publisherList,publisherName,dataWriter.TopicRef,dataWriter.QosRef);
    end
end


function[subscriberList,participantList]=getSubscriberList(modelName,participantList)
    subscriberList=[];


    dataReaderPaths=slrealtime.internal.dds.utils.BlockProperties.getParametersFromAllBlocks(modelName,...
    'recv',...
    'DataReaderPath');
    uniqueDataReaderPaths=unique(dataReaderPaths);
    for k=1:length(uniqueDataReaderPaths)
        dataReaderPath=uniqueDataReaderPaths{k};
        dataReader=dds.internal.simulink.getDataReader(modelName,dataReaderPath);
        participantName=dds.internal.getFullNameUpto(dataReader.Container.Container,'dds.datamodel.system.System');
        participantList=checkAndAddParticipantForDomain(participantList,participantName,dataReader.TopicRef.Container.DomainID);
        subscriberName=dds.internal.getFullNameUpto(dataReader,'dds.datamodel.domainparticipant.DomainParticipant');
        subscriberList=checkAndTopicAndQosEnt(subscriberList,subscriberName,dataReader.TopicRef,dataReader.QosRef);
    end
end


function participantEnt=createParticipantFor(participantName,domainIdStr)
    participantEnt=struct(getAttrFieldName('profile_name'),participantName,'domainId',domainIdStr,'rtps','');
    participantEnt.rtps=struct('builtin','');
    participantEnt.rtps.builtin=struct('discovery_config','');
    participantEnt.rtps.builtin.discovery_config=struct('leaseDuration','');
    participantEnt.rtps.builtin.discovery_config.leaseDuration=struct('sec','DURATION_INFINITY');
end


function participantList=checkAndAddParticipantForDomain(participantList,participantName,domainId)
    found=false;
    domainIdStr=dds.internal.simulink.Util.convertToStr(domainId);
    fldName=getAttrFieldName('profile_name');
    for i=1:numel(participantList)
        found=isequal(participantList(i).(fldName),participantName)&&isequal(participantList(i).domainId,domainIdStr);
        if found
            break;
        end
    end
    if~found
        participantEnt=createParticipantFor(participantName,domainIdStr);
        if isempty(participantList)
            participantList=participantEnt;
        else
            participantList=[participantList,participantEnt];
        end
    end
end


function pubSubList=checkAndTopicAndQosEnt(pubSubList,name,topicRef,qosRef)
    found=false;
    fldName=getAttrFieldName('profile_name');
    for i=1:numel(pubSubList)
        found=isequal(pubSubList(i).(fldName),name);
        if found
            break;
        end
    end
    if~found
        pubSubEnt=struct(getAttrFieldName('profile_name'),name,'topic','','qos','');
        [pubSubEnt.topic,pubSubEnt.qos]=createTopicAndQos(topicRef,qosRef);
        if isempty(fieldnames(pubSubEnt.qos))
            pubSubEnt.qos=[];
        end
        if isempty(pubSubList)
            pubSubList=pubSubEnt;
        else
            pubSubList=[pubSubList,pubSubEnt];
        end
    end
end


function[topic,qos]=createTopicAndQos(topicRef,qosRef)
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
    topicName=topicRef.Name;
    dataType=dds.internal.getFullNameForType(topicRef.RegisterTypeRef.TypeRef,'::');
    typeMembers=topicRef.RegisterTypeRef.TypeRef.Members;
    topic=struct('name',topicName,'dataType',dataType,'kind','NO_KEY');
    for i=1:size(typeMembers)
        if typeMembers{uint64(i)}.Key
            topic.kind='WITH_KEY';
            break;
        end
    end
    if~isempty(qosRef)&&~isempty(qosRef.History)
        qosHistoryStr=char(qosRef.History.Kind);
        if strcmp(qosHistoryStr,'KEEP_LAST_HISTORY_QOS')
            qosHistoryStr='KEEP_LAST';
        elseif strcmp(qosHistoryStr,'KEEP_ALL_HISTORY_QOS')
            qosHistoryStr='KEEP_ALL';
        end
        historyQos=struct('kind',qosHistoryStr,'depth',dds.internal.simulink.Util.convertToStr(qosRef.History.Depth));
        topic.historyQos=historyQos;
    end

    qos=struct();

    if~isempty(qosRef)&&~isempty(qosRef.Durability)
        durabilityKindStr=char(qosRef.Durability.Kind);
        durabilityKindStruct='';
        if strcmp(qosHistoryStr,'TRANSIENT_LOCAL_DURABILITY_QOS')
            durabilityKindStruct=struct('kind','TRANSIENT_LOCAL');
        elseif strcmp(durabilityKindStr,'TRANSIENT_DURABILITY_QOS')
            durabilityKindStruct=struct('kind','TRANSIENT');
        elseif strcmp(durabilityKindStr,'VOLATILE_DURABILITY_QOS')
            durabilityKindStruct=struct('kind','VOLATILE');
        end
        qos.durability=durabilityKindStruct;
    end

    if~isempty(qosRef)&&~isempty(qosRef.Reliability)
        reliabilityKindStruct='';
        reliabilityKindStr=char(qosRef.Reliability.Kind);
        if strcmp(reliabilityKindStr,'RELIABLE_RELIABILITY_QOS')
            reliabilityKindStruct=struct('kind','RELIABLE');
        elseif strcmp(reliabilityKindStr,'BEST_EFFORT_RELIABILITY_QOS')
            reliabilityKindStruct=struct('kind','BEST_EFFORT');
        end
        qos.reliability=reliabilityKindStruct;
    end
end


function attrFldName=getAttrFieldName(attrName)
    attrFldName=[attrName,getAttrExt()];
end


function attrExt=getAttrExt()
    attrExt='__attr';
end
