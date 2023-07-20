function urlcall(method,dataFile,model,idx,objectiveIdx,objectiveIdxForFilter,filterLinkType)




    persistent exportProgressBar;

    if nargin>1
        if~isempty(dataFile)
            dataFile=urldecode(dataFile);
        end
    end
    if nargin>2
        model=urldecode(model);
    else
        model=[];
    end

    if nargin<7
        filterLinkType=3;
    end

    if nargin<6
        objectiveIdxForFilter=[];
    end

    resultDialogH=findResultDialog(model,method);


    methodList={'highlight','report','harness'};
    if ismember(method,methodList)
        activeHarness=Simulink.harness.find(model,'OpenOnly','on');
        if~isempty(activeHarness)
            msg=DAStudio.message('Simulink:Harness:AbortSLDVUrlCall',activeHarness.name,activeHarness.model);
            msgTitle=DAStudio.message('Simulink:Harness:AbortSLDVUrlCallTitle');
            msgbox(msg,msgTitle,'error');
            return;
        end
    elseif strcmp(method,'export_to_sltest')
        activeHarness=Simulink.harness.find(model,'OpenOnly','on');
        if~isempty(activeHarness)&&~strcmp(model,activeHarness.name)
            msg=DAStudio.message('Simulink:Harness:AbortSLDVUrlCall',activeHarness.name,activeHarness.model);
            msgTitle=DAStudio.message('Simulink:Harness:AbortSLDVUrlCallTitle');
            msgbox(msg,msgTitle,'error');
            return;
        end
    end

    switch(lower(method))
    case 'highlight'
        setDialogTextBrowserEnable(resultDialogH,false);
        removeHilite(model);

        handles=get_param(model,'AutoVerifyData');

        if isfield(handles,'modelView')&&handles.modelView.isvalid





            modelH=get_param(model,'Handle');
            session=sldvprivate('sldvGetActiveSession',modelH);
            if isempty(session)
                session=sldvprivate('sldvCreateSession',modelH,[],[],true,[]);
            end

            session.toggleHighlighting(true);

            setDialogTextBrowserEnable(resultDialogH,true);
            return;
        end


        progressBar=createProgressBar(sprintf('%s',getString(message('Sldv:urlcall:HighlightingModelWith',model))));
        try
            modelH=get_param(model,'Handle');
            s=load(dataFile);
            sldvData=s.sldvData;
            sldvData=Sldv.DataUtils.convertToCurrentFormat(modelH,sldvData);
            handles=get_param(modelH,'AutoVerifyData');
            if isfield(handles,'modelView')&&handles.modelView.isvalid
                delete(handles.modelView);
            end
            if isfield(handles,'currentResult')
                resultFiles=handles.currentResult;
            else
                resultFiles=Sldv.Utils.initDVResultStruct();
            end
            modelView=Sldv.ModelView(sldvData,resultFiles);
            handles.modelView=modelView;
            set_param(modelH,'AutoVerifyData',handles);

            modelH=get_param(model,'Handle');
            session=sldvprivate('sldvGetActiveSession',modelH);
            if isempty(session)
                session=sldvprivate('sldvCreateSession',this.modelH,[],[],true,[]);
            end

            session.toggleHighlighting(true);

        catch Mex %#ok<NASGU>
        end

        if~isempty(progressBar)
            progressBar=[];%#ok<NASGU>
        end
        setDialogTextBrowserEnable(resultDialogH,true);

    case 'removehighlight'
        modelH=get_param(model,'Handle');
        session=sldvprivate('sldvGetActiveSession',modelH);
        if isempty(session)
            [~,session]=sldvgetsession(modelH,[],true);
        end

        session.toggleHighlighting(false);
    case 'opendir'
        if ispc
            dirname=dataFile;
            doscmd=sprintf('explorer.exe /e, "%s" &',dirname);
            dos(doscmd);
        end

    case 'openmodel'
        open_model(dataFile);

    case 'openreport'






        handles=get_param(model,'AutoVerifyData');
        if isfield(handles,'analysisFilter')&&handles.analysisFilter.isvalid
            filter=handles.analysisFilter;
            if filter.hasUnappliedChanges
                filter.show;
                errordlg(getString(message('Sldv:Filter:ApplyOrRevertOrCloseFilterRptGen')),...
                getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),...
                'modal');
                return;
            end
        end

        reportFile=dataFile;
        expectUrl=['file://localhost/',strrep(reportFile,'\','/')];
        urlL=numel(expectUrl);






        warning('off','MATLAB:web:BrowserAndUrlOuptputArgsRemovedInFutureRelease');
        [st,brws,url]=web;%#ok<WEBREMOVE>
        if st==0&&strncmp(url,expectUrl,urlL)
            brws.grabFocus;
        elseif st==0&&isempty(url)
            brws.setCurrentLocation(expectUrl);
        else
            web(reportFile);
        end
        warning('on','MATLAB:web:BrowserAndUrlOuptputArgsRemovedInFutureRelease');

    case 'openpdfreport'
        handles=get_param(model,'AutoVerifyData');
        if isfield(handles,'analysisFilter')&&handles.analysisFilter.isvalid
            filter=handles.analysisFilter;
            if filter.hasUnappliedChanges
                filter.show;
                errordlg(getString(message('Sldv:Filter:ApplyOrRevertOrCloseFilterRptGen')),...
                getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),...
                'modal');
                return;
            end
        end


        rptgen.pdfmanage('open',dataFile);

    case 'editlog'
        logFile=dataFile;
        edit(logFile);

    case 'loaddata'

        vars=evalin('base','whos(''sldvData*'');');
        if isempty(vars)
            varName='sldvData';
        else
            allVars={vars.name};
            biggestNum=0;
            for idx=1:length(allVars)
                suffix=allVars{idx}(9:end);
                x=str2double(suffix);
                if~isnan(x)&&x>biggestNum
                    biggestNum=x;
                end
            end
            varName=sprintf('sldvData%d',floor(biggestNum)+1);
        end
        [dataFolder,basename,dext]=fileparts(dataFile);
        s=load(dataFile);
        assignin('base',varName,s.sldvData);
        msg=sprintf('%s',getString(message('Sldv:urlcall:VariableContainsData',varName,[basename,dext],dataFolder)));
        title=getString(message('Sldv:urlcall:DataLoadedBaseWorkspace'));
        msgbox(msg,title);
    case 'viewinsdi'
        setDialogTextBrowserEnable(resultDialogH,false);
        try
            progressBar=createProgressBar(getString(message('Sldv:urlcall:ConvertLoadSDI')));
            Simulink.sdi.createRun('','file',dataFile);
            Simulink.sdi.view;
        catch
        end
        if~isempty(progressBar)
            progressBar=[];%#ok<NASGU>
        end
        setDialogTextBrowserEnable(resultDialogH,true);

    case 'report'
        setDialogTextBrowserEnable(resultDialogH,false);
        modelH=get_param(model,'Handle');
        currentResults=mdl_current_results(modelH);

        if isempty(dataFile)
            handles=get_param(modelH,'AutoVerifyData');
            if isfield(handles,'modelView')&&handles.modelView.isvalid
                sldvData=handles.modelView.data;
                progressHandle=handles.modelView.getProgressHandle;
                elapsedTime=progressHandle.testComp.getElapsedTime;
                sldvData.AnalysisInformation.ElapsedTime=elapsedTime;
                [~,resultPaths]=mdl_result_locations(modelH,sldvData.AnalysisInformation.Options,false,false,true);
            end
        else
            [sldvData,resultPaths]=readDataFile(dataFile,modelH);
        end


        if exist(resultPaths.ReportFileName,'file')
            delete(resultPaths.ReportFileName);
        end


        sldvData.AnalysisInformation.Options.DisplayReport='on';

        handles=get_param(model,'AutoVerifyData');
        filter=[];
        if isfield(handles,'analysisFilter')&&handles.analysisFilter.isvalid
            filter=handles.analysisFilter;
            if filter.hasUnappliedChanges
                filter.show;
                errordlg(getString(message('Sldv:Filter:ApplyOrRevertOrCloseFilterRptGen')),...
                getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),...
                'modal');
                return;
            end
        end

        [~,reportFilePath]=sldvreport(sldvData,[],resultPaths.ReportFileName,true,[],filter);
        currentResults.Report=reportFilePath;
        updateResults(sldvData,currentResults,modelH);
        setDialogTextBrowserEnable(resultDialogH,true);

    case 'create_export_progress_bar'
        exportProgressBar=createProgressBar(sprintf('%s',getString(message('Sldv:urlcall:ExportingDataToSLTest'))));

    case 'delete_export_progress_bar'
        if~isempty(exportProgressBar)
            exportProgressBar=[];
        end

    case 'pdfreport'
        modelH=get_param(model,'Handle');
        currentResults=mdl_current_results(modelH);

        if isempty(dataFile)
            handles=get_param(modelH,'AutoVerifyData');
            if isfield(handles,'modelView')&&handles.modelView.isvalid
                sldvData=handles.modelView.data;
                [~,resultPaths]=mdl_result_locations(modelH,sldvData.AnalysisInformation.Options,false,false,true);
            end
        else
            [sldvData,resultPaths]=readDataFile(dataFile,modelH);
        end



        [path,fileName,~]=fileparts(resultPaths.ReportFileName);
        resultFileName=[fileName,'.pdf'];
        if~isempty(path)
            resultFileName=fullfile(path,resultFileName);
        end
        if exist(resultFileName,'file')
            delete(resultFileName);
        end


        sldvData.AnalysisInformation.Options.DisplayReport='on';

        handles=get_param(modelH,'AutoVerifyData');
        filter=[];
        if isfield(handles,'analysisFilter')&&handles.analysisFilter.isvalid
            filter=handles.analysisFilter;
            if filter.hasUnappliedChanges
                filter.show;
                errordlg(getString(message('Sldv:Filter:ApplyOrRevertOrCloseFilterRptGen')),...
                getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),...
                'modal');
                return;
            end
        end

        [~,reportFilePath]=sldvreport(sldvData,[],resultPaths.ReportFileName,true,'PDF',filter);
        currentResults.PDFReport=reportFilePath;
        updateResults(sldvData,currentResults,modelH);

    case 'export_to_sltest'
        setDialogTextBrowserEnable(resultDialogH,false);
        if strcmp(get_param(model,'isHarness'),'on')
            ownerModel=Simulink.harness.internal.getHarnessOwnerBD(model);
            harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(model);
        else
            ownerModel=model;
            harnessInfo=[];
        end

        ownerModelH=get_param(ownerModel,'Handle');
        removeHilite(ownerModelH);
        try
            sldvData=readDataFile(dataFile,ownerModelH);

            if isempty(harnessInfo)
                if isfield(sldvData.ModelInformation,'SubsystemPath')
                    owner=sldvData.ModelInformation.SubsystemPath;
                elseif isfield(sldvData.ModelInformation,'ExtractedModel')
                    owner=get_param(getExtractedMdl(sldvData,ownerModelH),'name');
                    ownerModel=owner;
                else
                    owner=sldvData.ModelInformation.Name;
                end
            else
                owner=harnessInfo.ownerFullPath;
            end

            if~isfield(sldvData.ModelInformation,'SubsystemPath')&&...
                isfield(sldvData.ModelInformation,'HarnessOwnerModel')&&...
                ~slfeature('ExportSLDVTestCaseDialog')



                urlcall('create_export_progress_bar');
                [~,~,testFileName]=sltest.import.sldvData(dataFile,...
                'CreateHarness',false,...
                'TestHarnessName',sldvData.ModelInformation.Name);


                sltest.testmanager.view;
                sltest.testmanager.load(testFileName);

                urlcall('update_sltest_result',urlencode(dataFile),urlencode(sldvData.ModelInformation.Name),testFileName);
                setDialogTextBrowserEnable(resultDialogH,true);
            elseif slfeature('ExportSLDVTestCaseDialog')

                reuseHarness=~isfield(sldvData.ModelInformation,'SubsystemPath')&&isfield(sldvData.ModelInformation,'HarnessOwnerModel');
                [defaultHarnessName,~]=Simulink.harness.internal.getSLDVHarnessName(ownerModel,owner,sldvData.AnalysisInformation.Options);
                exportDlgH=Sldv.Utils.ExportSLDVTestCaseDialog.create(get_param(owner,'UDDObject'),...
                dataFile,defaultHarnessName,resultDialogH,reuseHarness);
                if~isempty(resultDialogH)
                    resultDialogSrc=resultDialogH.getSource;
                    resultDialogSrc.setSelectDialogH(exportDlgH);
                end
            else
                activeHarness=Simulink.harness.find(ownerModel,'OpenOnly','on');

                hList=Simulink.harness.internal.find(owner,'SearchDepth',0);
                if~isempty(hList)


                    hNames={hList.name};
                    [defaultHarnessName,~]=Simulink.harness.internal.getSLDVHarnessName(ownerModel,owner,sldvData.AnalysisInformation.Options);
                    selectDialogH=Sldv.Utils.sldvExportToSLTestDialog.create(get_param(owner,'UDDObject'),dataFile,hNames,defaultHarnessName,activeHarness,model,resultDialogH);
                    if~isempty(resultDialogH)
                        resultDialogSrc=resultDialogH.getSource;
                        resultDialogSrc.setSelectDialogH(selectDialogH);
                    end
                else

                    urlcall('create_export_progress_bar');
                    if~isempty(activeHarness)



                        Simulink.harness.close(activeHarness.ownerHandle,activeHarness.name);
                    end

                    [~,~,testFileName]=sltest.import.sldvData(dataFile);

                    sltest.testmanager.view;
                    sltest.testmanager.load(testFileName);
                    urlcall('update_sltest_result',urlencode(dataFile),urlencode(sldvData.ModelInformation.Name),testFileName);
                    setDialogTextBrowserEnable(resultDialogH,true);
                end
            end

        catch Mex
            urlcall('delete_export_progress_bar');
            setDialogTextBrowserEnable(resultDialogH,true);


            if strcmp(Mex.identifier,'Simulink:modelReference:MdlRefSaveCanceled')
            else
                msgTitle=DAStudio.message('Simulink:Harness:AbortSLDVUrlCallTitle');
                msgbox(Mex.message,msgTitle,'error');
            end
        end

    case 'savetospreadsheet'

        setDialogTextBrowserEnable(resultDialogH,false);
        ocBrowser=onCleanup(@()setDialogTextBrowserEnable(resultDialogH,true));


        progressBar=createProgressBar(sprintf('%s',getString(message('Sldv:urlcall:SavingToSpreadsheet'))));
        cleanUpProgressBar=onCleanup(@()delete(progressBar));

        try

            spreadsheetFilePath=sldvgenspreadsheet(model,dataFile);

            delete(cleanUpProgressBar);


            [basePath,fileName,ext]=fileparts(spreadsheetFilePath);

            msg=getString(message("Sldv:urlcall:SpreadsheetSavedAs",[fileName,ext],basePath));
            msgTitle=getString(message('Sldv:urlcall:SpreadsheetSaved'));
            helpdlg(msg,msgTitle);
        catch Mex

            delete(cleanUpProgressBar);


            errordlg(Mex.message);
        end

    case 'update_sltest_result'

        testFile=idx;
        if isstruct(dataFile)
            sldvData=dataFile;
        else
            s=load(dataFile);
            sldvData=s.sldvData;
        end

        model=sldvData.ModelInformation.Name;
        if~isfield(sldvData.ModelInformation,'HarnessOwnerModel')
            isTestHarness=false;
            if isfield(sldvData.ModelInformation,'ExtractedModel')
                ownerModel=get_param(getExtractedMdl(sldvData,model),'name');
            else
                ownerModel=model;
            end
        else
            isTestHarness=true;
            ownerModel=sldvData.ModelInformation.HarnessOwnerModel;
        end

        activeHarness=Simulink.harness.find(ownerModel,'OpenOnly','on');
        if isTestHarness
            if isempty(activeHarness)

                urlcall('delete_export_progress_bar');
                setDialogTextBrowserEnable(resultDialogH,true);
                return;
            else


                if~strcmp(activeHarness.name,model)
                    urlcall('delete_export_progress_bar');
                    setDialogTextBrowserEnable(resultDialogH,true);
                    DaStudio.error('active harness name does not match the analyzed harness');
                end
            end
        end

        modelH=get_param(model,'Handle');
        currentResults=mdl_current_results(modelH);
        currentResults.SLTestFile=testFile;
        updateResults(sldvData,currentResults,modelH);
        urlcall('delete_export_progress_bar');

    case 'view_sltest_result'

        setDialogTextBrowserEnable(resultDialogH,false);
        sltest.testmanager.view;
        sltest.testmanager.load(dataFile);
        setDialogTextBrowserEnable(resultDialogH,true);

    case 'debugusingslicerinformer'




        modelH=get_param(model,'Handle');


        avData=get_param(modelH,'AutoVerifyData');
        assert(~isempty(avData.DebugService));

        debugService=avData.DebugService;
        SID=debugService.getSidFromObjectiveIdx(objectiveIdx);
        debugService.setupSlicer(SID,objectiveIdx);

    case 'harness'
        setDialogTextBrowserEnable(resultDialogH,false);
        modelH=get_param(model,'Handle');
        currentResults=mdl_current_results(modelH);

        if~isempty(currentResults.HarnessModel)
            open_model(currentResults.HarnessModel);
        else
            progressBar=createProgressBar(sprintf('%s',getString(message('Sldv:urlcall:GeneratingHarnessModel',model))));
            cleanUpProgressBar=onCleanup(@()delete(progressBar));

            modelH=get_param(model,'Handle');
            currentResults=mdl_current_results(modelH);
            removeHilite(model);

            try
                if isempty(dataFile)
                    handles=get_param(modelH,'AutoVerifyData');
                    if isfield(handles,'modelView')&&handles.modelView.isvalid
                        sldvData=handles.modelView.data;
                        extractMdlH=getExtractedMdl(sldvData,modelH);
                    end
                else
                    [sldvData,~,~,extractMdlH]=readDataFile(dataFile,modelH);
                end
                opts=sldvoptions(modelH);
                [~,resultPaths]=mdl_result_locations(modelH,opts,false,false,true);

                hopts=sldvharnessopts;
                hopts.harnessFilePath=resultPaths.HarnessModelFileName;
                hopts.modelRefHarness=strcmp(opts.ModelReferenceHarness,'on');
                hopts.usedSignalsOnly=true;
                hopts.harnessSource=opts.HarnessSource;

                harnessFile=sldvmakeharness(extractMdlH,sldvData,hopts);
            catch Mex
                if~isempty(progressBar)
                    progressBar=[];
                end



                if strcmp(Mex.identifier,'Simulink:modelReference:MdlRefSaveCanceled')
                    harnessFile='';
                else
                    setDialogTextBrowserEnable(resultDialogH,true);
                    Simulink.output.error(Mex,...
                    'Component','Simulink Design Verifier',...
                    'Category','SLDV');
                    return;
                end
            end

            if~isempty(progressBar)
                progressBar=[];%#ok<NASGU>
            end

            currentResults.HarnessModel=harnessFile;
            updateResults(sldvData,currentResults,modelH);
        end

        if(nargin>3)&&~isempty(idx)
            try
                [~,mdlName,~]=fileparts(currentResults.HarnessModel);
                harnessSource=Sldv.harnesssource.Source.getSource(mdlName);
                harnessSource.setActiveTestcase(idx);
                open_system(harnessSource.blockH);
            catch Mex %#ok<NASGU>
            end
        end
        setDialogTextBrowserEnable(resultDialogH,true);

    case 'pathhighlight'
        modelH=get_param(model,'Handle');
        handles=get_param(modelH,'AutoVerifyData');
        if isfield(handles,'modelView')&&handles.modelView.isvalid
            sldvData=handles.modelView.data;
            highlightPath(sldvData,idx);
        end

    case 'pathhighlight_in_report'
        opened_model=find_system('type','block_diagram');
        [~,mdltohiliete]=fileparts(model);
        if~ismember(mdltohiliete,opened_model)
            open_system(model);
        end

        modelH=get_param(mdltohiliete,'Handle');
        handles=get_param(modelH,'AutoVerifyData');
        if isfield(handles,'currentResult')
            sldvData=readDataFile(handles.currentResult.DataFile,modelH);
            highlightPath(sldvData,idx);
        else
            warndlg(getString(message('Sldv:SldvReport:NeedToLoadData')));
        end

    case 'covreport'
        setDialogTextBrowserEnable(resultDialogH,false);
        progressBar=createProgressBar(sprintf('%s',getString(message('Sldv:urlcall:SimulatingModelWith',model))));
        modelH=get_param(model,'Handle');

        runOpts=sldvruntestopts;
        runOpts.coverageEnabled=true;

        try
            [sldvData,~,~,extractMdlH]=readDataFile(dataFile,modelH);

            sldvOpt=sldvData.AnalysisInformation.Options;
            isExtractedMdl=isfield(sldvData.ModelInformation,'ExtractedModel');
            cvt=sldvprivate('create_cvtest',extractMdlH,sldvOpt,isExtractedMdl);

            runOpts.coverageSetting=cvt;
            activeSession=sldvprivate('sldvGetActiveSession',modelH);

            if~isempty(activeSession)


                [covTotal,sldvTcIds]=activeSession.getCovData(sldvData.TestCases);




                sldvTcIdNoCv=setdiff(1:numel(sldvData.TestCases),sldvTcIds);
                runOpts.testIdx=sldvTcIdNoCv;
                if~isempty(sldvTcIdNoCv)
                    [~,newCovData]=sldvruntest(extractMdlH,sldvData,runOpts);

                    if~isempty(covTotal)&&~isempty(newCovData)
                        covTotal=covTotal+newCovData;
                    elseif~isempty(newCovData)
                        covTotal=newCovData;
                    end
                end
            else


                [~,covTotal]=sldvruntest(extractMdlH,sldvData,runOpts);
            end

            if isa(covTotal,'cv.cvdatagroup')
                allCovData=covTotal.getAll;
            else
                allCovData{1}=covTotal;
            end

            for idx=1:length(allCovData)
                [hasStartupVariants,hasStateflowVariants]=...
                Sldv.CvApi.hasStartupOrStateflowVariants(allCovData{idx});

                if strcmp(sldvOpt.AnalyzeAllStartupVariants,'on')&&hasStartupVariants






                    allCovData{idx}.excludeInactiveVariants=false;
                elseif hasStateflowVariants||hasStartupVariants

                    allCovData{idx}.excludeInactiveVariants=true;
                end
            end

            removeHilite(model);
        catch Mex
            if~isempty(progressBar)
                progressBar=[];%#ok<NASGU>
            end
            setDialogTextBrowserEnable(resultDialogH,true);
            rethrow(Mex);
        end

        if~isempty(progressBar)
            progressBar=[];%#ok<NASGU>
        end

        [resultDir,~,~]=fileparts(dataFile);

        [year,month,day,hour,min,sec]=datevec(now);
        sec=floor(sec);
        fileName=fullfile(resultDir,sprintf('cov_of_sldv_%d_%d_%d_%d_%d_%d.html',year,month,day,hour,min,sec));
        cvhtml(fileName,covTotal);
        fprintf(1,'\n%s\n',getString(message('Sldv:urlcall:CreatedModelCoverageReport',fileName)));
        setDialogTextBrowserEnable(resultDialogH,true);

    case 'filter'
        handles=get_param(model,'AutoVerifyData');
        data=[];
        if isempty(dataFile)
            if isfield(handles,'modelView')&&handles.modelView.isvalid
                data=handles.modelView.data;
            end
        else
            s=load(dataFile);
            data=s.sldvData;
        end

        if isfield(handles,'analysisFilter')&&handles.analysisFilter.isvalid
            filter=handles.analysisFilter;

            if filterLinkType==2



                [~,activeFilterFile,~]=fileparts(filter.fileName);

                analysisFilterFile='';
                if strcmp(data.AnalysisInformation.Options.CovFilter,'on')
                    [~,analysisFilterFile,~]=fileparts(data.AnalysisInformation.Options.CovFilterFileName);
                end

                if~isempty(analysisFilterFile)&&~strcmp(activeFilterFile,analysisFilterFile)

                    filter.show;
                    errordlg(getString(message('Sldv:Filter:LoadCorrectFilter',...
                    activeFilterFile,...
                    analysisFilterFile)),...
                    getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),...
                    'modal');
                    return;
                end
            end
        else
            modelName=get_param(model,'Name');
            if strcmp(data.AnalysisInformation.Options.CovFilter,'on')

                filterFileName=data.AnalysisInformation.Options.CovFilterFileName;
                filter=Sldv.Filter.getInstance(modelName,filterFileName);
            else

                filter=Sldv.Filter.createFilterEditor(modelName,'');
                filter.fileName=Sldv.Filter.defaultFileName;
            end

            handles.analysisFilter=filter;
            set_param(model,'AutoVerifyData',handles);
        end

        filter.show(Sldv.DataUtils.isXilSldvData(data));
        if filterLinkType<3
            processObjectiveForFilter(filter,data,objectiveIdxForFilter,filterLinkType,true);
        end
    case 'deadlogicsuggestionshortcircuit'
        try
            openDocFrom('DeadLogicSuggestionShortCircuit');
        catch

        end

    case 'deadlogicsuggestionconditionallyexecuteinputs'
        try
            openDocFrom('DeadLogicSuggestionConditionallyExecuteInputs');
        catch

        end

    otherwise
        error(message('Sldv:urlcall:Unknown'));
    end
