classdef DependencyAnalyzerReportPart<mlreportgen.dom.LockedDocumentPart




    methods
        function this=DependencyAnalyzerReportPart(format)
            this=this@mlreportgen.dom.LockedDocumentPart(format);
            open(this,dependencies.internal.report.getPartKey);
        end
    end
end
