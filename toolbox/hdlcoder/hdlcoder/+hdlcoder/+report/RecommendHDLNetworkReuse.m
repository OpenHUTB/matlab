classdef RecommendHDLNetworkReuse<hdlcoder.report.ReportPage
    methods
        function obj=RecommendHDLNetworkReuse(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:HDLNetworkReuseTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateHDLNetworkReuseReport(filename,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdHDLNetworkReuse';
        end

        function out=getDefaultReportFileName(~)
            out='hdl_network_reuse.html';
        end
    end
end
