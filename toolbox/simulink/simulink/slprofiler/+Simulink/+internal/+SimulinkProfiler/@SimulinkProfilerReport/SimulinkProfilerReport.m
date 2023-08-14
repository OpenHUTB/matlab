classdef SimulinkProfilerReport<mlreportgen.report.Report

    properties
    end

    methods
        function obj=SimulinkProfilerReport(varargin)
            obj=obj@mlreportgen.report.Report(varargin{:});
        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(rpt)
            path=Simulink.internal.SimulinkProfiler.SimulinkProfilerReport.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end

    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function createTemplate(templatePath,type)
            path=SimulinkProfilerReport.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReporter(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"SimulinkProfilerReport");
        end

    end
end