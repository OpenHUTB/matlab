function[wasSuccess,idsToUpdate,...
    filesInScenario,filesInScenarioFullFile,...
    fullScenarioFileLocationToWrite]=handleDoesScenarioNeedUpdate(fullScenarioFileLocationToWrite,modelStruct,sigIds,inputSpecID,appInstanceID,returnStr)






    subChannel='sta/mainui/diagnostic/request';
    fullChannel=sprintf('/sta%s/%s',appInstanceID,subChannel);

    wasSuccess=false;
    idsToUpdate=returnStr.idsToUpdate;
    shouldContinue=returnStr.ShouldContinue;
    filesInScenario=[];
    filesInScenarioFullFile=[];



    if~isempty(fullScenarioFileLocationToWrite)

        repoUtil=starepository.RepositoryUtility;

        numSigs=length(sigIds);
        listOfSources=cell(1,numSigs);
        listOfSourcesFullFile=cell(1,numSigs);


        for kSource=1:numSigs


            listOfSources{kSource}=repoUtil.getMetaDataByName(...
            sigIds(kSource),'FileName');


            listOfSourcesFullFile{kSource}=repoUtil.getMetaDataByName(...
            sigIds(kSource),'LastKnownFullFile');

        end


        idxWS=strcmp(listOfSources,getString(message('sl_iofile:matfile:BaseWorkspace')));


        filesInScenario=unique(listOfSources(~idxWS));
        filesInScenarioFullFile=unique(listOfSourcesFullFile(~idxWS));
        if~isempty(sigIds)
            if~isempty(idsToUpdate)
                if(returnStr.getFullFile)



                    filesInScenario=filesInScenario{1};
                    filesInScenarioFullFile=filesInScenarioFullFile{1};
                    fileWithLocation=locWriteToWhere(filesInScenario,filesInScenarioFullFile);



                    if isempty(fileWithLocation)

                        errMsg=DAStudio.message('sl_sta:sta:ScenarioDataFileDoesNotExist',filesInScenario,filesInScenarioFullFile);

                        slwebwidgets.errordlgweb(fullChannel,...
                        'sl_sta_general:common:Error',...
                        errMsg);


                        wasSuccess=false;
                        return;
                    end

                    needUpdate=true;
                    updateWithAppend=true;

                else




                    filesInScenarioFullFile=returnStr.datafileLocation;
                    fileWithLocation=filesInScenarioFullFile;
                    needUpdate=true;
                    updateWithAppend=false;
                end
            else



                shouldContinue=true;
                needUpdate=false;
                idsToUpdate=[];
                updateWithAppend=false;
                fileWithLocation=locWriteToWhere(filesInScenario{1},filesInScenarioFullFile{1});

                if isempty(fileWithLocation)

                    errMsg=DAStudio.message('sl_sta:sta:ScenarioDataFileDoesNotExist',filesInScenario{1},filesInScenarioFullFile{1});

                    slwebwidgets.errordlgweb(fullChannel,...
                    'sl_sta_general:common:Error',...
                    errMsg);

                    wasSuccess=false;
                    return;
                end
            end

            exportFileWithLocation=fileWithLocation;

        else
            shouldContinue=true;
            needUpdate=false;
            exportFileWithLocation='';
            updateWithAppend=false;
            idsToUpdate=[];

        end



        updateStrcture=struct;

        updateStrcture.shouldContinue=shouldContinue;
        updateStrcture.needUpdate=needUpdate;
        updateStrcture.exportFileWithLocation=exportFileWithLocation;
        updateStrcture.updateWithAppend=updateWithAppend;
        updateStrcture.idsToUpdate=idsToUpdate;


        [wasSuccess,idsToUpdate,...
        filesInScenario,filesInScenarioFullFile,...
        fullScenarioFileLocationToWrite]=doUpdateAndWriteLogic(fullScenarioFileLocationToWrite,modelStruct,sigIds,inputSpecID,appInstanceID,updateStrcture);


    end


    function fileToSave=locWriteToWhere(fileName,fileLocation)

        if exist(fileLocation,'file')
            fileToSave=fileLocation;
        elseif exist(fileName,'file')
            fileToSave=which(fileName);
        else
            fileToSave='';
        end