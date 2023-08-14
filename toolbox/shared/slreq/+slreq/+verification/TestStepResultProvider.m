classdef TestStepResultProvider<slreq.verification.ResultProviderIntf




    events
verificationStarted
verificationFinished
    end

    properties
        resultCache containers.Map;
        timestampCache containers.Map;
        resultRunIDCache containers.Map;
    end

    properties(Constant)
        MDL_INFO_MODEL_COL=1;
        MDL_INFO_HARNESS_COL=2;
        MDL_INFO_SCENARIO_COL=3;
        MDL_INFO_TSBLOCK_COL=4;
        MDL_INFO_FILEPATH_COL=5;
    end

    methods
        function this=TestStepResultProvider()


            this.resultCache=containers.Map('KeyType','char','ValueType','any');


            this.timestampCache=containers.Map('KeyType','char','ValueType','any');



            this.resultRunIDCache=containers.Map('KeyType','char','ValueType','any');
        end

        function scanProject(~,~)
        end

        function resetCachedResults(this)

            this.resultCache.remove(this.resultCache.keys);
            this.timestampCache.remove(this.timestampCache.keys);
        end

        function[resultStatus,resultTimestamp,reason]=getResult(this,links)


            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(links));
            if isa(links,'slreq.data.Link')
                resultTimestamp=arrayfun(@(link)link.modifiedOn,links);
            else
                resultTimestamp=repmat(datetime('now','TimeZone','Local')...
                ,1,length(links));
            end

            reason=repmat(struct('type','','message',''),1,length(links));
            for i=1:length(links)
                if isa(links(i),'slreq.data.Link')

                    linkSource=links(i).source;
                else
                    linkSource=links(i);
                end

                [harnessName,model,stepID,~,~,modelFilepath]=this.getHarnessInfo(linkSource);
                cacheKey=sprintf('%s::%s::%d',model,harnessName,stepID);

                if~isKey(this.resultCache,cacheKey)...
                    ||this.isResultChanged(cacheKey,harnessName,modelFilepath)








                    this.readAllSDIResults(model,harnessName,modelFilepath);
                end


                if isKey(this.resultCache,cacheKey)
                    resultStatus(i)=this.resultCache(cacheKey);
                    resultTimestamp(i)=datetime(this.timestampCache(cacheKey),...
                    'ConvertFrom','posixtime','TimeZone','Local');
                    runIDstr=message('Slvnv:slreq_verification:ResultObtainedByRunIDs',strjoin(this.resultRunIDCache(cacheKey),',')).getString();
                    reason(i)=struct('type','info','message',runIDstr);
                end
            end
        end

        function[runSuccess,resultStatus,resultTimestamp,reason]=runTest(this,verificationItems)

            runSuccess=false(1,length(verificationItems));
            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(verificationItems));


            resultTimestamp=repmat(datetime('now','TimeZone','Local'),1,length(verificationItems));
            reason=repmat(struct('type','','message',''),1,length(verificationItems));

            if~slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation()
                reason.type='info';
                reason.message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                reason=repmat(reason,1,length(verificationItems));
                return;
            end


            if isa(verificationItems,'slreq.data.Link')
                verificationItems=arrayfun(@(link)link.source,verificationItems);
            elseif~isa(verificationItems,'slreq.data.SourceItem')
                return;
            end

            numVerifItems=numel(verificationItems);
            harnessOrModels=strings(numVerifItems,5);
            for i=1:numVerifItems
                harnessOrModels(i,:)=getModelInfoForSimulation(verificationItems(i));
            end






            [uniqueModels,~,indexes]=unique(harnessOrModels,'rows');



























            [nUniqueModels,~]=size(uniqueModels);
            for thisfile=1:nUniqueModels
                verifItemsForThisModel=verificationItems(indexes==thisfile);
                numVerifItemsForThisModel=length(verifItemsForThisModel);
                iModel=uniqueModels(thisfile,this.MDL_INFO_MODEL_COL);
                iHarness=uniqueModels(thisfile,this.MDL_INFO_HARNESS_COL);
                iScenario=uniqueModels(thisfile,this.MDL_INFO_SCENARIO_COL);
                iTSBlock=uniqueModels(thisfile,this.MDL_INFO_TSBLOCK_COL);
                iModelFilepath=uniqueModels(thisfile,this.MDL_INFO_FILEPATH_COL);
                try
                    if isempty(iHarness)
                        this.simulateModelForRuntests(iModel,iTSBlock,iScenario);
                    else
                        this.simulateModelForRuntests(iHarness,iTSBlock,iScenario);
                    end



                    this.readAllSDIResults(iModel,iHarness,iModelFilepath);

                    [thisModelResultStatus,thisModelResultTimestamp]=this.getResult(verifItemsForThisModel);
                    runSuccess(indexes==thisfile)=true(1,numVerifItemsForThisModel);
                    resultStatus(indexes==thisfile)=thisModelResultStatus;
                    resultTimestamp(indexes==thisfile)=thisModelResultTimestamp;
                catch
                    thisModelReason.type='info';
                    thisModelReason.message=getString(message('Slvnv:slreq:UnknownError'));
                    reason(indexes==thisfile)=repmat(thisModelReason,1,numVerifItemsForThisModel);
                end

            end

            function out=getModelInfoForSimulation(verifItem)







                [harnessName,model,~,scenario,tsBlock,modelFilepath]=this.getHarnessInfo(verifItem);
                out=strings(1,5);
                out(1,this.MDL_INFO_MODEL_COL)=model;
                out(1,this.MDL_INFO_HARNESS_COL)=harnessName;
                out(1,this.MDL_INFO_SCENARIO_COL)=scenario;
                out(1,this.MDL_INFO_TSBLOCK_COL)=tsBlock;
                out(1,this.MDL_INFO_FILEPATH_COL)=modelFilepath;
            end
        end

        function navigate(~,link)

            if~slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation()
                return;
            end


        end

        function sourceTimestamp=getSourceTimestamp(~,link)
            if isa(link,'slreq.data.Link')
                sourceTimestamp=link.modifiedOn;
                sourceItem=link.source.artifactUri;
            else
                sourceTimestamp=datetime('now','TimeZone','Local');
                sourceItem=link.artifactUri;
            end

            sourceFileInfo=dir(sourceItem);
            if~isempty(sourceFileInfo)
                sourceTimestamp=datetime(sourceFileInfo.datenum,'ConvertFrom','datenum','TimeZone','Local');
            end
        end

        function id=getIdentifier(~)
            id='Simulink Test Sequence Step';
        end
    end

    methods(Static)
        function tf=hasSTMLicenseAndInstallation()
            tf=license('test','Simulink_Test')&&...
            dig.isProductInstalled('Simulink Test');
        end
    end

    methods
        function readAllSDIResults(this,model,harnessName,modelFilepath)


            validRuns=this.getCurrentlyValidRuns(harnessName,modelFilepath);
            if isempty(validRuns)
                return;
            end

            sdiEngine=Simulink.sdi.Instance.engine;
            allResults=this.getDefaultResultTable(0);


            for i=1:numel(validRuns)
                iResult=this.getResultsFromRun(model,harnessName,sdiEngine,validRuns(i));

                if~isempty(iResult)
                    allResults=[allResults;iResult];%#ok<AGROW> 
                end
            end

            missingIDs=ismissing(allResults.id);
            allResults(missingIDs,:)=[];

            uniqueIDs=unique(allResults.id);


            for i=1:numel(uniqueIDs)
                id=uniqueIDs(i);
                [result,timestamp,runIDs]=this.consolidateResultsForID(allResults,id);

                this.resultCache(id)=result;
                this.timestampCache(id)=timestamp;
                this.resultRunIDCache(id)=runIDs;
            end

            assert(numel(this.resultCache)==numel(this.timestampCache));
        end

        function validRuns=getCurrentlyValidRuns(this,harnessName,modelFilepath)
            validRuns=[];
            slRuns=this.getSimulinkRuns(harnessName);
            stmRuns=this.getTestManagerRuns(harnessName);
            allRunObjs=[slRuns;stmRuns];
            if isempty(allRunObjs)
                return;
            end

            validRuns=this.filterForValidRuns(allRunObjs,harnessName,modelFilepath);
        end

        function runs=getSimulinkRuns(~,harnessName)
            runIDs=Simulink.sdi.getAllRunIDs(harnessName);
            runs=arrayfun(@(x)Simulink.sdi.getRun(x),runIDs);
        end

        function runs=getTestManagerRuns(this,harnessName)





            Simulink.sdi.internal.flushStreamingBackend();
            stmRunIDs=Simulink.sdi.Instance.engine.getAllRunIDs('STM');
            runs=arrayfun(@(x)Simulink.sdi.getRun(x),stmRunIDs);
            runsForThisModel=arrayfun(@(r)ismember(harnessName,this.getModelNamesFromSTMRun(r)),runs);
            runs=runs(runsForThisModel);
        end

        function modelNames=getModelNamesFromSTMRun(~,stmRun)
            modelNames={};
            if stmRun.SignalCount>0








                modelNames=unique(arrayfun(@(x)x.Model,stmRun.getAllSignals(),'UniformOutput',false));
            end
        end

        function validRuns=filterForValidRuns(~,allRunObjs,harnessName,modelFilepath)%#ok<INUSD> 


            runTimestamp=arrayfun(@(runObj)runObj.DateCreated,allRunObjs);
            modelFiletimestamp=datetime(0,'ConvertFrom','posixtime','TimeZone','Local');
            if isfile(modelFilepath)
                modelFileInfo=dir(modelFilepath);
                modelFiletimestamp=datetime(modelFileInfo.datenum,'ConvertFrom','datenum','TimeZone','Local');
            end
            validRunsByTimestamp=(runTimestamp>=modelFiletimestamp);
            validRuns=allRunObjs(validRunsByTimestamp);
        end

        function results=getResultsFromRun(this,model,harnessName,sdiEngine,runObj)
            results=[];
            allSignals=runObj.getAllSignals();
            runTimestamp=posixtime(runObj.DateCreated);
            isVerifySignal=arrayfun(@(sig)this.isAssessment(sdiEngine,sig),allSignals);
            verifySignals=allSignals(isVerifySignal);
            runID=string(runObj.id);
            if~isempty(verifySignals)
                results=this.getDefaultResultTable(numel(verifySignals));

                for i=1:numel(verifySignals)

                    id=sdiEngine.getMetaDataV2(verifySignals(i).ID,'SSIDNumber');
                    result=sdiEngine.getMetaDataV2(verifySignals(i).ID,'AssessmentResult');
                    resultStatus=this.assessmentResultToStatus(result);

                    cacheKey=sprintf('%s::%s::%d',model,harnessName,id);
                    results(i,:)={cacheKey,resultStatus,runTimestamp,runID};
                end
            end
        end

        function tf=isAssessment(~,sdiEngine,signal)
            isVerifySignal=sdiEngine.getMetaDataV2(signal.id,'IsAssessment');
            if~isempty(isVerifySignal)
                tf=logical(isVerifySignal);
            else
                tf=false;
            end
        end

        function tbl=getDefaultResultTable(~,numRows)
            tbl=table('Size',[numRows,4],...
            'VariableTypes',{'string','slreq.verification.ResultStatus','double','string'},...
            'VariableNames',{'id','status','timestamp','runID'});








        end

        function out=assessmentResultToStatus(~,in)
            switch(in)
            case 0
                out=slreq.verification.ResultStatus.Pass;
            case 1
                out=slreq.verification.ResultStatus.Fail;
            otherwise
                out=slreq.verification.ResultStatus.Unknown;
            end
        end

        function[outStatus,outTimestamp,runIDs]=consolidateResultsForID(~,allResults,id)
            import slreq.verification.ResultStatus;
            resultsForID=allResults(allResults.id==id,:);
            allResults=resultsForID.status;
            passOnes=(allResults==ResultStatus.Pass);
            failOnes=(allResults==ResultStatus.Fail);
            unknownOnes=(allResults==ResultStatus.Unknown);
            runIDs=sort(resultsForID.runID);

            if all(passOnes)||(all(passOnes|unknownOnes)&&any(passOnes))


                outStatus=ResultStatus.Pass;
            elseif any(failOnes)
                outStatus=ResultStatus.Fail;
            else
                outStatus=ResultStatus.Unknown;
            end

            outTimestamp=max(resultsForID.timestamp);
        end

        function[harnessName,modelName,stepID,scenarioName,tsBlockPath,modelFilepath]=getHarnessInfo(this,sourceItem)


            modelFilepath=sourceItem.artifactUri;
            id=sourceItem.id;

            [~,modelName,~]=fileparts(modelFilepath);
            [~,objH,~]=rmisl.resolveObjInHarness(sprintf('%s%s',modelName,id));

            stateObj=sfroot().idToHandle(objH);
            stepID=stateObj.SSIdNumber;
            tsBlockPath=stateObj.Chart.Path;
            harnessName=bdroot(tsBlockPath);
            scenarioName=this.getScenarioForStep(stateObj);
        end

        function scenarioName=getScenarioForStep(~,stepObj)
            scenarioName='';
            if sltest.testsequence.isUsingScenarios(stepObj.Chart.Path)
                scenarioObj=stepObj.getParent();
                while(isa(scenarioObj.getParent(),'Stateflow.State'))
                    scenarioObj=scenarioObj.getParent();
                end

                scenarioName=scenarioObj.Name;
            end
        end

        function simulateModelForRuntests(this,model,tsBlock,scenario)



            resetModel=[];%#ok<NASGU> % in case model needs to be reset if we switch scenarios


            if scenario~=""

                wasDirty=get_param(model,'Dirty');

                originalScenario=this.switchToScenario(tsBlock,scenario);
                resetModel=onCleanup(@()this.resetModelAfterSim(model,tsBlock,originalScenario,wasDirty));
            end

            simIn=Simulink.SimulationInput(model);
            sim(simIn);


        end

        function resetModelAfterSim(this,model,tsBlock,originalScenarioIndex,wasDirty)
            this.setActiveScenario(tsBlock,originalScenarioIndex);
            set_param(model,'Dirty',wasDirty);
        end

        function originalScenario=switchToScenario(this,tsBlock,scenarioName)
            allScenarios=sltest.testsequence.internal.getAllScenarios(tsBlock);
            [~,setIndex]=ismember(scenarioName,allScenarios);

            setIndex=setIndex-1;
            originalScenario=this.setActiveScenario(tsBlock,setIndex);

        end

        function previousValue=setActiveScenario(~,tsBlock,scenarioIndex)
            rt=sfroot();
            chart=rt.find('-isa','Stateflow.ReactiveTestingTableChart','Path',tsBlock);
            sttman=Stateflow.STT.StateEventTableMan(chart.Id);
            viewManager=sttman.viewManager;

            previousValue=viewManager.scenarioParamVal();

            viewManager.jsActiveScenario(scenarioIndex);
        end

        function tf=isResultChanged(this,cacheKey,harnessName,modelFilepath)






            knownRunIDs=this.resultRunIDCache(cacheKey);
            currentlyValidRuns=this.getCurrentlyValidRuns(harnessName,modelFilepath);
            if isempty(currentlyValidRuns)


                tf=~isempty(knownRunIDs);
                return;
            end

            currentlyValidRunIDs=sort(arrayfun(@(x)string(x.ID),currentlyValidRuns));
            if numel(knownRunIDs)==numel(currentlyValidRunIDs)
                tf=any(knownRunIDs~=currentlyValidRunIDs);
            else
                tf=true;
            end
        end
    end
end
