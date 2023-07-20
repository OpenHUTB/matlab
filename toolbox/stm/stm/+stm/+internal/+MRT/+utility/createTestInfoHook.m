function status=createTestInfoHook(testTreeObj,outputRoot)




    status=1;

    try
        nodeIdMap=Simulink.sdi.Map(int32(0),int32(0));
        for nodek=1:length(testTreeObj.nodeList)
            testId=testTreeObj.nodeList(nodek).testId;
            nodeIdMap.insert(testId,1);
        end
        releaseName=testTreeObj.releaseName;
        itrMap=Simulink.sdi.Map(char('?'),int32(0));
        for nodek=1:length(testTreeObj.nodeList)
            theNode=testTreeObj.nodeList(nodek);
            testId=theNode.testId;
            resultId=theNode.resultId;
            iterationId=theNode.iterationId;
            isResultContainer=theNode.isResultContainer;

            isTestCaseResult=(theNode.resultType==3);
            isIterationResult=(theNode.resultType==4);
            isTC=(isTestCaseResult||isIterationResult);
            if(isTC&&isResultContainer)

                continue;
            end

            if(~isTC)
                infoPath=fullfile(outputRoot,'TestInfo',releaseName);
                genTestSuiteHookFile(infoPath,testId,resultId);
                continue;
            end


            tcObj=sltest.testmanager.TestCase([],testId);

            equStatus=0;
            if(strcmp(tcObj.TestType,'equivalence'))
                equStatus=1;
                permIndices=find(testTreeObj.EquivalenceTestIdList==testId);
                permIds=testTreeObj.PermutationIdList(permIndices)';
            else
                permIds=1;
            end

            for sk=permIds
                infoPath=fullfile(outputRoot,'TestInfo',releaseName);
                if(~exist(infoPath,'dir'))
                    mkdir(infoPath);
                end
                testInfoFile=fullfile(infoPath,['TestInfoHook_',sprintf('%d',testId),'.m']);


                parentTSSetupCbList={};
                totalIterations=-1;
                if(itrMap.isKey(testInfoFile))
                    totalIterations=itrMap.getDataByKey(testInfoFile);
                end
                totalIterations=totalIterations+1;
                addTestCaseInfoBlock(infoPath,tcObj,totalIterations,testId,iterationId,sk,resultId,equStatus,parentTSSetupCbList);
                itrMap.insert(testInfoFile,totalIterations);

                if(totalIterations==0)
                    totalIterations=totalIterations+1;
                    addTestCaseInfoBlock(infoPath,tcObj,totalIterations,testId,iterationId,sk,resultId,equStatus,parentTSSetupCbList);
                    itrMap.insert(testInfoFile,totalIterations);
                end
            end
        end
    catch
        status=0;
    end
end

