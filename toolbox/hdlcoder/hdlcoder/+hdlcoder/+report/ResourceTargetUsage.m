

classdef ResourceTargetUsage<hdlcoder.report.ReportPage
    methods
        function obj=ResourceTargetUsage(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:TargetRsrTitle',obj.ModelName);
        end

        function generate(obj)
            res_usage_file=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateTargetResourceUsageReport(res_usage_file,...
            obj.getTitle,...
            obj.ModelName,...
            obj.TcgInventory,...
            obj.JavaScriptBody);
        end
        function out=getId(~)
            out='rtwIdTargetResourceUsage';
        end
        function out=getDefaultReportFileName(~)
            out='target_resource_usage.html';
        end
    end
end
