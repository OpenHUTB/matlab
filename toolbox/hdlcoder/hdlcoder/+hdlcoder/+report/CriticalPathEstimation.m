

classdef CriticalPathEstimation<hdlcoder.report.ReportPage
    methods
        function obj=CriticalPathEstimation(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:CriticalPathEstimationTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            hDriver=hdlcurrentdriver;
            cpeReportFile=fullfile(hDriver.hdlGetBaseCodegendir(),'criticalpathestimationsummary.html');
            try
                copyfile(cpeReportFile,filename,'f');
            catch
            end
        end

        function out=getId(~)
            out='rtwIdCPE';
        end

        function out=getDefaultReportFileName(~)
            out='criticalpathestimationsummary.html';
        end
    end
end
