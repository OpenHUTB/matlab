

classdef Clock<hdlcoder.report.ReportPage
    methods
        function obj=Clock(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:PageTitle',obj.ModelName);
        end

        function generate(obj)
            survey_file=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateClockSummary(survey_file,...
            obj.getTitle,...
            obj.ModelName,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdClockPage';
        end

        function out=getDefaultReportFileName(~)
            out='clock.html';
        end
    end
end
