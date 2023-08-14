function domainParticipantLibrary=addOrGetDomainParticipantLibrary(modelName)










    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);

    libName=[modelName,'_Library'];

    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
    if isempty(systemInModel)
        return;
    end
    domainParticipantLibraries=systemInModel(1).DomainParticipantLibraries;

    lib=domainParticipantLibraries{libName};
    if~isempty(lib)
        domainParticipantLibrary=lib;
        return;
    end


    domainParticipantLibrary=dds.datamodel.domainparticipant.DomainParticipantLibrary(ddsMf0Model);
    domainParticipantLibrary.Name=libName;
    systemInModel.DomainParticipantLibraries.add(domainParticipantLibrary);
end


