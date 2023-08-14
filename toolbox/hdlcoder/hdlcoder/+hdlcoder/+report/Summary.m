

classdef Summary<hdlcoder.report.ReportPage
    methods
        function obj=Summary(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:PageTitle',obj.ModelName);
        end
        function generate(obj)
            survey_file=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateSummary(survey_file,...
            obj.getTitle,...
            obj.ModelName,...
            obj.JavaScriptBody,...
            obj.getLinkManager().hasWebview);
        end

        function out=getId(~)
            out='rtwIdSummaryPage';
        end
        function out=getDefaultReportFileName(~)
            out='survey.html';
        end
    end
end
