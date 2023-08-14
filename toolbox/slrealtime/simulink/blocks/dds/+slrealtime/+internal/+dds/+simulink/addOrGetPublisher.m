function publisher=addOrGetPublisher(modelName,blkId,domainPath)












    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);

    participant=slrealtime.internal.dds.simulink.addOrGetDomainParticipant(modelName,domainPath);

    publisherName=[blkId,'_Pub'];

    publisher=participant.Publishers{publisherName};
    if isempty(publisher)

        publisher=dds.datamodel.domainparticipant.Publisher(ddsMf0Model);
        publisher.Name=publisherName;
        participant.Publishers.add(publisher);

    elseif isempty(publisher.QosRef)

    else

        publisher.destroy;
        publisher=dds.datamodel.domainparticipant.Publisher(ddsMf0Model);
        publisher.Name=publisherName;
        participant.Publishers.add(publisher);
    end
end