function genTestSuiteHookFile(infoPath,testId,resultId)
    pp=stm.internal.getTestProperty(testId,'testsuite');
    itrk=1;
    for cbk=1:2
        if(cbk==1)
            script=pp.setupScript;
            funName=['tsSetupCallback_',sprintf('%d',testId)];
            tsCMD='setupCallback';
        else
            script=pp.cleanupScript;
            funName=['tsCleanupCallback_',sprintf('%d',testId)];
            tsCMD='cleanupCallback';
        end
        if(isempty(script))
            continue;
        end

        testInfoHookFile=fullfile(infoPath,[sprintf('TestInfoHook_%d_cb%d',testId,cbk),'.m']);
        fid=fopen(testInfoHookFile,'w');
        fprintf(fid,'%s%d%s\n','function TestInfo=TestInfoHook_',testId,sprintf('_cb%d()',cbk));
        fprintf(fid,'TestInfo{1}=IMT.TestInfo;\n');

        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.STM_MRT = true;']);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.STMTestName = ''',pp.name,''';']);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.IsTestSuite = true;']);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.ResultID = ',sprintf('%d',resultId),';']);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.SupportedTestSuites = {''matlab_startup''};']);

        fileName=fullfile(infoPath,[funName,'.m']);
        stm.internal.MRT.utility.genSTMCallback(fileName,{script},cbk);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.pre_matlab_startup_action  = ''',funName,''';']);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.TestSuiteCMD = ''',tsCMD,''';']);

        fprintf(fid,'\n');
        fclose(fid);
    end
end

function addTestCaseInfoBlock(infoPath,tcObj,itrk,testId,iterationId,simIndex,resultId,equTestStatus,parentTSSetupCbList)
    assert(simIndex==1||simIndex==2);
    testInfoHookfullfile=fullfile(infoPath,['TestInfoHook_',sprintf('%d',testId),'.m']);
    fid=fopen(testInfoHookfullfile,'a');

    if(itrk==0)
        fprintf(fid,'%s%d%s\n','function TestInfo=TestInfoHook_',testId,'()');
        fprintf(fid,'\n');
    else
        modelName=tcObj.getProperty('Model',simIndex);
        harnessName=tcObj.getProperty('HarnessName',simIndex);
        harnessOwner=tcObj.getProperty('HarnessOwner',simIndex);

        fprintf(fid,'%s\n',['%%Info for Iter:',sprintf('%d',itrk)]);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}=IMT.TestInfo;']);

        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.STM_MRT = true;']);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.STMTestName = ''',tcObj.Name,''';']);

        if(~isempty(harnessName))
            fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.ModelName = ''',harnessName,''';']);
            pLoad.sltest_isharness=true;
            pLoad.sltest_bdroot=harnessName;
            pLoad.sltest_sut=stm.internal.MRT.utility.fixMultilineString(harnessOwner);
        else
            fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.ModelName = ''',modelName,''';']);
            pLoad.sltest_isharness=false;
            pLoad.sltest_bdroot=modelName;
            pLoad.sltest_sut=modelName;
        end

        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.SimulationIndex = ',sprintf('%d',simIndex),';']);
        if(equTestStatus>0)
            fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.EquivalenceTestStatus = ',sprintf('%d',equTestStatus),';']);
        end
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.ResultID = ',sprintf('%d',resultId),';']);
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.SupportedTestSuites = {''simulink_simulate''};']);


        preLoadCallback=tcObj.getProperty('PreloadCallback',simIndex);
        if~isempty(preLoadCallback)||~isempty(parentTSSetupCbList)
            if(iterationId>0)
                funName=['tcPreLoadCallback_',sprintf('%d_%d_%d',testId,simIndex,iterationId)];
            else
                funName=['tcPreLoadCallback_',sprintf('%d_%d',testId,simIndex)];
            end

            fileName=fullfile(infoPath,[funName,'.m']);
            if(~exist(fileName,'file'))
                callbackList={preLoadCallback};
                if(~isempty(parentTSSetupCbList))
                    callbackList=[parentTSSetupCbList,callbackList];
                end
                stm.internal.MRT.utility.genSTMCallback(fileName,callbackList,0,tcObj,testId,iterationId);
            end
            fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.pre_simulink_load_action  = ''',funName,''';']);
        end


        if(~isempty(harnessName)&&~isempty(harnessOwner))
            harnessString=[harnessName,'%%%',harnessOwner];
            funName=stm.internal.MRT.utility.genModelLoadActionForHarness(...
            infoPath,modelName,harnessString,testId,simIndex);
            fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.simulink_load_action = ''',funName,''';']);
        end


        postLoadCallback=tcObj.getProperty('PostloadCallback',simIndex);
        if~isempty(postLoadCallback)
            if(iterationId>0)
                funName=['tcPostLoadCallback_',sprintf('%d_%d_%d',testId,simIndex,iterationId)];
            else
                funName=['tcPostLoadCallback_',sprintf('%d_%d',testId,simIndex)];
            end
            fileName=fullfile(infoPath,[funName,'.m']);
            if(~exist(fileName,'file'))
                stm.internal.MRT.utility.genSTMCallback(fileName,{postLoadCallback},1,tcObj,testId,iterationId,pLoad);
            end
            fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.post_simulink_load_action = ''',funName,''';']);
        end


        cleanupCallback=tcObj.getProperty('cleanupcallback',simIndex);
        if~isempty(cleanupCallback)
            if(iterationId>0)
                funName=['tcCleanupCallback_',sprintf('%d_%d_%d',testId,simIndex,iterationId)];
            else
                funName=['tcCleanupCallback_',sprintf('%d_%d',testId,simIndex)];
            end
            fileName=fullfile(infoPath,[funName,'.m']);
            if(~exist(fileName,'file'))
                stm.internal.MRT.utility.genSTMCallback(fileName,{cleanupCallback},2,tcObj,testId,iterationId);
            end
            fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.post_simulink_simulate_action = ''',funName,''';']);
        end


        funName=['preSimCallback_',sprintf('%d_%d',resultId,simIndex)];
        fprintf(fid,'%s\n',['TestInfo{',sprintf('%d',itrk),'}.pre_simulink_simulate_action = ''',funName,''';']);

        fprintf(fid,'\n\n');
    end
    fclose(fid);
end

