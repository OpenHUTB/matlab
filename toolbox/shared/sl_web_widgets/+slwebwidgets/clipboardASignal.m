function clipboardIDs=clipboardASignal(rootSigID)





    repo=starepository.RepositoryUtility();
    N_SIGS=length(rootSigID);
    clipboardIDs=-1*ones(1,N_SIGS);


    for kID=1:N_SIGS
        signalNameToCopy=getVariableName(repo,rootSigID(kID));
        simulinkSignal=getSimulinkSignalByID(repo,rootSigID(kID));


        itemFactory=starepository.factory.createSignalItemFactory(signalNameToCopy,simulinkSignal);

        item=itemFactory.createSignalItem;

        eng=sdi.Repository(true);
        jsonStruct=eng.safeTransaction(@starepository.ioitem.initStreaming,{item},'junkfile',0);

        clipboardIDs(kID)=jsonStruct{1}.ID;

        if isfield(jsonStruct{1},'ComplexID')
            clipboardIDs(kID)=jsonStruct{1}.ComplexID;
        end
    end
