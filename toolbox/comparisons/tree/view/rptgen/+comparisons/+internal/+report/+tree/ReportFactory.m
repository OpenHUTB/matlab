classdef ReportFactory<handle


    properties(Access=private)
        Constructor=@comparisons.internal.report.tree.ComparisonReport
ReportFormat
    end

    methods(Access=public)

        function reportCreator=ReportFactory(reportFormat,constructor)
            reportCreator.ReportFormat=reportFormat;
            if nargin>1
                reportCreator.Constructor=constructor;
            end
        end

        function reportLocation=createReport(reportFactory,mcosView,sources,reportFolder,reportName)
            reportFormat=reportFactory.ReportFormat;
            reportLocation=[fullfile(reportFolder,reportName),'.',reportFormat.getFileExtension];

            report=reportFactory.Constructor(mcosView,sources,reportLocation,reportFormat);
            report.fill();
        end

    end

end