classdef RptFile<mlreportgen.report.Reporter&...
    mlreportgen.report.internal.RptFileBase






























































    methods

        function this=RptFile(varargin)
            if(nargin==1)
                varargin=[{"SetupFile"},varargin];
            end

            this=this@mlreportgen.report.Reporter(varargin{:});


            if isempty(this.TemplateName)
                this.TemplateName="RptFile";
            end
        end

        function impl=getImpl(this,rpt)

            loadSetupFile(this);



            impl=getImpl@mlreportgen.report.Reporter(this,rpt);
        end

    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreportgen.report.RptFile})
        function content=getContent(this,rpt)





            content=getHoleContent(this,rpt);
        end
    end


    methods(Static)

        function path=getClassFolder()


            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)








            path=mlreportgen.report.RptFile.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.RptFile");
        end

    end

end