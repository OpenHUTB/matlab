






function ResultReportCreatedCallback(~,eventInfo)


    if~feature('ALMReportWorkflow')
        return;
    end

    try


        if~alm.internal.project.isArtifactTrackingActive()
            return;
        end


        filePath=eventInfo.FilePath;
        resultObjects=eventInfo.ResultObjs;

        project=currentProject;
        projectRootFolder=project.RootFolder;
        as=alm.internal.ArtifactService.get(projectRootFolder);



        try
            storageHandler_M=as.resolveStorageHandler(filePath);
        catch ME
            as.notifyUser("warn",...
            message('alm:sltest_handlers:ArtifactIgnored',...
            filePath,ME.message));
            return;
        end

        storageFactory=alm.StorageFactory;
        graph=alm.Graph();
        storage=graph.importStorage(...
        as.getGraph().getStorageByCustomId(storageHandler_M.CustomId));
        storageHandler=storageFactory.createHandler(storage);



        r=storageHandler.getRelativeAddress(filePath);
        if r.Ok
            relFilePath=string(r.Value);
        else
            return;
        end

        mgr=alm.internal.HandlerServiceManager.get();
        service=mgr.getService('alm::services::SLTestResultHandlerService');
        artifactFactory=service.createArtifactFactory(storage,graph);


        artFile=graph.createArtifact(relFilePath);
        artFile.Type='sl_test_report_file';
        artFile.Label=relFilePath;



        hasOldResultSet=false;
        for i=1:numel(resultObjects)
            resultObject=resultObjects(i);
            resultSet=getResultSet(resultObject);
            resultSetUuid=string(...
            alm.internal.sltest.Utils.getResultUUID(resultSet));
            if resultSetUuid.strlength()==0
                hasOldResultSet=true;
            end
        end
        if hasOldResultSet
            artFile.LastAnalysisStatus='ERROR';
            opaqueFileCache=alm.internal.OpaqueFileCache.getInstance();
            opaqueFileCache.insert(relFilePath,...
            'sl_test_report_file',...
            char(alm.internal.uuid.generateNilUuid()),...
            graph);
            as.updateArtifacts(filePath);
            return;
        end


        fake.Graph=graph;
        fake.Storage=storage;
        fake.StorageHandler=storageHandler;
        fake.Factory=artifactFactory;
        fake.MainArtifact=artFile;

        resultSetUuids=strings(0,1);
        for i=1:numel(resultObjects)

            resultObject=resultObjects(i);
            resultSet=getResultSet(resultObject);


            v=alm.internal.sltest.visitor.TestResultHandler(fake);
            traverser=alm.internal.sltest.SLTestResultTraverser(v);
            traverser.run(resultObject);


            allArtifacts=graph.getAllArtifacts('sl_test_resultset');
            for artIndex=1:numel(allArtifacts)
                artifact=allArtifacts(artIndex);
                artifact.Type='sl_test_report_resultset';
            end
            allArtifacts=graph.getAllArtifacts('sl_test_case_result');
            for artIndex=1:numel(allArtifacts)
                artifact=allArtifacts(artIndex);
                artifact.Type='sl_test_report_result';
            end

            resultSetUuid=string(...
            alm.internal.sltest.Utils.getResultUUID(resultSet));
            if resultSetUuid.strlength()~=0
                resultSetUuids(end+1)=resultSetUuid;%#ok<AGROW>
            end

        end



        theGraph=as.getGraph();
        resultSetUuids=unique(resultSetUuids);
        inputUuids=strings(0,1);
        for i=1:numel(resultSetUuids)
            resultSetUuid=resultSetUuids(i);
            if resultSetUuid.strlength()~=0
                taskEvidence=theGraph.getTaskEvidenceByCustomId(...
                'sl_test_sim',resultSetUuid);
                if~isempty(taskEvidence)
                    inputUuids(end+1)=taskEvidence.UUID;%#ok<AGROW>
                end
            end
        end





        opaqueFileCache=alm.internal.OpaqueFileCache.getInstance();
        opaqueFileCache.insert(relFilePath,...
        'sl_test_report_file',...
        char(alm.internal.uuid.generateNilUuid()),...
        graph,...
        resultSetUuids);



        if numel(inputUuids)==numel(resultObjects)

            reportAddress=alm.ArtifactAddress;
            reportAddress.SelfContained=relFilePath;


            eb=alm.internal.EvidenceBuilder("sl_test_rep",relFilePath);
            eb.TemplateTask.Timestamp_s=uint64(posixtime(resultSet.StartTime)*1000);
            eb.TemplateTask.Duration_s=uint64(seconds(resultSet.Duration));
            eb.InputUuids=inputUuids;
            eb.AutoAnalyze=true;
            eb.UniquenessPolicy="INCREMENT";
            eb.OutputAddresses=reportAddress;
            taskEvidenceUuid=as.addTaskEvidence(eb);%#ok<NASGU>

            as.updateArtifacts(filePath);

        elseif isReconciled(theGraph,resultSetUuids)



            as.updateArtifacts(filePath);
        else

        end

    catch ME
        warning(message(...
        'alm:handler_services:CallbackError',...
        'ResultReportCreated',...
        ME.message));
    end
end

function resultSet=getResultSet(resultObject)
    resultSet=[];
    switch class(resultObject)
    case 'sltest.testmanager.ResultSet'
        resultSet=resultObject;
    case{'sltest.testmanager.TestFileResult',...
        'sltest.testmanager.TestSuiteResult',...
        'sltest.testmanager.TestCaseResult'}
        resultSet=getResultSet(resultObject.Parent);
    end
end

function result=isReconciled(fullGraph,resultSetUuids)

    result=true;
    existingResultSets=fullGraph.getAllArtifacts('sl_test_resultset');
    existingResultSetUuids=string({existingResultSets.Address});
    if isempty(existingResultSetUuids)
        result=false;
        return;
    end
    for i=1:numel(resultSetUuids)
        if~any(strcmp(resultSetUuids(i),existingResultSetUuids))
            result=false;
        end
    end
end

