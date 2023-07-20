function publisher=addOrGetPublisher(modelName,portName,domainPath)












    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);

    participant=dds.internal.simulink.addOrGetDomainParticipant(modelName,domainPath);

    mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
    applicationName=mapping.SoftwareArtifactName;
    publisherName=[applicationName,'_',portName,'_Pub'];

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
