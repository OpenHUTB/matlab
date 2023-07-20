classdef AbstractReportBuilder<handle




    properties(Access=protected)
Report
    end

    methods
        function createReport(obj)
            obj.Report=DataTypeWorkflow.Advisor.internal.utils.AnalyzerReport;
        end

        function report=getReport(obj)
            report=obj.Report;
        end
    end

    methods(Abstract)
        buildCheckListStep(obj,ru);
        buildSummaryStep(obj,ru);
        buildDetailedStep(obj,ru);
    end
end

