
classdef DashboardReportInternal<mlreportgen.report.Report

    properties(SetAccess=private)
Project
DashboardLayout
ReportLocale
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(rpt)
            path=dashboard.internal.report.DashboardReportInternal.getClassFolder();
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
            path=dashboard.internal.report.DashboardReportInternal.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReport(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"dashboard.internal.report.DashboardReportInternal");
        end
    end

    methods(Access=protected,Hidden)
        result=openImpl(reporter,impl,varargin);
    end
end