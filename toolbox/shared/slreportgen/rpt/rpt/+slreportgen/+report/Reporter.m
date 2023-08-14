classdef Reporter<mlreportgen.report.ReporterBase





















    methods
        function reporter=Reporter(varargin)
            reporter=reporter@mlreportgen.report.ReporterBase(varargin{:});
        end
    end

    methods(Access={?mlreportgen.report.ReporterBase,?mlreportgen.report.ReportBase},Sealed,Hidden)
        function validateReport(~,report)
            import slreportgen.report.validators.*
            mustBeSimulinkReport(report);
        end
    end

    methods(Access=protected,Sealed,Hidden)
        function ctr=getImplCtr(~)
            ctr=str2func('slreportgen.report.internal.DocumentPart');
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(this,rpt)
            if strcmp(class(this),"slreportgen.report.Reporter")


                reporterPath=mlreportgen.report.Reporter.getClassFolder();
                templatePath=...
                mlreportgen.report.ReportForm.getFormTemplatePath(...
                reporterPath,rpt.Type);
            else

                templatePath=...
                getDefaultTemplatePath@mlreportgen.report.ReporterBase(this,rpt);
            end

        end
    end

    methods(Static)

        function path=getClassFolder()



            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)






            sourcePath=mlreportgen.report.Reporter.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,sourcePath);
        end

        function classfile=customizeReporter(toClasspath)











            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "slreportgen.report.Reporter","mlreportgen.report.Reporter");
        end
    end

end
