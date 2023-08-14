function ExportCompletedCallback(~,eventInfo,isImplicit)









    if nargin==2
        isImplicit=false;
    end




    if~alm.internal.project.isArtifactTrackingActive()
        return;
    end


    try
        prj=matlab.project.currentProject();



        as=alm.internal.ArtifactService.get(prj.RootFolder);



        r=alm.internal.GlobalProjectFactory.get().findProjectRoot(...
        fullfile(eventInfo.FilePath));





        if~strcmp(prj.RootFolder,r)
            as.notifyUser("warn",...
            message('alm:sltest_handlers:ArtifactOutsideCurrentProject',...
            alm.internal.createRevealFileHyperlink(eventInfo.FilePath),prj.RootFolder));
            return;
        end



        try
            storageHandler=as.resolveStorageHandler(eventInfo.FilePath);
        catch ME
            as.notifyUser("warn",...
            message('alm:sltest_handlers:ArtifactIgnored',...
            alm.internal.createRevealFileHyperlink(eventInfo.FilePath),...
            ME.message));
            return;
        end








        as.removeArtifact(eventInfo.FilePath);




        if endsWith(eventInfo.FilePath,".mldatx")
            resultSets=sltest.testmanager.importResults(fullfile(eventInfo.FilePath),...
            'UniqueImport',true,...
            'PartialLoad',true);
        elseif endsWith(eventInfo.FilePath,".sltsrf")



            [~,uuidName]=fileparts(eventInfo.FilePath);
            rsID=stm.internal.getResultSetIDsFromUUID(uuidName);

            assert(~isempty(rsID)&&rsID~=0,"No in-memory result with matching UUID for file '"+...
            eventInfo.FilePath+"' found.");

            resultSets=sltest.testmanager.ResultSet([],rsID);

            assert(~isempty(resultSets),"No in-memory result with matching UUID for file '"+...
            eventInfo.FilePath+"' found.");
        end





        if endsWith(eventInfo.FilePath,".mldatx")
            for iResultSet=1:numel(resultSets)
                resultSet=resultSets(iResultSet);
                resultSetUuid=alm.internal.sltest.Utils.getResultUUID(resultSet);

                databaseFullFilePath=...
                alm.internal.ArtifactService.getDatabaseLocation(prj.RootFolder);
                [databasePath,~]=fileparts(databaseFullFilePath);
                sessionFileName=fullfile(databasePath,"sltest",...
                resultSetUuid+".sltsrf");


                as.removeArtifact(sessionFileName);

                if isfile(sessionFileName)
                    delete(sessionFileName);
                end
            end
        end


        table=cell(0,2);



        for iResultSet=1:numel(resultSets)
            resultSet=resultSets(iResultSet);

            resultSetUuid=alm.internal.sltest.Utils.getResultUUID(resultSet);

            eb=alm.internal.EvidenceCache.get().try_get("sl_test_sim",...
            resultSetUuid);

            if isempty(eb)
                continue;
            end

            eb.UniquenessPolicy="INCREMENT";

            timeStamp=uint64(...
            posixtime(datetime('now','TimeZone','local'))*1000);
            eb.TemplateTask.setCustomProperty("ExportTimeStamp",...
            num2str(timeStamp));

            resultSetAddress=alm.ArtifactAddress;
            resultSetAddress.SelfContained=string(eventInfo.FilePath);
            resultSetAddress.Contained=string(resultSetUuid);

            eb.OutputAddresses=resultSetAddress;


            table{end+1,1}=as.addTaskEvidence(eb);%#ok<AGROW>
            table{end,2}=resultSet;

        end



        opaqueFileCache=alm.internal.OpaqueFileCache.getInstance();
        hasImplicitReport=isImplicit&&...
        opaqueFileCache.count>uint64(0)&&...
        size(table,1)==1;

        if hasImplicitReport
            slTestSimTeUuid=table{1,1};
            resultSet=table{1,2};
            matchingOpaqueFileContents=getMatchingOpaqueFileContents(resultSet.UUID);
            reportFiles=strings(1,numel(matchingOpaqueFileContents));
            for i=1:numel(matchingOpaqueFileContents)

                opaqueFileContents=matchingOpaqueFileContents(i);
                relFilePath=opaqueFileContents.Address;

                opaqueFileAddress=alm.ArtifactAddress;
                opaqueFileAddress.SelfContained=relFilePath;


                eb=alm.internal.EvidenceBuilder("sl_test_rep",relFilePath);
                eb.TemplateTask.Timestamp_s=uint64(posixtime(resultSet.StartTime)*1000);
                eb.TemplateTask.Duration_s=uint64(seconds(resultSet.Duration));
                eb.InputUuids=string(slTestSimTeUuid);
                eb.AutoAnalyze=true;
                eb.UniquenessPolicy="INCREMENT";
                eb.OutputAddresses=opaqueFileAddress;
                opaqueFileContents.Uuid=as.addTaskEvidence(eb);

                reportFile=storageHandler.getAbsoluteAddress(relFilePath);
                reportFiles(i)=string(reportFile);
            end
        else
            reportFiles=strings(0);
        end




        allFiles=[string(eventInfo.FilePath),reportFiles];
        as.updateArtifacts(allFiles);


    catch ME
        warning(message('alm:handler_services:CallbackError','ExportCompleted',ME.identifier));
    end

end

function opaqueFileContents=getMatchingOpaqueFileContents(resultSetUuid)
    opaqueFileCache=alm.internal.OpaqueFileCache.getInstance();
    allOpaqueFileContents=opaqueFileCache.get();
    opaqueFileContents=alm.internal.OpaqueFileContents.empty;
    for i=1:numel(allOpaqueFileContents)
        thisOpaqueFileContent=allOpaqueFileContents(i);
        if strcmp(thisOpaqueFileContent.Uuid,alm.internal.uuid.generateNilUuid())
            resultSetUuids=thisOpaqueFileContent.ResultSetUuids;
            if numel(resultSetUuids)==1
                if strcmp(resultSetUuids{1},resultSetUuid)
                    opaqueFileContents(end+1)=thisOpaqueFileContent;%#ok<AGROW>
                end
            end
        end
    end
end

