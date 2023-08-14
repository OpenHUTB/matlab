

classdef RecommendDelayBalance<hdlcoder.report.ReportPage
    methods
        function obj=RecommendDelayBalance(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:DelayBalancingTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateRecommendationsDelayBalancing(filename,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdDelayBalancing';
        end

        function out=getDefaultReportFileName(~)
            out='delay_balancing.html';
        end
    end
end
