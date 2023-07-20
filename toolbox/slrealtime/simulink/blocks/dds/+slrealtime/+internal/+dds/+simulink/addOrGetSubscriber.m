function subscriber=addOrGetSubscriber(modelName,blkId,domainPath)












    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);

    participant=slrealtime.internal.dds.simulink.addOrGetDomainParticipant(modelName,domainPath);


    subscriberName=[blkId,'_Sub'];


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
