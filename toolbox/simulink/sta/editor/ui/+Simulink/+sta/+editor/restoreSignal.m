function jsonStruct=restoreSignal(restoreSignalProperties,varargin)




    REPORT_JSON=true;

    if~isempty(varargin)
        REPORT_JSON=varargin{1};
    end

    idToRestore=restoreSignalProperties.rootsignalid;

    if isempty(restoreSignalProperties.parentid)||...
        (ischar(restoreSignalProperties.parentid)&&strcmp(restoreSignalProperties.parentid,'input'))
        restoreSignalProperties.parentid=0;
    elseif iscell(restoreSignalProperties.parentid)

        for kCell=1:length(restoreSignalProperties.parentid)
            if(ischar(restoreSignalProperties.parentid{kCell})&&strcmp(restoreSignalProperties.parentid{kCell},'input'))
                restoreSignalProperties.parentid{kCell}=0;
            end
        end

        restoreSignalProperties.parentid=cell2mat(restoreSignalProperties.parentid);
    end
    parentToRestoreTo=restoreSignalProperties.parentid;





    appInstanceID=restoreSignalProperties.appid;
    repoManager=sta.RepositoryManager();
    scenarioid=getScenarioIDByAppID(repoManager,appInstanceID);

    aFactory=starepository.repositorysignal.Factory;
    jsonToSend={};
    for kRestore=1:length(idToRestore)


        repoSignal=aFactory.getSupportedExtractor(idToRestore(kRestore));
        repoUtil=starepository.RepositoryUtility;
        if~parentToRestoreTo(kRestore)==0


            oldestParent=repoUtil.getOldestRelative(parentToRestoreTo(kRestore));


            repoUtil.setParent(idToRestore(kRestore),parentToRestoreTo(kRestore));
            parentMeta=repoUtil.getMetaDataStructure(parentToRestoreTo(kRestore));
            signalNameAsCell=repoUtil.getSignalNames(idToRestore(kRestore));

            repoUtil.setMetaDataByName(idToRestore(kRestore),'FullName',[parentMeta.FullName,'.',signalNameAsCell{1}]);
            repoUtil.setMetaDataByName(idToRestore(kRestore),'ParentName',parentMeta.FullName);

            repoUtil.setMetaDataByName(idToRestore(kRestore),'IS_EDITED',1);


            if oldestParent~=0
                repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
            end

            jsonStruct=jsonStructFromID(repoSignal,idToRestore(kRestore));

        else
            jsonStruct=jsonStructFromID(repoSignal,idToRestore(kRestore));



            eng=sdi.Repository(true);
            eng.safeTransaction(@initExternalSources,...
            jsonStruct,...
            scenarioid);

            repoUtil.setMetaDataByName(idToRestore(kRestore),'IS_EDITED',1);
        end

        jsonToSend=[jsonToSend,jsonStruct];
    end

    if REPORT_JSON
        baseMessageChanel='staeditor';
        uniqueAppID=appInstanceID;
        msgTopics=Simulink.sta.EditorTopics();
        outdata.arrayOfListItems=jsonToSend;

        outdata.viewoninsert=[];

        if isfield(restoreSignalProperties,'viewoninsert')
            outdata.viewoninsert=restoreSignalProperties.viewoninsert;
        end

        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SIGNAL_EDIT,outdata);
        msgOut.spinnerID='insertsignal';
        msgOut.spinnerOn=false;
        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);

    end




