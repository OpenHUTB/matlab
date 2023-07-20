classdef RecommendFlatteningHierarchy<hdlcoder.report.ReportPage
    methods
        function obj=RecommendFlatteningHierarchy(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:FlattenHierarchyTitle',obj.ModelName);
        end

        function generate(obj)
            filename=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateFlatteningHierarchyReport(filename,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.JavaScriptBody);
        end

        function out=getId(~)
            out='rtwIdFlattenHierarchy';
        end

        function out=getDefaultReportFileName(~)
            out='flatten_hierarchy.html';
        end
    end
end
