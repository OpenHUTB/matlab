



classdef CoverageTopOff<handle
    methods(Static)


        [retTcId,msgList]=topOffCoverage(covFileName,...
        topModel,inAnalyzedModel,isTopLevelModel,...
        harnessOptions,testParentId,testFilePath,testCaseId,testCaseType,...
        srcSimIndex,setAllSimulations,includeExpectedOutput,excelFilePath,...
        sldvTestCaseFilePath,sldvBackToBackMode,shouldThrow);


        [fileNames,harnessOwner,msgList,status]=topOffExternalCode(cvRslts,...
        topModel,modelOpts,shouldThrow);


        retPath=checkFilePath(testFilePath);

        cmd=formCMD(cmd,params);


        harnessList=getOpenHarnessList(topModel);


        revertModelSettings(cmds);


        [tcObj,tfObj,newFileCreated]=createTestCase(testFileId,testFilePath,testCaseType);


        realignIterationsForEquivalenceTest(tcObj,existingIterations);


        tfObj=getTestFileFromTestCaseId(tcId);


        setupCoverageSettings(tf,cvResult);

        tcObj=findTestCaseFromTestFileById(tfObj,tcId);

        close_SLDV_progressUI(refMdl);


        deActivateTestOverrides(testCaseObj);



        addIterationWithActiveSettings(testCaseObj);
        setFilters(tfObj,cvResult);
    end
end
