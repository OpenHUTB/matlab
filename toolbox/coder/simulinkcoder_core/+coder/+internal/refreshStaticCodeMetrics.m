function refreshStaticCodeMetrics(reportInfo,lModelName,...
    lBuildDirectory,...
    ~,...
    lCodeGenerationId,mainCompileFolder,genCMOverride,varargin)




    if nargin<7
        genCMOverride=false;
    end

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
            return;
        end
    end

    if slfeature('DecoupleCodeMetrics')
        CMSaveLocation=fullfile(reportInfo.CodeGenFolder,reportInfo.ModelRefRelativeBuildDir,'tmwinternal');
    else
        CMSaveLocation=fullfile(mainCompileFolder,'html');
    end

    if~coder.internal.slcoderReport('generateCodeMetricsReportOn',lModelName)
        cmFile=fullfile(CMSaveLocation,'codeMetrics.mat');
        if isfile(cmFile)
            delete(cmFile);
        end
        return;
    end

    isNewCode=~isequal(reportInfo.CodeGenerationIdStaticMetrics,lCodeGenerationId);

    if isNewCode||genCMOverride
        perf_id='genStaticCodeMetricsReport';
        PerfTools.Tracer.logSimulinkData('SLbuild',lModelName,...
        reportInfo.PerfTracerTargetName,...
        perf_id,true);
        rtw.report.CodeMetrics.generateStaticCodeMetrics(...
        rtw.report.getReportInfo(lModelName),...
        reportInfo.getBuildInfo,...
        CMSaveLocation,...
        rtwprivate('getSourceSubsystemName',lModelName));
        PerfTools.Tracer.logSimulinkData('SLbuild',lModelName,...
        reportInfo.PerfTracerTargetName,...
        perf_id,false);



        setCodeGenerationIdStaticMetrics(reportInfo,lCodeGenerationId);



        if rtw.report.ReportInfo.featureReportV2



            dataPath=fullfile(reportInfo.getReportDir,'data');
            if~isfolder(dataPath)
                return;
            end

            cr=simulinkcoder.internal.Report.getInstance;
            isRefBuild=isCurrModelRefBuild(reportInfo);
            reportV2Gen=true;
            codeData=cr.getCodeData(lModelName,isRefBuild,'',reportV2Gen);


            fid=fopen(fullfile(dataPath,'data.js'),'w');
            fprintf(fid,'var dataJson = %s;',jsonencode(codeData));
            fclose(fid);



            if~isempty(varargin)
                isXil=varargin{1};
            else
                isXil=false;
            end

            if isa(reportInfo,'rtw.report.ReportInfo')&&~isXil
                reportInfo.show;
            end
        end
    end
end

function res=isCurrModelRefBuild(reportInfo)


    res=false;

    model=reportInfo.ModelName;
    try
        dirs=RTW.getBuildDir(model);
    catch

        return;
    end
    relRefBuildFolder=dirs.ModelRefRelativeBuildDir;
    if~isempty(relRefBuildFolder)&&contains(reportInfo.getReportDir,relRefBuildFolder)


        res=true;
    end
end
