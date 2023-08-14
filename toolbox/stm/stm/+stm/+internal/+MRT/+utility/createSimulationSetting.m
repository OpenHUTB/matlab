function createSimulationSetting(testTreeObj,outputRoot)




    status=1;
    try
        for nodek=1:length(testTreeObj.nodeList)
            theNode=testTreeObj.nodeList(nodek);

            isTestCaseResult=(theNode.resultType==3);
            isIterationResult=(theNode.resultType==4);
            isResultContainer=theNode.isResultContainer;
            isTC=(isTestCaseResult||isIterationResult);
            if(~isTC||isResultContainer)
                continue;
            end
            testId=testTreeObj.nodeList(nodek).testId;
            itrId=testTreeObj.nodeList(nodek).iterationId;
            resultId=testTreeObj.nodeList(nodek).resultId;
            releaseName=testTreeObj.releaseName;

            tcrLoc=fullfile(outputRoot,['TestCaseResult_',sprintf('%d',resultId)]);
            tc=sltest.testmanager.TestCase([],testId);


            if(strcmp(tc.TestType,'equivalence'))
                permIndices=find(testTreeObj.EquivalenceTestIdList==testId);
                permIds=testTreeObj.PermutationIdList(permIndices)';
            else
                permIds=1;
            end
            for k=permIds
                [runcfg,simInput]=stm.internal.MRT.utility.getSimulationSettings(testId,itrId,k-1);

                simInput.CoverageSettings.CoverageFilterFilename='';
                simSettings.resultId=resultId;

                if isempty(simInput.ResultUUID)
                    tcr=sltest.testmanager.TestResult.getResultFromID(resultId);
                    simInput.ResultUUID=tcr.ResultUUID;
                end
                simSettings.(['sim',num2str(k)]).runcfg=runcfg;
                simSettings.(['sim',num2str(k)]).simInput=simInput;
                if(~isempty(runcfg.out.messages))
                    stm.internal.addResultMessage(resultId,runcfg.out.messages,runcfg.out.errorOrLog);
                end
            end


            testInfo={};

            for sk=permIds
                relDir=fullfile(outputRoot,'TestInfo',releaseName);
                if(~exist(relDir,'dir'))
                    mkdir(relDir);
                end

                simSettingFile=fullfile(relDir,['simSettings_',sprintf('%d',resultId),'.mat']);
                save(simSettingFile,'simSettings');


                stm.internal.MRT.utility.genPreSimCallback(outputRoot,releaseName,...
                resultId,sk);


                oneTestInfo=struct(...
                'release',releaseName,...
                'testInfoPath',relDir,...
                'resultId',resultId,...
                'testId',testId,...
                'iterationId',itrId,...
                'simIndex',sk...
                );
                testInfo{sk}=oneTestInfo;
            end
            oFile=fullfile(tcrLoc,'testInfo.mat');
            if(exist(oFile,'file'))


                m=load(oFile);
                existingTestInfo=m.testInfo;
                for idx=1:length(existingTestInfo)
                    if isempty(existingTestInfo{idx})
                        continue;
                    end
                    testInfo{idx}=existingTestInfo{idx};
                end
            end
            save(oFile,'testInfo');
        end
    catch me
        rethrow(me);
    end
end


