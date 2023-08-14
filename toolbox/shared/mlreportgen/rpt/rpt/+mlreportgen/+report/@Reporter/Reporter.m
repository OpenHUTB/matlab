classdef Reporter<mlreportgen.report.ReporterBase




















    methods
        function reporter=Reporter(varargin)
            reporter=reporter@mlreportgen.report.ReporterBase(varargin{:});
        end
    end

    methods(Access={?mlreportgen.report.ReporterBase,?mlreportgen.report.ReportBase},Sealed,Hidden)
        function validateReport(~,report)
            import mlreportgen.report.validators.*


            mustBeReportBase(report);
        end
    end

    methods(Access=protected,Sealed,Hidden)
        function ctr=getImplCtr(~)
            ctr=str2func('mlreportgen.report.internal.DocumentPart');
        end
    end

    methods(Static)

        function path=getClassFolder()



            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)






            path=mlreportgen.report.Reporter.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)











            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.Reporter");
        end
    end

end