end

function openDocFrom(aDocAnchor)
    helpview(fullfile(docroot,'sldv','sldv.map'),aDocAnchor);
end

function removeHighlightingPreserveData(model)
    modelH=get_param(model,'Handle');
    handles=get(modelH,'AutoVerifyData');
    if isfield(handles,'modelView')&&handles.modelView.isvalid
        handles.modelView.removeHighlightingPreservingData();
    end
end

function removeHilite(model)
    modelH=get_param(model,'Handle');
    handles=get(modelH,'AutoVerifyData');
    SLStudio.Utils.RemoveHighlighting(modelH);
    if isfield(handles,'modelView')&&handles.modelView.isvalid
        handles.modelView.refresh;
    end
end

function[sldvData,resultPaths,opts,extractMdlH]=readDataFile(dataFile,modelH)
    s=load(dataFile);
    sldvData=s.sldvData;
    opts=sldvData.AnalysisInformation.Options;

    if nargout>1
        [~,resultPaths]=mdl_result_locations(modelH,opts,false,false,true);
    end

    if nargout>3
        extractMdlH=getExtractedMdl(sldvData,modelH);
    end
end

function out=is_model_open(mdlName)
    try
        mdlH=get_param(mdlName,'Handle');%#ok<NASGU>
        out=true;
    catch Mex %#ok<NASGU>
        out=false;
    end
