function subscriber=addOrGetSubscriber(modelName,portName,domainPath)












    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);

    participant=dds.internal.simulink.addOrGetDomainParticipant(modelName,domainPath);

    mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
    applicationName=mapping.SoftwareArtifactName;

    subscriberName=[applicationName,'_',portName,'_Sub'];

    subscriber=participant.Subscribers{subscriberName};
    if isempty(subscriber)

        subscriber=dds.datamodel.domainparticipant.Subscriber(ddsMf0Model);
        subscriber.Name=subscriberName;
        participant.Subscribers.add(subscriber);

    elseif isempty(subscriber.QosRef)

    else

        subscriber.destroy;
        subscriber=dds.datamodel.domainparticipant.Subscriber(ddsMf0Model);
        subscriber.Name=subscriberName;
        participant.Subscribers.add(subscriber);
    end
end
