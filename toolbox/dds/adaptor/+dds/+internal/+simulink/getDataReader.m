function dataReader=getDataReader(modelName,readerPath)







    dataReader={};

    dd=get_param(modelName,'DataDictionary');
    if isempty(dd)
        return;
    end

    ddConn=Simulink.data.dictionary.open(dd);
    if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
        return;
    end

    ddsMf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddConn.filepath);

    entities=split(readerPath,"/");

    if length(entities)~=4
        return;
    end
    participantLibraryName=entities{1};
    participantName=entities{2};
    subscriberName=entities{3};
    readerName=entities{4};

    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
    domainParticipantLibraries=systemInModel(1).DomainParticipantLibraries;
    lib=domainParticipantLibraries{participantLibraryName};
    if~isempty(lib)
        participant=lib.DomainParticipants{participantName};
        subscriber=participant.Subscribers{subscriberName};
        dataReader=subscriber.DataReaders{readerName};
    end
end
