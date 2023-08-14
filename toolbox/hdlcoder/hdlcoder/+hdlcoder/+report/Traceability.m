

classdef Traceability<hdlcoder.report.ReportPage
    methods
        function obj=Traceability(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:TraceabilityTitle',obj.ModelName);
        end

        function generate(~)

        end

        function out=getId(~)
            out='rtwIdTraceability';
        end

        function out=getDefaultReportFileName(~)
            out='trace.html';
        end
    end
end
