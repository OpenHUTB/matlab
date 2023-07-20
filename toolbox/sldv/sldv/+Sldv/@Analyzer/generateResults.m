function[status,msg,resultFileNames,sldvData]=generateResults(obj)




    assert(~isempty(obj.mTestComp));

    assert(~strcmp(obj.mTestComp.analysisStatus,'Stopped due to errors'));

    testComp=obj.mTestComp;

    status=1;
    msg=[];
    resultFileNames=Sldv.Utils.initDVResultStruct();
    sldvData=[];

    if obj.mShowUI

        pb=Sldv.Utils.ScopedProgressIndicator('Sldv:SldvresultsSummary:GeneratingResults');
        deleteProgressBar=onCleanup(@()delete(pb));
    end




    if~slavteng('feature','IncrementalHighlighting')
        obj.removeModelHighlighting(obj.mModelH);
    end



    obj.removeReportLinkWarn(obj.mModelH);

    obj.logNewLines(getString(message('Sldv:SldvRun:GeneratingOutputFiles')));

    testComp.profileStage('Design Verifier: Results');
    testComp.getMainProfileLogger().openPhase('Design Verifier: Results');

    activeSettings=testComp.activeSettings;
    sldvprivate('reduceTestCases',testComp);

    if obj.stopRequested()
        msg=obj.displayMessages;
        return;
    end


    testComp.profileStage('GenerateSldvData');
    testComp.getMainProfileLogger().openPhase('GenerateSldvData');

    try
        [sldvData,obj.mResultFileNames,~]=obj.generateData(activeSettings,obj.mResultFileNames);
    catch Mex


        msg=getString(message('Sldv:SldvRun:ErrorWhileGeneratingData'));
        if strfind(Mex.identifier,'Sldv:DataUtils:')==1
            msg=[msg,'. ',Mex.message];
        else
            msg=[msg,getString(message('Sldv:SldvRun:FollowingIssue')),Mex.message];
        end
        obj.logAll(sprintf('%s\n\n',msg));

        testComp.profileStage('end');
        testComp.getMainProfileLogger().closePhase('GenerateSldvData');



        rethrow(Mex);
    end
    testComp.profileStage('end');
    testComp.getMainProfileLogger().closePhase('GenerateSldvData');

    if obj.stopRequested()
        msg=obj.displayMessages;
        return;
    end


    if isequal(activeSettings.SaveHarnessModel,'on')
        testComp.profileStage('GenerateHarnessModel');
        testComp.getMainProfileLogger().openPhase('GenerateHarnessModel');

        obj.mResultFileNames=obj.generateHarness(sldvData,obj.mResultFileNames);

        testComp.profileStage('end');
        testComp.getMainProfileLogger().closePhase('GenerateHarnessModel');
    end

    if obj.stopRequested()
        msg=obj.displayMessages;
        return;
    end


    sldvData=Sldv.DataUtils.updatePerformanceData(sldvData,testComp);


    sldvData=Sldv.DataUtils.storeReleaseInformation(sldvData);



    sldvData=Sldv.DataUtils.updateRebuildModelRepresentationInfo(sldvData,testComp);


    if isequal(activeSettings.SaveReport,'on')
        testComp.profileStage('GenerateSldvReport');
        testComp.getMainProfileLogger().openPhase('GenerateSldvReport');

        try
            obj.mResultFileNames=obj.generateReport(sldvData,[],obj.mResultFileNames);
        catch Mex



            msg=getString(message('Sldv:SldvRun:ErrorGeneratingReport'));
            if strfind(Mex.identifier,'Sldv:RptGen:')==1
                msg=[msg,'. ',Mex.message];
            else
                msg=[msg,getString(message('Sldv:SldvRun:FollowingIssue')),Mex.message];
            end
            obj.logAll(sprintf('%s\n\n',msg));

            testComp.profileStage('end');
            testComp.getMainProfileLogger().closePhase('GenerateSldvReport');

            rethrow(Mex);
        end
        testComp.profileStage('end');
        testComp.getMainProfileLogger().closePhase('GenerateSldvReport');
    end

    if license('test','MATLAB_Report_Gen')&&isequal(activeSettings.SaveReport,'on')&&...
        isequal(activeSettings.ReportPDFFormat,'on')

        testComp.profileStage('GenerateSldvPDFReport');
        testComp.getMainProfileLogger().openPhase('GenerateSldvPDFReport');

        try
            obj.mResultFileNames=obj.generateReport(sldvData,'-fPDF',obj.mResultFileNames);
        catch Mex



            msg=getString(message('Sldv:SldvRun:ErrorGeneratingReport'));
            if strfind(Mex.identifier,'Sldv:RptGen:')==1
                msg=[msg,'. ',Mex.message];
            else
                msg=[msg,getString(message('Sldv:SldvRun:FollowingIssue')),Mex.message];
            end
            obj.logAll(sprintf('%s\n\n',msg));

            testComp.profileStage('end');
            testComp.getMainProfileLogger().closePhase('GenerateSldvPDFReport');

            rethrow(Mex);
        end
        testComp.profileStage('end');
        testComp.getMainProfileLogger().closePhase('GenerateSldvPDFReport');
    end

    obj.logSome(sprintf('\n%s',datestr(now)));

    testComp.profileStage('end');
    testComp.getMainProfileLogger().closePhase('Design Verifier: Results');

    obj.logNewLines(getString(message('Sldv:SldvRun:ResultsGenerationCompleted')));


    sldvData=Sldv.DataUtils.updatePerformanceData(sldvData,testComp);

    warnmsg=Sldv.DataUtils.saveDataToFile(sldvData,testComp.resolvedSettings.DataFileName,testComp.createableSimData);
    if~isempty(warnmsg)
        obj.logAll(sprintf('%s\n',warnmsg,obj.activity()));
        if isfield(testComp.resolvedSettings,'DataFileName')
            testComp.resolvedSettings=rmfield(testComp.resolvedSettings,'DataFileName');
        end
    else
        obj.mResultFileNames.DataFile=testComp.resolvedSettings.DataFileName;
        obj.logAll(obj.html_spaced_label_val(getString(message('Sldv:SldvRun:DataFile')),testComp.resolvedSettings.DataFileName));
    end

    if obj.mShowUI

        [year,month,day,hour,min,sec]=datevec(now);
        sec=floor(sec);
        logBaseName=sprintf('sldv_log_%d_%d_%d_%d_%d_%d',year,month,day,hour,min,sec);
        logFullName=Sldv.utils.settingsFilename(logBaseName,true,'.txt',testComp.analysisInfo.extractedModelH,false,false,obj.mSldvOpts);
        testComp.progressUI.saveTextLog(logFullName);
        testComp.progressUI.logPath=logFullName;
        obj.mResultFileNames.LogFile=logFullName;


        obj.displaySummaryLog(sldvData,obj.mResultFileNames);
    end

    try



        resultsOnModel=strcmp(activeSettings.Mode,'DesignErrorDetection')||...
        strcmp(activeSettings.DisplayResultsOnModel,'on');

        if~slavteng('feature','IncrementalHighlighting')
            if obj.mShowUI&&resultsOnModel&&~ModelAdvisor.isRunning
                modelView=Sldv.ModelView(sldvData,obj.mResultFileNames);
                modelView.view;
                handles=get_param(obj.mModelH,'AutoVerifyData');
                handles.modelView=modelView;
                set_param(obj.mModelH,'AutoVerifyData',handles);
            end
        else










            session=sldvprivate('sldvGetActiveSession',obj.mModelH);
            if(obj.mShowUI&&~ModelAdvisor.isRunning)&&session.HighlightStatusFlag
                handles=get_param(obj.mModelH,'AutoVerifyData');
                if isfield(handles,'modelView')
                    modelView=handles.modelView;
                    modelView.updateSldvData(sldvData,obj.mResultFileNames);
                    modelView.view;
                end
            end
        end
    catch MEx %#ok<NASGU>

    end


    if obj.mShowUI
        try
            testComp.progressUI.finalized=true;
            testComp.progressUI.refreshLogArea();
            testComp.progressUI.showLogArea();
        catch
        end
    end

    try





        if~testComp.recordDvirSim&&~sldvshareprivate('util_is_analyzing_for_fixpt_tool')
            sldvprivate('mdl_current_results',obj.mModelH,obj.mResultFileNames);


            SldvDebugger.setupDebugService(obj.mModelH,sldvData);
        end

        obj.mAnalysisErrorMsg=obj.displayMessages();
        msg=obj.mAnalysisErrorMsg;
    catch
    end

    resultFileNames=obj.mResultFileNames;

    return;
end


