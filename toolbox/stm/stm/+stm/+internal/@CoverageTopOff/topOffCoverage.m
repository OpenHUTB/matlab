function[retTcId,msgList]=topOffCoverage(covFileName,...
    topModel,inAnalyzedModel,isTopLevelModel,...
    harnessOptions,testParentId,testFilePath,testCaseId,testCaseType,...
    srcSimIndex,setAllSimulations,includeExpectedOutput,excelFilePath,...
    sldvTestCaseFilePath,sldvBackToBackMode,shouldThrow)

































    retTcId=0;
    msgList=string.empty;
    usingCvResults=~isempty(covFileName);
    SILMode=[];
    inHarnessModel=harnessOptions.harnessModel;
    harnessOwner=harnessOptions.harnessOwner;
    harnessSRCType=harnessOptions.harnessSrcType;


    assert(srcSimIndex==1||srcSimIndex==2);


    if(testParentId<=0)

        if isfile(testFilePath)
            error(message('stm:general:TestFileAlreadyExist',testFilePath));
        end
        testFilePath=stm.internal.CoverageTopOff.checkFilePath(testFilePath);
    else
        pp=stm.internal.getTestProperty(testParentId,'testsuite');
        testFilePath=pp.testFilePath;
    end
    [~,values]=fileattrib(pwd);
    if(values.UserWrite==0)
        error(message('stm:CoverageStrings:CovTopOff_Error_FolderIsReadOnly',pwd));
    end

    analyzedModel=inAnalyzedModel;
    harnessModel=inHarnessModel;
    revertCMDs={};




    isSIL=~isempty(SILMode);
    isSLCustomCode=false;
    cvdLoaded=false;
    if sldv.code.internal.isXilFeatureEnabled()&&usingCvResults
        [cvTests,cvResults]=cvloadGroup(covFileName);
        cvdLoaded=true;

        isSLCustomCode=~isempty(cvResults)&&cvResults{1}.isSimulinkCustomCode;
        isSIL=~isempty(cvTests)&&SlCov.CovMode.isSIL(cvResults{1}.simMode)&&~isempty(cvResults{1}.codeCovData);
        if isSIL&&(cvResults{1}.isCustomCode||cvResults{1}.isSharedUtility)

            analyzedModel=topModel;
        end
    end


    if isSLCustomCode&&~slfeature('STMTopOffExternalCode')
        error(message('stm:CoverageStrings:CovTopOff_Error_UnsupportedCustomCode'));
    end

    modelToUse=topModel;
    useHarnessForAnalysis=(slfeature('STMSldvUseHarnessForAnalysis')>0)&&...
    ~usingCvResults&&...
    ~isempty(harnessModel);



    if(~stm.internal.util.SimulinkModel.isModelOpenOrLoaded(modelToUse))
        load_system(modelToUse);
        revertCMDs{end+1}=stm.internal.CoverageTopOff.formCMD('close_system',{modelToUse});

        cvdLoaded=false;
    end


    harnessList=sltest.harness.find(topModel,'Name',analyzedModel);
    if~isempty(harnessList)
        if usingCvResults
            harnessModel=analyzedModel;
        end
        inHarnessModel=analyzedModel;
        useHarnessForAnalysis=true;
        harnessOwner=harnessList(1).ownerFullPath;
    end

    if isSLCustomCode
        modelToUse=topModel;
    elseif~isTopLevelModel&&~useHarnessForAnalysis
        modelToUse=analyzedModel;
    end

    if(~stm.internal.util.SimulinkModel.isModelOpenOrLoaded(modelToUse))
        load_system(modelToUse);
        revertCMDs{end+1}=stm.internal.CoverageTopOff.formCMD('close_system',{modelToUse});

        cvdLoaded=false;
    end

    bCreateANewHarness=false;

    if usingCvResults

        usingHarness=~isempty(harnessOwner);
        if(~isempty(harnessOwner)&&isempty(inHarnessModel)&&~useHarnessForAnalysis)
            bCreateANewHarness=true;
            assert(testCaseId<0);
        end
    else


        usingHarness=useHarnessForAnalysis;
    end
    isLibraryHarness=bdIsLibrary(modelToUse);


    currentHarnessList=stm.internal.CoverageTopOff.getOpenHarnessList(modelToUse);

    for k=1:length(currentHarnessList)




        if~(strcmp(currentHarnessList(k).harnessName,inHarnessModel)&&useHarnessForAnalysis)
            sltest.harness.close(currentHarnessList(k).harnessOwner,currentHarnessList(k).harnessName);

            revertCMDs{end+1}=stm.internal.CoverageTopOff.formCMD('stm.internal.util.loadHarness',...
            {currentHarnessList(k).harnessOwner,currentHarnessList(k).harnessName,true});%#ok


            cvdLoaded=false;
        end
    end

    if((isLibraryHarness&&~isSLCustomCode)||useHarnessForAnalysis)
        if(~bCreateANewHarness)
            stm.internal.util.loadHarness(harnessOwner,inHarnessModel);
            modelSldvOpts=sldvoptions(inHarnessModel);
            sltest.harness.close(harnessOwner,inHarnessModel);


            cvdLoaded=false;

        else
            modelSldvOpts=sldvoptions;
        end
    elseif isSLCustomCode
        modelSldvOpts=sldvoptions;
    else
        modelSldvOpts=sldvoptions(modelToUse);
    end

    if(strcmp(get_param(modelToUse,'Lock'),'on'))
        set_param(modelToUse,'Lock','off');
        revertCMDs{end+1}=stm.internal.CoverageTopOff.formCMD('set_param',{modelToUse,'Lock','on'});
    end

    if usingCvResults

        if~cvdLoaded
            [cvTests,cvResults]=cvloadGroup(covFileName);
        end
        opts=getSldvOptionsFromCovData(cvTests,cvResults,modelSldvOpts,isSIL);

        if(usingHarness&&~useHarnessForAnalysis)

            cvd=cvResults{1};
            if~isSIL||~(cvd.isCustomCode||cvd.isSharedUtility)
                cvi.ReportUtils.checkHarnessData(cvd);
            end
        end
    else


        opts=modelSldvOpts.deepCopy();
    end


    if(~bCreateANewHarness)
        hCleanup=onCleanup(@()stm.internal.CoverageTopOff.revertModelSettings(revertCMDs));
    end


    w=warning('off','Sldv:GENCOV:AlreadyFullCoverage');
    oc=onCleanup(@()warning(w));


    opts.RebuildModelRepresentation='Always';

    assert(~isempty(includeExpectedOutput));
    if includeExpectedOutput
        opts.SaveExpectedOutput='on';
    else
        opts.SaveExpectedOutput='off';
    end


    fileNames=[];%#ok<NASGU> 
    if((isLibraryHarness&&~isSLCustomCode)||useHarnessForAnalysis)
        stm.internal.util.loadHarness(harnessOwner,inHarnessModel);






        stmInfo=struct(...
        'topModel',topModel,...
        'harnessOwner',harnessOwner,...
        'harnessName',inHarnessModel,...
        'harnessSrcType',harnessSRCType,...
        'isEnhancedMCDC',sldvBackToBackMode,...
        'isLibraryHarness',isLibraryHarness,...
        'SILHarnessCodePath',harnessOptions.correspondingSILHarnessCodePath,...
        'covData',[]);

        resultsInfo=sldvprivate('sldvAnalysisForSTMHarness',stmInfo,opts,true,sldvTestCaseFilePath);

        fileNames=resultsInfo.fileNames;
        msg=resultsInfo.msg;
        fullCovgFlag=resultsInfo.fullCovAlreadyAchieved;

        stm.internal.CoverageTopOff.close_SLDV_progressUI(inHarnessModel);
        sltest.harness.close(harnessOwner,inHarnessModel);
    else
        if isSIL


            if isempty(SILMode)
                SILMode=cvResults{1}.simMode;
            end
            opts.adjustTestgenTarget(char(SILMode));
        end

        cvRslts=[];
        if usingCvResults
            cvRslts=cvResults{1};
        end





        if sldvBackToBackMode
            [~,fileNames,msg,fullCovgFlag]=sldvprivate('sldvAnalysisForBackToBackMode',...
            topModel,analyzedModel,opts,true,'',false,...
            harnessOptions.correspondingSILHarnessCodePath);
        elseif usingCvResults
            if isSLCustomCode&&slfeature('STMTopOffExternalCode')

                usingHarness=true;
                harnessOwnerBlock=[];%#ok<NASGU> 
                [fileNames,harnessOwnerBlock,msgList,status]=stm.internal.CoverageTopOff.topOffExternalCode(cvRslts,topModel,opts,shouldThrow);
                if~isempty(msgList)
                    return;
                end
            else
                [~,fileNames,~,msg,fullCovgFlag]=sldvrun(analyzedModel,opts,true,cvRslts);
            end
        else
            stmInfo=struct(...
            'topModel',topModel,...
            'harnessOwner',harnessOwner,...
            'harnessName',inHarnessModel,...
            'harnessSrcType',harnessSRCType,...
            'isEnhancedMCDC',sldvBackToBackMode,...
            'isLibraryHarness',isLibraryHarness,...
            'SILHarnessCodePath',harnessOptions.correspondingSILHarnessCodePath,...
            'covData',[]);

            resultsInfo=sldvprivate('sldvAnalysisForSTMHarness',stmInfo,opts,true,sldvTestCaseFilePath);

            fileNames=resultsInfo.fileNames;
            msg=resultsInfo.msg;
            fullCovgFlag=resultsInfo.fullCovAlreadyAchieved;
        end

        stm.internal.CoverageTopOff.close_SLDV_progressUI(modelToUse);
    end



    if~isSLCustomCode
        matFile=fileNames.DataFile;
        if strlength(matFile)==0
            if fullCovgFlag
                error(message('stm:CoverageStrings:CovTopOff_Warning_AlreadyFullCoverageAchieved'));
            elseif isstruct(msg)
                msgList=string({msg.msg});
            elseif ischar(msg)
                msgList=string(msg);
            end

            if shouldThrow
                error(message('stm:CoverageStrings:CovTopOff_Error_SldvError',strjoin(msgList,'\n')));
            end
            status=false;
        else
            status=true;
        end
    end

    if~status
        return;
    end



    for i=1:numel(fileNames)
        if~isSLCustomCode
            matFile=fileNames.DataFile;
        else
            matFile=fileNames{i}.DataFile;
        end
        sldvFileContent=load(matFile);
        nGroups=0;
        if(isfield(sldvFileContent,'sldvData'))
            if isfield(sldvFileContent.sldvData,'TestCases')
                nGroups=length(sldvFileContent.sldvData.TestCases);
            elseif(isfield(sldvFileContent.sldvData,'CounterExamples'))
                nGroups=length(sldvFileContent.sldvData.CounterExamples);
            end
        end
        if(nGroups==0)
            error(message('stm:CoverageStrings:EmptySLDVData'));
        end

        existingIterations=[];
        if(usingHarness)
            sldvData=sltest.internal.convertSldvData(sldvFileContent);
            sldvDataInfo.Data=sldvData;
            sldvDataInfo.FilePath=matFile;

            param.Model=modelToUse;
            param.harnessToDelete='';
            param.CreateHarness=bCreateANewHarness;
            if isSLCustomCode
                param.ownerPath=harnessOwnerBlock{i};
            else
                param.ownerPath=harnessOwner;
            end
            param.excelFilePath=excelFilePath;
            if(param.CreateHarness)
                param.TestHarnessName=Simulink.harness.internal.getDefaultName(param.Model,harnessOwner,[]);
                param.TestHarnessSource=harnessSRCType;
            else
                if usingCvResults&&~isfield(sldvData.ModelInformation,'SubsystemPath')&&...
                    isfield(sldvData.ModelInformation,'HarnessOwnerModel')&&strcmp(harnessSRCType,'Inport')
                    param.TestHarnessName=sldvData.ModelInformation.Name;
                else
                    param.TestHarnessName=harnessModel;
                end
            end
            if isfield(sldvData.ModelInformation,'ExtractedModel')
                param.ExtractedModelPath=sldvData.ModelInformation.ExtractedModel;
            else
                param.ExtractedModelPath='';
            end
            param.TestFileName=testFilePath;
            param.TestCase=sltest.testmanager.TestCase.empty;
            if(testCaseId>0)
                tfObj=sltest.testmanager.load(param.TestFileName);
                param.TestCase=stm.internal.CoverageTopOff.findTestCaseFromTestFileById(tfObj,testCaseId);
                existingIterations=param.TestCase.getIterations();
            end
            newTestCaseCreated=isempty(param.TestCase);

            param.TestType='baseline';
            if(testCaseType==sltest.testmanager.TestCaseTypes.Simulation)
                param.TestType='simulation';
            elseif(testCaseType==sltest.testmanager.TestCaseTypes.Equivalence)
                param.TestType='equivalence';
            end
            param.FromSTMTopOff=true;
            if usingCvResults
                param.CovResult=cvResults{1};
            end

            param.SimulationIndex=srcSimIndex;
            if(sltest.testmanager.TestCaseTypes.Equivalence==testCaseType&&setAllSimulations)
                param.SimulationIndex=[1,2];
            end
            if(newTestCaseCreated)
                param.SimulationIndex=1;
            end
            [~,~,tcObj]=stm.internal.sldv.importSLDVDataMain(sldvDataInfo,param);
            retTcId=tcObj.getID();

            newTestFileCreated=(testParentId<=0);
            if(newTestFileCreated)
                tfObj=sltest.testmanager.load(testFilePath);
            end
        else
            newTestFileCreated=false;
            newTestCaseCreated=false;
            if(testCaseId>0)
                tfObj=stm.internal.CoverageTopOff.getTestFileFromTestCaseId(testCaseId);
                tcObj=stm.internal.CoverageTopOff.findTestCaseFromTestFileById(tfObj,testCaseId);
                existingIterations=tcObj.getIterations();
                if isempty(existingIterations)
                    stm.internal.CoverageTopOff.addIterationWithActiveSettings(tcObj);
                end
            else
                [tcObj,tfObj,newTestFileCreated]=stm.internal.CoverageTopOff.createTestCase(testParentId,testFilePath,testCaseType);
                if isSIL
                    tcObj.setProperty('SimulationMode','Software-in-the-Loop (SIL)');
                end
                newTestCaseCreated=true;
            end
            retTcId=tcObj.getID();

            simIndex=srcSimIndex;
            if(sltest.testmanager.TestCaseTypes.Equivalence==testCaseType&&setAllSimulations)
                simIndex=[1,2];
            end

            stm.internal.setupTestCase(tcObj,modelToUse,[],matFile,simIndex,excelFilePath);




            stm.internal.CoverageTopOff.deActivateTestOverrides(tcObj);

            if newTestFileCreated&&~isempty(tfObj)&&usingCvResults
                stm.internal.CoverageTopOff.setupCoverageSettings(tfObj,cvResults{1});
            end
        end


        if(sltest.testmanager.TestCaseTypes.Equivalence==testCaseType&&~isempty(tcObj))
            if(newTestCaseCreated)

                tcObj.copySimulationSettings(1,2);
            end

            if(setAllSimulations||newTestCaseCreated)
                stm.internal.CoverageTopOff.realignIterationsForEquivalenceTest(tcObj,existingIterations);
            end
        end

        if exist('tfObj','var')&&exist('cvResults','var')
            stm.internal.CoverageTopOff.setFilters(tfObj,cvResults{1});
        end
        if(newTestFileCreated)
            tfObj.saveToFile();
        end
    end
