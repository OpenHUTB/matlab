classdef DetailedReportManager<handle



    properties(Access=public)
        folderName='CoverageDetails';
        reportNamePattern='docked__cov__report__$MODEL$__$COVMODE$.html';
        topModel;
        reportSettings;
        generatedReports;
        reportFolder;
        covModes={};
    end

    properties(GetAccess=public,SetAccess=private)
        hasMultipleCovModes=false;
    end


    methods(Access=public)

        function this=DetailedReportManager(topModel,contextInfo)
            this.topModel=topModel;
            this.reportSettings=this.getReportSettings(contextInfo);
            this.reportFolder=this.getReportFolder();
            this.generatedReports=struct(...
            'analyzedModel',{},...
            'SummaryReport',false,...
            'harnessModel',{},...
            'ownerModel',{},...
            'reportName',{},...
            'reportPath',{},...
            'reportPathEncoded',{},...
            'covMode',{},...
            'modelName',{},...
            'ctxInfo',{});
        end

        function delete(~)



        end

        function createReport(this,cvdg)
            if isa(cvdg,'cv.cvdatagroup')


                modelCovId=get_param(get_param(this.topModel,'Handle'),'CoverageId');
                if modelCovId==0
                    return
                end
                simMode=SlCov.CovMode(cv('get',modelCovId,'.simMode'));
                reportName=this.getReportName(this.topModel,SlCov.CovMode.toString(simMode));
                reportFullPath=fullfile(this.reportFolder,reportName);
                reportFullPath_encoded=fullfile(this.reportFolder,urlencode(reportName));
                cvhtml(reportFullPath,cvdg,this.reportSettings);
                report=struct('analyzedModel',this.topModel,...
                'SummaryReport',true,...
                'harnessModel','',...
                'ownerModel','',...
                'reportName',reportName,...
                'reportPath',reportFullPath,...
                'reportPathEncoded',reportFullPath_encoded,...
                'covMode',SlCov.CovMode.toString(simMode),...
                'modelName','',...
                'ctxInfo',[]);

                this.generatedReports(end+1)=report;



                cvdataInGrp=cvdg.getAll;
                for idx=1:numel(cvdataInGrp)
                    allCovData=cvdataInGrp{idx};


                    for index=1:numel(allCovData)
                        cvd=allCovData(index);
                        modelCovId=cvi.ReportUtils.getModelCovId(cvd);
                        if~isempty(cvd)&&~isempty(modelCovId)
                            covMode=SlCov.CovMode.toString(cvd.simMode);
                            this.logCovMode(covMode);
                            if strcmp(covMode,'Normal')
                                this.reportNamePattern='$MODEL$_cov.html';
                            elseif strcmp(covMode,'SIL')
                                this.reportNamePattern='$MODEL$_(sil)_cov.html';
                            elseif strcmp(covMode,'ModelRefSIL')
                                this.reportNamePattern='$MODEL$_(modelrefsil)_cov.html';
                            end

                            analyzedModel=cvd.modelinfo.analyzedModel;


                            if~strcmp(cvd.modelinfo.ownerModel,cvd.modelinfo.ownerBlock)&&...
                                strcmp(get_param(cvd.modelinfo.analyzedModel,'Type'),'block')
                                analyzedModel=cvd.modelinfo.harnessModel;
                            end
                            reportName=this.getReportName(analyzedModel,covMode);
                            this.reportGenerator(cvd,reportName,analyzedModel,false);
                        end
                    end
                end
            else
                allCovData=cvdg;


                for index=1:numel(allCovData)
                    cvd=allCovData(index);
                    covMode=SlCov.CovMode.toString(cvd.simMode);
                    this.logCovMode(covMode);
                    this.reportNamePattern='docked__cov__report__$MODEL$__$COVMODE$.html';
                    analyzedModel=cvd.modelinfo.analyzedModel;





                    if~strcmp(this.topModel,analyzedModel)&&...
                        strcmp(cvd.modelinfo.ownerModel,cvd.modelinfo.ownerBlock)
                        cvdg=cv.cvdatagroup(allCovData);
                        this.createReport(cvdg);
                    else
                        reportName=this.getReportName(analyzedModel,covMode);
                        reportFullPath=fullfile(this.reportFolder,reportName);
                        cvhtml(reportFullPath,cvd,this.reportSettings,cvd.simMode);
                        this.reportGenerator(cvd,reportName,analyzedModel,true);
                    end
                end
            end
        end

        function reportGenerator(this,cvd,reportName,analyzedModel,flag)
            reportFullPath=fullfile(this.reportFolder,reportName);
            reportFullPath_encoded=fullfile(this.reportFolder,urlencode(reportName));
            ctxInfo=this.reportSettings.contextInfo;
            modelName='';
            if~isempty(ctxInfo)
                ctxInfo.cvdId=cvd.id;
                modelName=get_param(bdroot(cv('get',cv('get',cvd.rootId,'.topSlsf'),'.handle')),'name');
            end
            report=struct('analyzedModel',analyzedModel,...
            'SummaryReport',false,...
            'harnessModel','',...
            'ownerModel','',...
            'reportName',reportName,...
            'reportPath',reportFullPath,...
            'reportPathEncoded',reportFullPath_encoded,...
            'covMode',SlCov.CovMode.toString(cvd.simMode),...
            'modelName',modelName,...
            'ctxInfo',ctxInfo);




            if flag
                report.harnessModel=cvd.modelinfo.harnessModel;
                report.ownerModel=cvd.modelinfo.ownerModel;
            end

            this.generatedReports(end+1)=report;
        end

        function report=getReport(this,modelH,selectionH,covMode)
            modelName=get_param(modelH,'name');
            covPath=get_param(modelName,'CovPath');
            fullCovPath=cvi.TopModelCov.checkCovPath(modelName,covPath);
            idx=(strcmpi({this.generatedReports.analyzedModel},fullCovPath)|...
            strcmpi({this.generatedReports.harnessModel},fullCovPath)|...
            strcmpi({this.generatedReports.ownerModel},fullCovPath))...
            &strcmp({this.generatedReports.covMode},covMode);
            report=this.generatedReports(idx);




            if numel(report)>1
                if modelH~=selectionH
                    idx=~cellfun(@(x)all(x),{report.SummaryReport});
                else
                    idx=cellfun(@(x)all(x),{report.SummaryReport});
                end
                report=report(idx);
            end
        end

        function modes=getCovModes(this)
            modes=this.covModes;
        end
    end


    methods(Access=private)

        function logCovMode(this,covMode)
            if~ismember(covMode,this.covModes)
                this.covModes{end+1}=covMode;
            end
            this.hasMultipleCovModes=(numel(this.covModes)>1);
        end

        function name=getReportName(this,modelName,covMode)
            modelName=urlencode(modelName);
            name=this.reportNamePattern;
            name=strrep(name,'$MODEL$',modelName);
            name=strrep(name,'$COVMODE$',covMode);
        end

        function reportFolder=getReportFolder(this)
            covBaseDir=this.reportSettings.covOutputDir;
            covBaseDir=cvi.TopModelCov.checkOutputDir(covBaseDir,0);
            if isempty(covBaseDir)
                covBaseDir=tempdir;
            end
            reportFolder=fullfile(covBaseDir,this.folderName);

            if~exist(reportFolder,'dir')
                mkdir(reportFolder);
            end
        end

        function cvhtmlS=getReportSettings(this,contextInfo)
            cvhtmlS=cvi.CvhtmlSettings(this.topModel);
            cvhtmlS.showReport=false;
            cvhtmlS.elimFullCovDetails=false;
            cvhtmlS.generateWebViewReport=false;
            cvhtmlS.reportSignalRange=false;
            cvhtmlS.contextInfo=contextInfo;
            cvhtmlS.isDockedReport=true;
        end
    end
end





