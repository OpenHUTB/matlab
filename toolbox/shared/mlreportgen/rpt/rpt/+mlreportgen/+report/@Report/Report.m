classdef Report<mlreportgen.report.ReportBase&...
    mlreportgen.report.internal.Report































































































    methods
        function rpt=Report(varargin)
            rpt=rpt@mlreportgen.report.ReportBase(varargin{:});
        end
    end


    methods(Static)
        function path=getClassFolder()




            path=fileparts(mfilename('fullpath'));
        end

        function classfile=customizeReport(toClasspath)













            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.Report");
        end

        function template=createTemplate(templatePath,type)






            path=mlreportgen.report.Report.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

    end

end

