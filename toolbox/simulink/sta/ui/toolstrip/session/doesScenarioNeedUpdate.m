function[shouldContinue,needUpdate,fileWithLocation,updateWithAppend,idsToUpdate]=...
    doesScenarioNeedUpdate(sigIds)




    numSigs=length(sigIds);
    listOfSources=cell(1,numSigs);
    listOfSourcesFullFile=cell(1,numSigs);
    idsToUpdate=[];

    repoUtil=starepository.RepositoryUtility;


    for kSource=1:numSigs


        listOfSources{kSource}=repoUtil.getMetaDataByName(...
        sigIds(kSource),'FileName');


        listOfSourcesFullFile{kSource}=repoUtil.getMetaDataByName(...
        sigIds(kSource),'LastKnownFullFile');

    end


    idxWS=strcmp(listOfSources,getString(message('sl_iofile:matfile:BaseWorkspace')));


    filesInScenario=unique(listOfSources(~idxWS));
    filesInScenarioFullFile=unique(listOfSourcesFullFile(~idxWS));


    isOnlyOneFile=length(filesInScenario)==1;
    isAllWS=isempty(filesInScenario);


    if any(idxWS)


        if isOnlyOneFile

            isMat=~isempty(strfind(filesInScenarioFullFile{1},'.mat'));
            isExcel=~isempty(strfind(filesInScenarioFullFile{1},'.xls'))||~isempty(strfind(filesInScenarioFullFile{1},'.xlsx'));

            if isMat
                questText=getString(message('sl_sta:sta:DataSourcesMATandBase',filesInScenario{1}));
            else
                questText=getString(message('sl_sta:sta:DataSourcesExcelandBase',filesInScenario{1}));
            end


            questResponse=questdlg(questText,...
            getString(message('sl_sta:sta:DataSourceMixedTitle')),...
            getString(message('sl_sta_general:common:Yes')),...
            getString(message('sl_sta_general:common:No')),...
            getString(message('sl_sta_general:common:Yes')));

            if isempty(questResponse)||strcmp(questResponse,getString(message('sl_sta_general:common:No')))
                shouldContinue=false;
                needUpdate=true;
                fileWithLocation='';
                updateWithAppend=false;
                return;
            end


            updateWithAppend=true;




            if exist(filesInScenarioFullFile{1},'file')
                fileToSave=filesInScenarioFullFile{1};
            elseif exist(filesInScenario{1},'file')
                fileToSave=filesInScenario{1};
            end

            filesInScenario=filesInScenario{1};
            filesInScenarioFullFile=filesInScenarioFullFile{1};



        elseif isAllWS


            questResponse=questdlg(getString(message('sl_sta:sta:DataSourcesBaseOnly')),...
            getString(message('sl_sta:sta:DataSourceMixedTitle')),...
            getString(message('sl_sta_general:common:Yes')),...
            getString(message('sl_sta_general:common:No')),...
            getString(message('sl_sta_general:common:Yes')));

            if isempty(questResponse)||strcmp(questResponse,getString(message('sl_sta_general:common:No')))
                shouldContinue=false;
                needUpdate=true;
                fileWithLocation='';
                updateWithAppend=false;
                return;
            end

            updateWithAppend=false;

            [filename,pathname]=uiputfile(...
            {'*.mat',getString(message('MATLAB:uistring:uiopen:MATfiles'));...
            },...
            getString(message('sl_web_widgets:exportdialog:ExportDataTitle')));

            if~isempty(filename)&&ischar(filename)
                fileToSave=fullfile(pathname,filename);
            else
                fileToSave='';
            end
            filesInScenario=filename;
            filesInScenarioFullFile=fileToSave;



        end


        shouldContinue=true;
        needUpdate=true;
        idsToUpdate=sigIds(idxWS);
        if updateWithAppend
            fileWithLocation=locWriteToWhere(filesInScenario,filesInScenarioFullFile);
        else
            fileWithLocation=filesInScenarioFullFile;
        end
    else



        shouldContinue=true;
        needUpdate=false;
        idsToUpdate=[];
        updateWithAppend=false;
        fileWithLocation=locWriteToWhere(filesInScenario{1},filesInScenarioFullFile{1});

    end

    function fileToSave=locWriteToWhere(fileName,fileLocation)

        if exist(fileLocation,'file')
            fileToSave=fileLocation;
        elseif exist(fileName,'file')
            fileToSave=which(fileName);
        end
