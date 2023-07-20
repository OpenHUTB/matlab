classdef EvolutionSpecReport<mlreportgen.report.Report







    properties
    end

    methods
        function obj=EvolutionSpecReport(varargin)
            obj=obj@mlreportgen.report.Report(varargin{:});
        end
    end





    methods(Access=protected,Hidden)

        result=openImpl(report,impl,varargin)
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(rpt)
            path=evolutions.internal.report.EvolutionSpecReport.getClassFolder();
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
            path=EvolutionSpecReport.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReporter(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"EvolutionSpecReport");
        end

    end

end


