function outMsg=mappingStartup(inputSpecID,jsonStruct,varargin)





    outMsg=struct;

    repoSpec=sta.InputSpecification(inputSpecID);

    legacy_behavior=true;

    if length(varargin)>0
        legacy_behavior=varargin{1};
    end



    if~isempty(jsonStruct)

        mapIds=repoSpec.getInputMapIDs;


        sigNames=cell(1,length(jsonStruct));

        idxToRemove=-1*ones(1,length(jsonStruct));

        for kJson=1:length(jsonStruct)
            if isMappable(jsonStruct,jsonStruct{kJson}.ParentID)
                sigNames{kJson}=jsonStruct{kJson}.Name;
            else
                idxToRemove(kJson)=kJson;
            end
        end


        sigNames(cellfun(@isEmptyAndNotString,sigNames))=[];


        idxToRemove(idxToRemove==-1)=[];

        if~isempty(idxToRemove)
            jsonStruct(idxToRemove)=[];
        end



        [FOUND_DATASET,jsonStruct,sigNames,dsID]=filterInputsForDataset(jsonStruct,sigNames);


        for kIDs=1:length(mapIds)


            inMap=sta.InputMap(mapIds(kIDs));


            if FOUND_DATASET&&strcmpi(repoSpec.MappingMode,'index')
                isThisSignal=false(1,length(sigNames));

                if kIDs+1<=length(sigNames)

                    isThisSignal(kIDs+1)=true;
                end

            else


                isThisSignal=strcmp(inMap.InputName,sigNames);
            end


            if any(isThisSignal)


                if sum(isThisSignal)>1


                    idxMatch=find(isThisSignal==1);



                    for kMatch=1:length(idxMatch)





                        if strcmp(jsonStruct{idxMatch(kMatch)}.ParentName,inMap.InputParentName)

                            isThisSignal=false(1,length(isThisSignal));

                            isThisSignal(idxMatch(kMatch))=true;
                            break;
                        end


                    end

                end



                if ischar(jsonStruct{isThisSignal}.ParentID)&&strcmpi(jsonStruct{isThisSignal}.ParentID,'input')
                    inMap.SignalID=jsonStruct{isThisSignal}.ID;
                else

                    for kJson=1:length(jsonStruct)

                        if jsonStruct{isThisSignal}.ParentID==jsonStruct{kJson}.ID



                            if ischar(jsonStruct{kJson}.ParentID)&&strcmpi(jsonStruct{kJson}.ParentID,'input')&&...
                                (~strcmpi(jsonStruct{kJson}.Type,'Bus')||...
                                ~strcmpi(jsonStruct{kJson}.Type,'SaveToWorkspaceFormatStruct')||...
                                ~strcmpi(jsonStruct{kJson}.Type,'ArrayOfBus'))
                                inMap.SignalID=jsonStruct{isThisSignal}.ID;
                                break;
                            end

                        end

                    end
                end

                if inMap.SignalID~=-1&&legacy_behavior

                    if FOUND_DATASET

                        loadToWorkspace(dsID);
                    else

                        loadToWorkspace(inMap.SignalID);
                    end

                end
            end

        end

        if bdIsLoaded(repoSpec.DefaultModel)&&legacy_behavior

            setExternalInput(repoSpec.DefaultModel,repoSpec.InputString);
        end
    end


    outMsg.resultsTable=tableStructFromInputSpecID(inputSpecID);
    outMsg.inputSpecID=inputSpecID;

    if~legacy_behavior

        outMsg.scenarioid=dsID;

    end


    outMsg.dataProps=[];
    outMsg.mapMode=repoSpec.MappingMode;
    optionsUsed.mapMode=repoSpec.MappingMode;
    optionsUsed.compile=repoSpec.Verify;
    optionsUsed.partial=repoSpec.AllowPartial;
    optionsUsed.custom=repoSpec.CustomFile;

    outMsg.optionsUsed=optionsUsed;



    function loadToWorkspace(dbId)


        aFactory=starepository.repositorysignal.Factory;


        concreteExtractor=aFactory.getSupportedExtractor(dbId);
        [varValue,varNames]=concreteExtractor.extractValue(dbId);


        assignin('base',varNames,varValue);

        function bool=isMappable(jsonStruct,ParentID)

            bool=false;


            if ischar(ParentID)&&strcmpi(ParentID,'input')
                bool=true;
                return;
            end


            for k=1:length(jsonStruct)

                if jsonStruct{k}.ID==ParentID

                    if strcmpi(jsonStruct{k}.Type,'DataSet')

                        bool=true;
                        break;
                    end

                end

            end


            function bool=isEmptyAndNotString(aVar)

                bool=false;

                if isempty(aVar)&&~ischar(aVar)
                    bool=true;
                end







                function[FOUND_DATASET,jsonStruct,sigNames,dsID]=filterInputsForDataset(jsonStruct,sigNames)
                    FOUND_DATASET=false;
                    DS_index=[];
                    dsID=[];

                    for k=1:length(jsonStruct)

                        if strcmpi(jsonStruct{k}.Type,'DataSet')
                            FOUND_DATASET=true;
                            DS_index=k;
                            dsID=jsonStruct{k}.ID;
                            break
                        end

                    end

                    DS_childIndex=[];
                    for k=DS_index+1:length(jsonStruct)


                        if(jsonStruct{DS_index}.ID==jsonStruct{k}.ParentID)
                            DS_childIndex=[DS_childIndex,k];
                        end

                    end

                    if~isempty(DS_index)&&~isempty(DS_childIndex)
                        jsonStruct=jsonStruct([DS_index,DS_childIndex]);
                        sigNames=sigNames([DS_index,DS_childIndex]);
                    end