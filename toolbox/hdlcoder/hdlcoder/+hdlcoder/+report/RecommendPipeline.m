

classdef RecommendPipeline<hdlcoder.report.ReportPage
    methods
        function obj=RecommendPipeline(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:DistPipelineTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateRecommendationsPipelining(filename,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdDistPipe';
        end

        function out=getDefaultReportFileName(~)
            out='distributed_pipelining.html';
        end
    end
end
