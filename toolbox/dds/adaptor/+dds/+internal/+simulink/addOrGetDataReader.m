function dataReader=addOrGetDataReader(modelName,portName,topicPath,qosPath,...
    filterKind,filterExpression,filterParameterList)












    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);

    [domainLibName,domainName,topicName]=...
    dds.internal.simulink.Util.getDDSPartitionedTopics(topicPath);
    domainPath=[domainLibName,'/',domainName];
    subscriber=dds.internal.simulink.addOrGetSubscriber(modelName,portName,domainPath);
    readerName=[portName,'_Reader'];

    dataReader=subscriber.DataReaders{readerName};

    if~isempty(dataReader)
        dataReader.destroy();
    end


    domainLibRef=systemInModel(1).DomainLibraries{domainLibName};
    domainRef=domainLibRef.Domains{domainName};
    topicRef=domainRef.Topics{topicName};

    qosRef=dds.internal.simulink.Util.getQoS(modelName,qosPath,true);

    dataReader=dds.datamodel.domainparticipant.DataReader(ddsMf0Model);
    dataReader.Name=readerName;

    if~isempty(qosPath)
        dataReader.QosRef=qosRef;
    end


    if~isempty(filterKind)&&~isempty(filterExpression)
        filter=dds.datamodel.domainparticipant.Filter(ddsMf0Model);
        filter.Name=[readerName,'_filter'];
        if strcmp(filterKind,'SQL')
            filter.Kind=dds.datamodel.domainparticipant.ddstypes.FilterKind.builtin_sql;
        else
            filter.Kind=dds.datamodel.domainparticipant.ddstypes.FilterKind.builtin_stringMatch;
        end
        filter.Expression=filterExpression;
        paramList=split(filterParameterList,newline);
        for i=1:numel(paramList)

            param=strip(paramList{i});
            if~isempty(param)
                filter.ParameterList.add(param);
            end
        end
        dataReader.ContentFilter=filter;
    end

    dataReader.TopicRef=topicRef;

    subscriber.DataReaders.add(dataReader);

end