end

function setDialogTextBrowserEnable(dlg,status)
    if~isempty(dlg)
        dlg.setEnabled('browserarea',status);
        dlg.setEnabled('logarea',status);
    end
end

function progressBar=createProgressBar(title)
    try
        progressBar=DAStudio.WaitBar;
        progressBar.setWindowTitle(title);
        progressBar.setLabelText(DAStudio.message('Simulink:tools:MAPleaseWait'));
        progressBar.setCircularProgressBar(true);
        progressBar.show();
    catch Mex %#ok<NASGU>
        progressBar=[];
    end
end

function updateResults(sldvData,fileNames,modelH)
    mdl_current_results(modelH,fileNames);
    refresh_mdlexplr_result(modelH);
    try
        [progressUI,modelView]=mdl_progress_ui_and_model_view(modelH);
        analStatus=sldvData.AnalysisInformation.Status;



        if~(strcmpi(analStatus,'In progress'))
            htmlSummry=Sldv.ReportUtils.getHTMLsummary(sldvData,...
            fileNames,...
            get_param(modelH,'Name'),...
            false);

            if~isempty(progressUI)
                progressUI.setLog(htmlSummry);
            end


            av_handle=get_param(modelH,'AutoVerifyData');
            if isfield(av_handle,'res_dialog')
                res_dialog=av_handle.res_dialog;

                res_dialog.refresh();
            end
        end
        if~isempty(modelView)
            modelView.update(fileNames);
        end
    catch Mex %#ok<NASGU>
    end
