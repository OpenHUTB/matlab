function dataWriter=getDataWriter(modelName,writerPath)







    dataWriter={};

    dd=get_param(modelName,'DataDictionary');
    if isempty(dd)
        return;
    end

    ddConn=Simulink.data.dictionary.open(dd);
    if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
        return;
    end

    ddsMf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddConn.filepath);

    entities=split(writerPath,"/");

    if length(entities)~=4
        return;
    end
    participantLibraryName=entities{1};
    participantName=entities{2};
    publisherName=entities{3};
    writerName=entities{4};

    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
    domainParticipantLibraries=systemInModel(1).DomainParticipantLibraries;
    lib=domainParticipantLibraries{participantLibraryName};
    if~isempty(lib)
        participant=lib.DomainParticipants{participantName};
        publisher=participant.Publishers{publisherName};
        dataWriter=publisher.DataWriters{writerName};
    end
end
