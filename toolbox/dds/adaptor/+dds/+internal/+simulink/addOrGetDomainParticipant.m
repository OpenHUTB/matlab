function domainParticipant=addOrGetDomainParticipant(modelName,domainPath)













    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);

    participantLib=dds.internal.simulink.addOrGetDomainParticipantLibrary(modelName);

    domainEntities=split(domainPath,'/');
    domainLibName=domainEntities{1};
    domainName=domainEntities{2};

    mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
    applicationName=mapping.SoftwareArtifactName;

    domain=dds.internal.simulink.Util.getDomain(modelName,domainLibName,domainName);
    participantName=[applicationName,'_',num2str(domain.DomainID)];

    needToCreate=true;

    domainParticipant=participantLib.DomainParticipants{participantName};
    if~isempty(domainParticipant)

        isMismatch=~isempty(domainParticipant.QosRef)...
        ||~isequal(domainParticipant.DomainRef.DomainID,domain.DomainID);
        needToCreate=isMismatch;
        if isMismatch
            domainParticipant.destroy;
        end
    end

    if needToCreate
        systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
        domainLibRef=systemInModel(1).DomainLibraries{domainLibName};
        domainRef=domainLibRef.Domains{domainName};
        domainParticipant=dds.datamodel.domainparticipant.DomainParticipant(ddsMf0Model);
        domainParticipant.Name=participantName;
        domainParticipant.DomainLibraryRef=domainLibRef;
        domainParticipant.DomainRef=domainRef;
        participantLib.DomainParticipants.add(domainParticipant);
    end
end

