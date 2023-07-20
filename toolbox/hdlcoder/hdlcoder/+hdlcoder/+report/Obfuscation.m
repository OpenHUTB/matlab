classdef Obfuscation<hdlcoder.report.ReportPage
    methods
        function obj=Obfuscation(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:ObfuscationTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateObfuscationReport(filename,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdObfuscation';
        end

        function out=getDefaultReportFileName(~)
            out='obfuscation_report.html';
        end
    end
end
