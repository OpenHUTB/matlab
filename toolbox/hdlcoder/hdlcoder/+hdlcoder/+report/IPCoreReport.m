

classdef IPCoreReport<hdlcoder.report.ReportPage
    methods
        function obj=IPCoreReport(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function generate(obj)%#ok<MANU>

        end
        function out=getId(~)
            out='rtwIdIPCoreReport';
        end
        function out=getDefaultReportFileName(~)
            out='ip_core_report.html';
        end
    end
end
