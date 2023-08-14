function dataWriter=addOrGetDataWriter(modelName,blockName,topicPath,qosPath)












    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);

    [domainLibName,domainName,topicName]=...
    dds.internal.simulink.Util.getDDSPartitionedTopics(topicPath);
    domainPath=[domainLibName,'/',domainName];
    publisher=slrealtime.internal.dds.simulink.addOrGetPublisher(modelName,blockName,domainPath);
    writerName=[blockName,'_Writer'];

    dataWriter=publisher.DataWriters{writerName};

    if~isempty(dataWriter)
        dataWriter.destroy();
    end


    domainLibRef=systemInModel(1).DomainLibraries{domainLibName};
    domainRef=domainLibRef.Domains{domainName};
    topicRef=domainRef.Topics{topicName};
    qosRef=dds.internal.simulink.Util.getQoS(modelName,qosPath,false);

    dataWriter=dds.datamodel.domainparticipant.DataWriter(ddsMf0Model);
    dataWriter.Name=writerName;

    if~isempty(qosPath)
        dataWriter.QosRef=qosRef;
    end

    dataWriter.TopicRef=topicRef;

    publisher.DataWriters.add(dataWriter);

end


