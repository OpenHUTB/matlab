classdef DependencyAnalyzerReport<mlreportgen.dom.LockedDocument




    methods
        function this=DependencyAnalyzerReport(name,format)
            this=this@mlreportgen.dom.LockedDocument(name,format);
            open(this,dependencies.internal.report.getReportKey);
        end
    end
end
