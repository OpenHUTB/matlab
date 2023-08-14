classdef rptgen_cform_subform<mlreportgen.rpt2api.ComponentConverter


































    methods

        function this=rptgen_cform_subform(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)


            writeStartBanner(this);

            varName=getVariableName(this);
            templateType=this.Component.TemplateType;







            if strcmp(templateType,"file")
                fprintf(this.FID,'%s = DocumentPart(rptObj.Type,"%s");\n',...
                varName,getTemplatePath(this,this.Component.Template));
            elseif strcmp(templateType,"library")
                docPartName=this.Component.DocPartTemplateName;
                templateSource=this.Component.TemplateSource;
                if strcmp(templateSource,"reportForm")
                    fprintf(this.FID,...
                    '%s = DocumentPart(rptObj.Document,"%s");\n',...
                    varName,docPartName);
                elseif strcmp(templateSource,"parentSubform")
                    parentName=this.RptFileConverter.VariableNameStack.top;
                    fprintf(this.FID,'%s = DocumentPart(%s,"%s");\n',...
                    varName,parentName,docPartName);
                elseif strcmp(templateSource,"other")
                    fprintf(this.FID,...
                    '%s = DocumentPart(rptObj.Type,"%s","%s");\n',...
                    varName,getTemplatePath(this,this.Component.Template),docPartName);
                end
            end
        end

        function convertComponentChildren(this)

            varName=getVariableName(this);
            children=getComponentChildren(this);
            nChild=numel(children);
            if nChild>0

                fprintf(this.FID,"open(%s);\n\n",varName);





                fwrite(this.FID,"% Fill holes in the document part."+newline);
                fprintf(this.FID,'while ~strcmp(%s.CurrentHoleId,"#end#")\n',varName);
                fprintf(this.FID,"switch %s.CurrentHoleId\n",varName);



                convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(this);




                fprintf(this.FID,"end\n");
                fprintf(this.FID,"moveToNextHole(%s);\n",varName);
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"close(%s);\n\n",varName);
            end


            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n\n",parentName,varName);



            writeEndBanner(this);
        end

        function name=getVariableRootName(~)





            name="rptDocPart";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cform_subform.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Access=private)

        function templatePath=getTemplatePath(this,template)


            cache=rptgen.db2dom.TemplateCache.getTheCache();
            [~,templateId,~]=fileparts(template);
            templatePath=[];
            switch this.RptFileConverter.OutputType
            case "docx"
                templatePath=getDOCXTemplate(cache,templateId);
            case "html"
                templatePath=getHTMLTemplate(cache,templateId);
            case "pdf"
                templatePath=getPDFTemplate(cache,templateId);
            case "html-file"
                templatePath=getHTMLFileTemplate(cache,templateId);
            end
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cform_subform
            templateFolder=fullfile(rptgen_cform_subform.getClassFolder,...
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
