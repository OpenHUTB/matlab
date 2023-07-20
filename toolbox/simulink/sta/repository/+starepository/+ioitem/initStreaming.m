function jsonStruct=initStreaming(item,fileName,currentTreeOrderMax)



    jsonStruct={};


    if~isempty(item)

        runTimeRange.Start=[];
        runTimeRange.Stop=[];

        runID=Simulink.sdi.createRun;
        Simulink.sdi.internal.moveRunToApp(runID,'sta',true);


        for k=1:length(item)



            parentSigID=0;
            sigStruct=initializeRepository(item{k},fileName,k,runID,parentSigID,...
            runTimeRange);

            jsonStruct=[jsonStruct,sigStruct];

        end


        cellEmpty=cellfun(@isempty,jsonStruct);
        jsonStruct(cellEmpty)=[];

        repoUtil=starepository.RepositoryUtility();


        for kStruct=1:length(jsonStruct)
            jsonStruct{kStruct}.TreeOrder=currentTreeOrderMax+kStruct;
            setMetaDataByName(repoUtil,jsonStruct{kStruct}.ID,'TreeOrder',jsonStruct{kStruct}.TreeOrder);

            if isfield(jsonStruct{kStruct},'ComplexID')
                setMetaDataByName(repoUtil,jsonStruct{kStruct}.ComplexID,'TreeOrder',jsonStruct{kStruct}.TreeOrder);
            end
        end

    end
