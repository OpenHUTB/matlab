function SimulationCompletedCallback(varargin)

    try
        if~alm.internal.project.isArtifactTrackingActive()
            return;
        end
        prj=matlab.project.currentProject();

        resultSets=varargin{2}.ResultSet;
        if isempty(resultSets)
            return;
        end

        for iResultSet=1:numel(resultSets)

            resultSet=resultSets(iResultSet);
            v=alm.internal.sltest.visitor.TopLevelTestElements();
            traverser=alm.internal.sltest.SLTestResultTraverser(v);
            topLevelResObjs=traverser.run(resultSet);
            topLevelResObjs(1)=[];
            topLevelSpecObj=cellfun(@(x)alm.internal.sltest.Utils.resultToSpec(x),...
            topLevelResObjs,'Uni',false);
            nSpecs=numel(topLevelSpecObj);

            projectRoot=prj.RootFolder;
            as=alm.internal.ArtifactService.get(projectRoot);

            testAddresses=[];


            for i=1:nSpecs

                spec=topLevelSpecObj{i};


                if isempty(spec)
                    continue;
                end

                absoluteTestFilePath=alm.internal.sltest.Utils.getTestFilePath(spec);

                testAddress=alm.ArtifactAddress;
                testAddress.SelfContained=absoluteTestFilePath;

                testAddress.Contained=string(alm.internal.sltest.Utils.getSpecUUID(spec));

                testAddresses=[testAddresses,testAddress];%#ok<AGROW>
                if~strcmp(projectRoot,alm.internal.GlobalProjectFactory.get().findProjectRoot(absoluteTestFilePath))
                    as.notifyUser("warn",...
                    message('alm:sltest_handlers:ArtifactOutsideCurrentProject',...
                    alm.internal.createRevealFileHyperlink(absoluteTestFilePath),projectRoot));
                else


                    try
                        as.resolveStorageHandler(absoluteTestFilePath);
                    catch ME
                        as.notifyUser("warn",...
                        message('alm:sltest_handlers:ArtifactIgnored',...
                        alm.internal.createRevealFileHyperlink(absoluteTestFilePath),...
                        ME.message));
                    end
                end



                if endsWith(absoluteTestFilePath,".m")
                    as.notifyUser("warn",...
                    message('alm:sltest_handlers:UnsupportedMALTABbasedTest',...
                    alm.internal.createRevealFileHyperlink(absoluteTestFilePath)));
                    continue;
                end

            end
            v=alm.internal.sltest.visitor.TestedInterfaceCollector();
            traverser=alm.internal.sltest.SLTestResultTraverser(v);
            testedSIDs=traverser.run(resultSet);

            models=strtok(testedSIDs,':');

            nModels=numel(models);
            modelAddresses=[];


            for i=1:nModels

                model=models{i};

                absolutePath=alm.internal.sltest.Utils.resolveModelName(model);
                modelAddress=alm.ArtifactAddress;
                modelAddress.SelfContained=absolutePath;
                modelAddress.Contained=string(model);
                modelAddresses=[modelAddresses,modelAddress];%#ok<AGROW>
                if~strcmp(projectRoot,alm.internal.GlobalProjectFactory.get().findProjectRoot(absolutePath))
                    as.notifyUser("warn",...
                    message('alm:sltest_handlers:ArtifactOutsideCurrentProject',...
                    alm.internal.createRevealFileHyperlink(absolutePath),projectRoot));
                end

                try
                    as.resolveStorageHandler(absolutePath);
                catch ME
                    as.notifyUser("warn",...
                    message('alm:sltest_handlers:ArtifactIgnored',...
                    alm.internal.createRevealFileHyperlink(absolutePath),...
                    ME.message));
                end
            end
            eb=alm.internal.EvidenceBuilder("sl_test_sim",...
            alm.internal.sltest.Utils.getResultUUID(resultSet));
            eb.TemplateTask.Timestamp_s=uint64(posixtime(resultSet.StartTime)*1000);
            eb.TemplateTask.Duration_s=uint64(seconds(resultSet.Duration));
            eb.InputAddresses=[testAddresses,modelAddresses];
            eb.AutoAnalyze=true;
            eb.UniquenessPolicy="INCREMENT";


            as.saveInputBaseline(eb);

            cache=alm.internal.EvidenceCache.get();
            cache.insert(eb);


        end

        for resultSet=resultSets
            fullFileName=alm.internal.sltest.createSessionResultFile(...
            prj.RootFolder,resultSet);
            eventInfo.FilePath=fullFileName;


            alm.internal.sltest.ExportCompletedCallback([],eventInfo,true);
        end


    catch ME

        warning(message('alm:handler_services:CallbackError','SimulationCompleted',ME.identifier));
    end

end
