

classdef StaticLatencyPathAnalysis<hdlcoder.report.ReportPage
    methods
        function obj=StaticLatencyPathAnalysis(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:StaticLatencyPathReportTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            hDriver=hdlcurrentdriver;
            cpeReportFile=fullfile(hDriver.hdlGetCodegendir(),'staticlatencypathanalysissummary.html');
            try
                copyfile(cpeReportFile,filename,'f');
            catch
            end
        end

        function out=getId(~)
            out='rtwIdStaticLatency';
        end

        function out=getDefaultReportFileName(~)
            out='staticlatencypathanalysissummary.html';
        end
    end
end
