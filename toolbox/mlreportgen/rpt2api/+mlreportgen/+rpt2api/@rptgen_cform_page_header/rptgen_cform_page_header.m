classdef rptgen_cform_page_header<mlreportgen.rpt2api.rptgen_cform_page_hdrFtr































    methods

        function this=rptgen_cform_page_header(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function className=getDOMClassName(this)


            className=[];
            rptOutputType=this.RptFileConverter.OutputType;
            if strcmpi(rptOutputType,"docx")
                className="DOCXPageHeader";
            elseif strcmpi(rptOutputType,"pdf")
                className="PDFPageHeader";
            end
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cform_page_header.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cform_page_header
            templateFolder=fullfile(rptgen_cform_page_header.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

    methods(Access=private,Static)
        function count=getCurrentCounter()


            persistent counter;
            if isempty(counter)


                counter=1;




                mlreportgen.rpt2api.ComponentConverter.classesToClearAfterConversion(mfilename);
            else

                counter=counter+1;
            end
            count=counter;
        end
    end

end
