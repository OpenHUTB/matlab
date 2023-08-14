

classdef RecommendAdaptivePipeline<hdlcoder.report.ReportPage
    methods
        function obj=RecommendAdaptivePipeline(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:AdaptivePipeliningTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateAdaptivePipeliningReport(filename,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdAdaptivePipelining';
        end

        function out=getDefaultReportFileName(~)
            out='adaptive_pipelining.html';
        end
    end
end
