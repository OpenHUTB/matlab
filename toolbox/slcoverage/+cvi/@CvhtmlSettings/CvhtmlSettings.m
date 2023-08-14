



classdef CvhtmlSettings<handle
    properties
        varName='covdata';
        enableCumulative=0;
        saveCumulativeToWorkspaceVar=0;
        saveSingleToWorkspaceVar=1;
        cumulativeVarName='';
        covCumulativeReport=0;
        incVarName=0;
        incFileName=0
        makeReport=1;
        covReportOnPause=0;
        covCompData=[];
        covMetricSettings='';
        modelDisplay=0;
        covSaveOutputData=0;
        covOutputDir='';
        covDataFileName='';
        covShowResultsExplorer=0;


        showReport=true;
        generateWebViewReport=false;
        allTestInMdlSumm=1;
        aggregatedTests=1;
        barGrInMdlSumm=1;
        twoColorBarGraphs=1;
        hitCntInMdlSumm=0;
        elimFullCov=0;
        elimFullCovDetails=1;
        complexInSumm=1;
        complexInBlkTable=1;
        filtSFEvent=0;
        filtExecMetric=0;
        showReqTable=1;



        reportSignalRange=true
        ownerCovOutputDir=''
        isLinked=true;
        summaryMode=0;

        summaryHtml='';
        filterDialogTag='';
        alternativeMetricNameIdx=1;
        generatWebViewReportData=0;
        whiteColor='$#FFFFFF';
        redColor='$#FFD0D0';
        ltBlueColor='$#00FFFF';
        varSizeColor='$#F0F0F0';
        barGraphBorder=1;
        imageSubDirectory='scv_images';
        cumulativeReport=false;
        reportSubTitle='';
        performTiming=0;
        mathWorksTesting=0;
        topModelName='';
        ownerModel='';
        explorerGeneratedReport=false
        explorerGeneratedHighlight=false
        contextInfo=[]
        isDockedReport=false
    end
    methods
        function this=CvhtmlSettings(varargin)
            if nargin>=1
                try


                    this.topModelName=get_param(varargin{1},'Name');
                catch
                end
            end
            if nargin>=2
                this.ownerModel=varargin{2};
            end

            if~isempty(this.topModelName)
                this.getModelParams(this.topModelName);
            else
                this.getDefaultModelParams;
            end
            this.getInternal;
        end
        function setHtmlOptions(this,htmlOptions)
            cvi.ReportUtils.parseOptionString(this,htmlOptions);
        end

        function applyToModel(this,modelH)
            htmlOptions=cvi.ReportUtils.getOptionsTable;
            htmlOptionsStr='';
            [m,~]=size(htmlOptions);
            for idx=1:m
                if this.(htmlOptions{idx,2})
                    v='1';
                else
                    v='0';
                end
                sStr=['-',htmlOptions{idx,3},'=',v];
                if isempty(htmlOptionsStr)
                    htmlOptionsStr=sStr;
                else
                    htmlOptionsStr=[htmlOptionsStr,' ',sStr];%#ok<AGROW>
                end
            end

            set_param(modelH,'CovHTMLOptions',htmlOptionsStr);
            set_param(modelH,'CovEnableCumulative',cvi.CvhtmlSettings.boolToOnOff(this.enableCumulative));
            set_param(modelH,'CovCumulativeReport',cvi.CvhtmlSettings.boolToOnOff(this.covCumulativeReport));
        end


        function setRequirementsMapping(this,reqInfo)
            this.contextInfo.Requirements=reqInfo;
        end

        function setFilterCtxId(this,ctxId,reportViewCmd)
            if nargin<3
                reportViewCmd='cvhtml';
            end
            if~ischar(ctxId)
                ctxId=num2str(ctxId);
            end
            this.contextInfo.filterCtxId=ctxId;
            this.contextInfo.filterReportViewCmd=reportViewCmd;
        end

        function[ctxId,reportViewCmd]=getFilterCtxId(this)
            ctxId='';
            reportViewCmd='';
            if~isempty(this.contextInfo)&&isfield(this.contextInfo,'filterCtxId')
                ctxId=this.contextInfo.filterCtxId;
                reportViewCmd=this.contextInfo.filterReportViewCmd;
            end
        end

    end
    methods(Static=true)
        function dirName=getOutputDir(modelH)
            covOutputDir=get_param(modelH,'CovOutputDir');
            modelName=get_param(modelH,'Name');
            dirName=cvi.CvhtmlSettings.getProcessedDirName(covOutputDir,modelName);
        end

        function dirName=getProcessedDirName(dirName,modelName)
            dirName=strrep(dirName,'$ModelName$',modelName);
            dirName=strrep(dirName,'\',filesep);
            dirName=strrep(dirName,'/',filesep);
        end

        function res=copy(cvhtmlsetting)
            if isa(cvhtmlsetting,'cvi.CvhtmlSettings')
                flds=fields(cvhtmlsetting);
                res=cvi.CvhtmlSettings;
                for idx=1:numel(flds)
                    res.(flds{idx})=cvhtmlsetting.(flds{idx});
                end
            end
        end

        function OnOff=boolToOnOff(b)
            if b
                OnOff='on';
            else
                OnOff='off';
            end
        end

    end
    methods(Access=private)
        function getModelParams(this,modelH)

            this.varName=get_param(modelH,'CovSaveName');
            this.enableCumulative=strcmpi(get_param(modelH,'CovEnableCumulative'),'on');
            this.saveCumulativeToWorkspaceVar=strcmpi(get_param(modelH,'CovSaveCumulativeToWorkspaceVar'),'on');
            this.saveSingleToWorkspaceVar=strcmpi(get_param(modelH,'CovSaveSingleToWorkspaceVar'),'on');
            this.cumulativeVarName=get_param(modelH,'CovCumulativeVarName');
            this.covCumulativeReport=strcmpi(get_param(modelH,'CovCumulativeReport'),'on');
            this.covShowResultsExplorer=strcmpi(get_param(modelH,'CovShowResultsExplorer'),'on');

            this.covSaveOutputData=strcmpi(get_param(modelH,'CovSaveOutputData'),'on');
            this.covDataFileName=get_param(modelH,'CovDataFileName');
            this.incVarName=strcmpi(get_param(modelH,'CovNameIncrementing'),'on');
            this.incFileName=strcmpi(get_param(modelH,'CovFileNameIncrementing'),'on');
            this.makeReport=strcmpi(get_param(modelH,'CovHtmlReporting'),'on');
            this.covReportOnPause=strcmpi(get_param(modelH,'CovReportOnPause'),'on');
            this.covCompData=get_param(modelH,'CovCompData');
            this.covMetricSettings=get_param(modelH,'CovMetricSettings');
            this.modelDisplay=~any(this.covMetricSettings=='e');
            setHtmlOptions(this,get_param(modelH,'CovHTMLOptions'));
            this.covOutputDir=cvi.CvhtmlSettings.getOutputDir(modelH);
            modelName=get_param(modelH,'Name');
            if~isempty(this.ownerModel)
                ownerModelH=get_param(this.ownerModel,'handle');
                this.ownerCovOutputDir=cvi.CvhtmlSettings.getOutputDir(ownerModelH);
            end

            this.covDataFileName=strrep(this.covDataFileName,'$ModelName$',modelName);


        end
        function getDefaultModelParams(this)

            this.varName='covdata';
            this.enableCumulative=1;
            this.saveCumulativeToWorkspaceVar=0;
            this.saveSingleToWorkspaceVar=1;
            this.cumulativeVarName='';
            this.covCumulativeReport=0;
            this.incVarName=0;
            this.incFileName=1;
            this.makeReport=1;
            this.covReportOnPause=0;
            this.covCompData=[];
            this.covMetricSettings='';
            this.modelDisplay=~any(this.covMetricSettings=='e');
            setHtmlOptions(this,'');
        end
        function getInternal(this)

            this.barGraphBorder=1;
            this.imageSubDirectory='scv_images';
            this.cumulativeReport=false;
            this.reportSubTitle='';




            try
                this.performTiming=evalin('base','do_cvhtml_timing_analysis');
            catch Mex %#ok<NASGU>
                this.performTiming=0;
            end





            try
                this.mathWorksTesting=evalin('base','BnT_simcoverage_testing');
            catch Mex %#ok<NASGU>
                this.mathWorksTesting=0;
            end
        end
    end

end
