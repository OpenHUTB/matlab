

classdef RecommendTargetCodeGeneration<hdlcoder.report.ReportPage
    methods
        function obj=RecommendTargetCodeGeneration(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:RecommendTargetTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateTargetCodeGenerationReport(filename,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdTargetCodeGeneration';
        end

        function out=getDefaultReportFileName(~)
            out='targetcodegeneration.html';
        end
    end
end


