classdef(Hidden)ComparisonPublisher<handle






    properties(Access=private)
        JavaDriver;
    end

    methods(Access=public)

        function obj=ComparisonPublisher(javaDriver)
            obj.JavaDriver=javaDriver;
        end

        function report=publish(this,options)
            format=this.getReportFormat(options);
            location=this.getReportLocation(options);
            report=this.createComparisonReport(location,format);
        end

    end

    methods(Access=private)

        function format=getReportFormat(~,options)
            import slxmlcomp.internal.report.ReportFormat;
            format=ReportFormat.fromString(options.Format);
        end

        function location=getReportLocation(~,options)
            location=fullfile(options.OutputFolder,options.Name);
        end

        function report=createComparisonReport(...
            this,...
            reportLocation,...
format...
            )
            import slxmlcomp.internal.report.createReport;
            createReport(this.getReportDriverFacade,reportLocation,format)
            report=reportLocation;
        end

        function facade=getReportDriverFacade(this)
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.matlab.SLXMATLABPrintableReportDriverFacade;
            facade=SLXMATLABPrintableReportDriverFacade(...
            this.JavaDriver...
            );
        end

    end

end
