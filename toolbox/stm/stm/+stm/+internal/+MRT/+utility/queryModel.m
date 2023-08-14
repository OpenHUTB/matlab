function out=queryModel(modelName,harnessString,workerId,workerRoot,tcId,type,suppressError)





    if(nargin<7)
        suppressError=false;
    end
    imtHarnessRoot=fullfile(matlabroot,'toolbox','stm','stm','MultiReleaseExecHarness');
    addpath(imtHarnessRoot);
    c=onCleanup(@()rmpath(imtHarnessRoot));

    workspaceRoot=stm.internal.MRT.utility.createWorkspace(0,1,false);

    TestInfo{1}=IMT.TestInfo;
    TestInfo{1}.STM_MRT=true;

    if(isempty(harnessString))
        TestInfo{1}.ModelName=modelName;
    else
        ind=strfind(harnessString,'%%%');
        harnessName=harnessString(1:ind(1)-1);
        TestInfo{1}.ModelName=harnessName;


        infoPath=fullfile(workspaceRoot,'TestInfo',workerId);
        if(~exist(infoPath,'dir'))
            mkdir(infoPath);
        end
        funName=stm.internal.MRT.utility.genModelLoadActionForHarness(...
        infoPath,modelName,harnessString,tcId,1);
        TestInfo{1}.simulink_load_action=funName;
    end
    TestInfo{1}.SupportedTestSuites={'simulink_simulate'};


    if(tcId>0)
        callbackList=stm.internal.MRT.utility.getAncesterCallbacks(tcId);
        tc=sltest.testmanager.TestCase([],tcId);
        tcCb=tc.getProperty('preloadcallback');
        if(~isempty(tcCb))
            callbackList{end+1}=tcCb;
        end

        if(~isempty(callbackList))
            cbStr=join(callbackList,newline);
            TestInfo{1}.pre_simulink_load_action=cbStr{1};
        end
    end

    params={modelName,harnessString};
    paramStr=join(params,''',''');
    if(strcmp(type,'parameter'))
        cmdStr=['simOut = stm.internal.MRT.share.getModelParameters(''',paramStr{1},''');'];
    elseif(strcmp(type,'configset'))
        cmdStr=['simOut = stm.internal.MRT.share.refreshConfigSetHints(''',paramStr{1},''');'];
    elseif(strcmp(type,'signalbuildergroup'))
        cmdStr=['simOut = stm.internal.MRT.share.refreshSigBuilderHints(''',paramStr{1},''');'];
    elseif(strcmp(type,'harness'))
        cmdStr=['simOut = stm.internal.MRT.share.findHarness(''',modelName,''');'];
    end
    TestInfo{1}.pre_simulink_simulate_action=cmdStr;

    imtResult=stm.internal.MRT.utility.runTestInIMT(workerId,workerRoot,workspaceRoot,...
    TestInfo);
    imtResult=imtResult{1};

    hasError=false;
    fields=fieldnames(imtResult);
    for k=1:length(fields)
        fieldName=fields{k};
        if(isfield(imtResult,fieldName))
            if(~imtResult.(fieldName).correctness)
                hasError=true;
                if(~suppressError)
                    error(imtResult.(fieldName).errormsg);
                end
            end
        end
    end
    if(hasError)
        out=[];
    else
        out=imtResult.simulink_simulate.STM.SimOut;
    end

end
