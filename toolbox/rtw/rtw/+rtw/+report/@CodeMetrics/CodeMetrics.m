classdef CodeMetrics<coder.report.CodeMetricsBase







    properties
ModelName
        SourceSubsystem=''
    end

    methods
        function obj=CodeMetrics(modelName,buildDir,varargin)
            obj.ModelName=modelName;
            obj.BuildDir=buildDir;
            if(length(varargin)>1)
                obj.SourceSubsystem=varargin{1};
            end
            if(length(varargin)>2)
                obj.InReportInfo=varargin{2};
            end
        end
        function execute(obj)
            if~isa(obj.Data,'rtw.codemetrics.CodeMetrics')
                option=struct('targetisCPP',obj.targetisCPP);
                obj.Data=coder.CodeMetrics(obj.BuildDir,[],option);
            end
            execute@coder.report.CodeMetricsBase(obj);
        end
    end

    methods(Hidden=true)
        initMessages(obj)
        introduction=getHTMLIntroduction(obj)
        function isForNewReport=isSLReportV2(obj)
            isForNewReport=rtw.report.ReportInfo.featureReportV2&&...
            contains(obj.ReportFolder,['html',filesep,'pages']);
        end
    end

    methods
    end

    methods(Static=true)
        out=getDisableMessage(~)
        createCodeMetricsData(reportInfo)
        insertReport(reportInfo,codeMetricsRpt,isSameReportAsDisplay)
        generateStaticCodeMetrics(reportInfo,buildInfo,saveLocation,sourceSubsystem,needCMReportGen,modelName)
    end
end




