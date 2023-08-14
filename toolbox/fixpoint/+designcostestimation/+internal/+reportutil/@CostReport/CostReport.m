classdef CostReport<slreportgen.report.Report





    properties
    end

    methods

        function obj=CostReport(varargin)
            obj=obj@slreportgen.report.Report(varargin{:});
        end
    end



    methods(Hidden)
        function templatePath=getDefaultTemplatePath(rpt)
            path=designcostestimation.internal.reportutil.CostReport.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end

    end

    methods(Access=protected,Hidden)
        result=openImpl(report,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function createTemplate(templatePath,type)
            path=designcostestimation.internal.reportutil.CostReport.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReport(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"designcostestimation.internal.reportutil.CostReport");
        end

    end
end