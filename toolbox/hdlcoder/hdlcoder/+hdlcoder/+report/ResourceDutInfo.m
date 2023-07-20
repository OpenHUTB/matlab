

classdef ResourceDutInfo<hdlcoder.report.ReportPage
    methods
        function obj=ResourceDutInfo(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:RsrDutInfoTitle',obj.ModelName);
        end

        function generate(obj)
            bom_file=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateDutInfoReport(bom_file,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.TcgInventory,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdDutInformation';
        end

        function out=getDefaultReportFileName(~)
            out='dut_information.html';
        end
    end
end
