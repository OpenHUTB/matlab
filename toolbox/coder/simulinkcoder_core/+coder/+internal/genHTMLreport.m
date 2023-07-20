function calledShowReport=genHTMLreport(varargin)





    try
        calledShowReport=cpp_feval_wrapper('loc_genHTMLreport',varargin{:});
    catch ME
        rethrow(ME);
    end

    function calledShowReport=loc_genHTMLreport(lBuildDirectory,lModelName,lCodeFormatForStateflow,...
        lModelReferenceTargetType,lLaunchCodeGenerationReport,...
        lUpdateTopModelReferenceTarget,lIsXil,updateReport,lCodeGenerationId)%#ok<DEFNU>



        calledShowReport=false;

        statusMsg=[];%#ok
        if slfeature('EnableCodeGenStatusBarUpdates')~=0
            bdHandle=get_param(lModelName,'Handle');
            statusMsg=rtw.util.resetStatusBar(bdHandle);%#ok
            updateMsg=message('RTW:uiupdate:CodeReport');
            set_param(bdHandle,'StatusString',getString(updateMsg));
        end
        savePWD=cd(lBuildDirectory);
        htmlDir=fullfile(lBuildDirectory,'html');
        rptFileName=fullfile(htmlDir,coder.internal.slcoderReport('getReportFileName',...
        lModelName,lCodeFormatForStateflow));
        tInfoFile=fullfile(htmlDir,'traceInfo.mat');
        if exist(tInfoFile,'file')==2
            delete(tInfoFile);
        end
        RTW.TraceInfo.instance(lModelName);
        protectingMdl=Simulink.ModelReference.ProtectedModel.protectingModel(lModelName);


        if(protectingMdl)
            reportInfo=Simulink.ModelReference.ProtectedModel.Report.instance(lModelName);
        else
            reportInfo=rtw.report.ReportInfo.instance(lModelName);
        end

        id='genHTMLreport';
        targetName=reportInfo.PerfTracerTargetName;
        PerfTools.Tracer.logSimulinkData('SLbuild',lModelName,targetName,...
        id,true);
        oc_perf=onCleanup(@()PerfTools.Tracer.logSimulinkData('SLbuild',lModelName,targetName,...
        id,false));

        delete(fullfile(htmlDir,'*.xml'));
        bRefreshCurrentReport=false;

        reportInfo.getSortedFileInfoList();
        if~isempty(reportInfo.getBrowserDocument)&&...
            strcmp(reportInfo.getBrowserDocument.documentName,...
            reportInfo.getReportFileFullName)
            bRefreshCurrentReport=true;
        end


        folders=Simulink.filegen.internal.FolderConfiguration(lModelName);
        htmlFolder=fullfile(folders.CodeGeneration.absolutePath('SharedUtilityCode'),'html');

        reportInfo.RelativePathToSharedUtilRptFromRpt=...
        coder.report.ReportInfoBase.getRelativePathToFile(...
        htmlFolder,...
        fullfile(reportInfo.getReportDir,filesep));



        setCodeGenerationId(reportInfo,lCodeGenerationId);

        if~bRefreshCurrentReport&&strcmp(get_param(lModelName,'GenerateReport'),'off')

            delete(fullfile(htmlDir,'*.html'));

            me=[];
            try
                infoStruct=coder.internal.infoMATFileMgr('load',...
                'binfo',lModelName,...
                lModelReferenceTargetType);
            catch me
                if~strcmp(me.identifier,'RTW:buildProcess:infoMATFileMgrMatFileNotFound')
                    rethrow(me);
                end
            end


            if isempty(me)

                if isfield(infoStruct,'htmlrptLinks')
                    [reportInfo.ModelReferences,reportInfo.TopProtectedModelReferences]=...
                    Simulink.ModelReference.ProtectedModel.filterAllProtectedSubmodels(...
                    infoStruct.modelRefsAll,...
                    infoStruct.protectedModelRefs);
                    reportInfo.ModelReferencesReports=getModelReferencesReports(infoStruct,reportInfo);
                    setModelreferencesBuildDir(reportInfo,infoStruct);
                end
            end

            if protectingMdl

                coder.internal.infoMATFileMgr(...
                'updatehtmlrptLinks','binfo',...
                lModelName,...
                lModelReferenceTargetType,...
                rptFileName);
            end

        else

            infoStruct=coder.internal.infoMATFileMgr('load',...
            'binfo',lModelName,...
            lModelReferenceTargetType);

            if isfield(infoStruct,'htmlrptLinks')
                [reportInfo.ModelReferences,reportInfo.TopProtectedModelReferences]=...
                Simulink.ModelReference.ProtectedModel.filterAllProtectedSubmodels(...
                infoStruct.modelRefsAll,...
                infoStruct.protectedModelRefs);
                reportInfo.ModelReferencesReports=getModelReferencesReports(infoStruct,reportInfo);
                setModelreferencesBuildDir(reportInfo,infoStruct);
            end

            coder.internal.infoMATFileMgr(...
            'updatehtmlrptLinks','binfo',...
            lModelName,...
            lModelReferenceTargetType,...
            rptFileName);
            bMdlRef=~strcmp(lModelReferenceTargetType,'NONE');

            if protectingMdl
                return;
            end


            if strcmp(get_param(lModelName,'RTWVerbose'),'on')
                msg='### Creating HTML report file %s\n';
                try
                    desktopInUse=desktop('-inuse');
                catch
                    desktopInUse=false;
                end
                if desktopInUse
                    fprintf(1,msg,reportInfo.getHyperlink);
                else
                    fprintf(1,msg,reportInfo.getReportFileName);
                end
            end
            if updateReport
                reportInfo.update;
            else
                reportInfo.emitHTML;
            end



            if(strcmp(get_param(lModelName,'LaunchReport'),'on')||bRefreshCurrentReport)&&...
                lLaunchCodeGenerationReport&&...
                (~bMdlRef||lUpdateTopModelReferenceTarget)&&...
                ~lIsXil




                if~rtw.report.ReportInfo.featureReportV2||...
                    strcmp(get_param(lModelName,'GenerateCodeMetricsReport'),'off')
                    reportInfo.show;
                    calledShowReport=true;
                end
            end
        end

        cd(savePWD);

        function out=getModelReferencesReports(infoStruct,reportInfo)

            htmlrptLinks=Simulink.ModelReference.ProtectedModel.filterReportLinksForModelsInAllMdlRefs(...
            infoStruct,...
            reportInfo.ModelReferences);

            relativePath=fullfile(infoStruct.relativePathToAnchor,'..');
            out=cellfun(@(x)strrep(fullfile(relativePath,x),'\','/'),htmlrptLinks,...
            'UniformOutput',false);

            function setModelreferencesBuildDir(reportInfo,infoStruct)
                if~isempty(reportInfo.ModelReferences)
                    tmp=RTW.getBuildDir(reportInfo.ModelName);
                    codeGenFolder=tmp.CodeGenFolder;
                    mdlrefsAll=infoStruct.modelRefsAll;
                    buildDirs=infoStruct.modelRefsBuildDirsAll;
                    reportInfo.ModelReferencesBuildDir=containers.Map;
                    for i=1:length(mdlrefsAll)
                        reportInfo.ModelReferencesBuildDir(mdlrefsAll{i})=...
                        struct('CodeGenFolder',codeGenFolder,...
                        'ModelRefRelativeBuildDir',buildDirs{i});
                    end
                end