end

function[progressUI,modelView]=mdl_progress_ui_and_model_view(modelH)
    handles=get_param(modelH,'AutoVerifyData');
    if~isempty(handles)&&isfield(handles,'ui')&&ishandle(handles.ui)
        progressUI=handles.ui;
    else
        progressUI=[];
    end
    if~isempty(handles)&&isfield(handles,'modelView')&&handles.modelView.isvalid
        modelView=handles.modelView;
    else
        modelView=[];
    end
end

function refresh_mdlexplr_result(modelH)
    try
        modelObj=get_param(modelH,'Object');

        children=modelObj.getHierarchicalChildren;

        for child=children(:)'
            if isa(child,'Simulink.DVOutput')
                child.refresh;
                break;
            end
        end


        root=slroot;
        me=[];
        daRoot=DAStudio.Root;
        explorers=daRoot.find('-isa','DAStudio.Explorer');
        for i=1:length(explorers)
            if root==explorers(i).getRoot
                me=explorers(i);
                break;
            end
        end


        if~isempty(me)
            dlg=me.getDialog;
            dlgSrc=dlg.getSource;

            if isa(dlgSrc,'Simulink.DVOutput')&&dlgSrc.up==modelObj
                dlg.refresh();
            end
        end
    catch Mex %#ok<NASGU>
    end
end

function open_model(harnessModel)
    if~isempty(harnessModel)
        harnessModel=urldecode(harnessModel);
    end
    modelFullPath=harnessModel;
    [~,mdlName,~]=fileparts(modelFullPath);
    if is_model_open(mdlName)
        open_system(mdlName);
    else
        open_system(modelFullPath);
    end
end

function dlg=findResultDialog(model,method)

    dlg=[];
    if strcmp(method,'delete_export_progress_bar')
        return;
    end
    tag='SLDV_RESULT_DIALOG';
    for d=DAStudio.ToolRoot.getOpenDialogs()'
        if strcmp(d.dialogTag,tag)
            src=d.getSource;
            if strcmp(src.modelName,model)
                dlg=d;
                return;
            end
        end
    end
end