end

function metric=getCovSettings(cvTests,cvResults,isSIL)
    if~isempty(cvTests)

        metric=cvTests.settings;
    else


        if isSIL
            codeTr=cvResults.codeCovData.CodeTr;
            metric.decision=~isempty(codeTr.getDecisionPoints(codeTr.Root));
            metric.condition=~isempty(codeTr.getConditionPoints(codeTr.Root));
            metric.mcdc=~isempty(codeTr.getMCDCPoints(codeTr.Root));
            metric.relationalop=~isempty(codeTr.getRelationalBoundaryPoints(codeTr.Root));
        else
            covRes=cvResults.metrics;
            metric.decision=~isempty(covRes.decision);
            metric.condition=~isempty(covRes.condition);
            metric.mcdc=~isempty(covRes.mcdc);
            metric.relationalop=~isempty(covRes.testobjectives.cvmetric_Structural_relationalop);
        end
    end
end

function opts=getSldvOptionsFromCovData(cvTests,cvResults,modelSldvOpts,isSIL)
    opts=modelSldvOpts.deepCopy();
    opts.IgnoreCovSatisfied='off';
    opts.SaveHarnessModel='off';
    opts.Mode='TestGeneration';


    metric=getCovSettings(cvTests{1},cvResults{1},isSIL);


    if metric.mcdc
        opts.ModelCoverageObjectives='MCDC';
    else
        if metric.decision&&~metric.condition
            opts.ModelCoverageObjectives='Decision';
        elseif metric.condition
            opts.ModelCoverageObjectives='ConditionDecision';
        else
            opts.ModelCoverageObjectives='None';
        end
    end


    if metric.relationalop
        opts.IncludeRelationalBoundary='on';
    else
        opts.IncludeRelationalBoundary='off';
    end
end

function[tests,data]=cvloadGroup(filename)



    if isa(filename,'cvdata')
        data={filename};
        tests={filename.test};
    else
        [tests,data]=cvload(filename);
    end
    if isempty(data)
        error(message('stm:CoverageStrings:CovTopOff_Error_EmpytCoverageResult',filename));
    elseif isa(data{1},'cv.cvdatagroup')
        tests={tests{1}.get(tests{1}.allNames{1})};
        data=data{1}.getAll;
    end
end


