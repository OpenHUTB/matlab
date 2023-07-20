function result=refreshHTMLreport(lBuildDirectory,lModelName,lCodeFormatForStateflow,...
    lModelReferenceTargetType,lLaunchCodeGenerationReport,...
    lUpdateTopModelReferenceTarget,lIsXil,reportInfo,lCodeGenerationId)





    result=[];
    htmlDir=fullfile(lBuildDirectory,'html');


    if strcmp(get_param(lModelName,'GenerateReport'),'off')
        if exist(htmlDir,'dir')
            try
                rmdir(htmlDir,'s');
            catch
            end
        end
        set_param(lModelName,'CoderReportInfo',[]);
        ssH=rtwprivate('getSourceSubsystemHandle',lModelName);
        if~isempty(ssH)
            set_param(bdroot(ssH),'CoderReportInfo',[]);
        end

        result.CMRefreshRequired=true;
        return
    end


    savePWD=cd(lBuildDirectory);

    if~isa(reportInfo,'rtw.report.ReportInfo')
        try
            reportInfo=rtw.report.ReportInfo.loadMat(lModelName,lBuildDirectory);
            rtw.report.ReportInfo.setInstance(lModelName,reportInfo);
        catch me
            if~any(strcmp(me.identifier,{'RTW:report:ReportInfoNotFound',...
                'RTW:report:invalidBuildFolder'}))
                cd(savePWD);
                rethrow(me);
            end
        end
    else
        reportInfo.initStartDirBasedOnBuildDir;
    end


    if isa(reportInfo,'rtw.report.ReportInfo')
        id='refreshHTMLreport';
        PerfTools.Tracer.logSimulinkData('SLbuild',lModelName,reportInfo.PerfTracerTargetName,...
        id,true);
        oc_perf=onCleanup(@()PerfTools.Tracer.logSimulinkData('SLbuild',lModelName,reportInfo.PerfTracerTargetName,...
        id,false));

        delete(fullfile(htmlDir,'*_cov.xml'));
        sharedUtilHtmlDir=fullfile...
        (htmlDir,reportInfo.RelativePathToSharedUtilRptFromRpt);
        delete(fullfile(sharedUtilHtmlDir,'*_cov.xml'));

        jsFile=fullfile(htmlDir,'rtwannotate.js');
        if exist(jsFile,'file')
            delete(jsFile)
        end
        jsFileSharedUtil=fullfile(sharedUtilHtmlDir,'rtwannotate.js');
        if exist(jsFileSharedUtil,'file')
            delete(jsFileSharedUtil)
        end



        removeInTheLoopFiles=false;
        if~lIsXil
            inTheLoopTag='In-the-Loop';
            if~isempty(reportInfo.getTaggedFiles(inTheLoopTag))
                removeInTheLoopFiles=true;
            end
        end

        showHTMLReport=false;
        generateHTMLReport=false;
        if(~isempty(reportInfo.Config)&&~isequal(reportInfo.Config,...
            rtw.report.Config(lModelName)))||...
            ~reportInfo.isFileUptodate('legacy')||...
            ~reportInfo.isFileUptodate('interface')


            generateHTMLReport=true;
        end




        bMdlRef=~strcmp(lModelReferenceTargetType,'NONE');
        if strcmp(get_param(lModelName,'LaunchReport'),'on')&&...
            (~bMdlRef||lUpdateTopModelReferenceTarget)&&...
            ~lIsXil
            showHTMLReport=true;
        end

        if removeInTheLoopFiles


            reportInfo.removeTaggedFiles(inTheLoopTag);



            if~generateHTMLReport
                reportInfo.emitContents;
            end
        end

        if generateHTMLReport

            updateReport=true;
            coder.internal.genHTMLreport(lBuildDirectory,lModelName,lCodeFormatForStateflow,...
            lModelReferenceTargetType,lLaunchCodeGenerationReport,...
            lUpdateTopModelReferenceTarget,lIsXil,updateReport,...
            lCodeGenerationId);
        end


        if generateHTMLReport||removeInTheLoopFiles
            reportInfo.saveMat;
            if coder.internal.slcoderReport('generateCodeMetricsReportOn',lModelName)
                if slfeature('DecoupleCodeMetrics')
                    CMSaveLocation=fullfile(reportInfo.CodeGenFolder,reportInfo.ModelRefRelativeBuildDir,'tmwinternal');
                else
                    CMSaveLocation=fullfile(lBuildDirectory,'html');
                end
                rtw.report.CodeMetrics.generateStaticCodeMetrics(reportInfo,reportInfo.getBuildInfo(),...
                CMSaveLocation,...
                rtwprivate('getSourceSubsystemName',lModelName));

                result.CMRefreshRequired=false;
            end
        end

        if(removeInTheLoopFiles||showHTMLReport)
            reportInfo.show;
        end

    end
    cd(savePWD);


