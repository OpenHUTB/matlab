classdef rptgen_cform_page_hdrFtr<mlreportgen.rpt2api.ComponentConverter






























    methods(Abstract,Access=protected)



        getDOMClassName(this);
    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser



            writeStartBanner(this);

            varName=getVariableName(this);
            DOMClassName=getDOMClassName(this);
            pageType=this.Component.PageType;
            templateType=this.Component.TemplateType;

            if strcmp(templateType,"pageLayout")
                fprintf(this.FID,'%s = %s("%s");\n',...
                varName,DOMClassName,pageType);
            elseif strcmp(templateType,"file")
                fprintf(this.FID,'%s = %s("%s",getDefaultReportTemplate("%s"));\n',...
                varName,DOMClassName,pageType,this.RptFileConverter.OutputType);
            elseif strcmp(templateType,"library")
                docPartName=this.Component.DocPartTemplateName;
                templateSource=this.Component.TemplateSource;

                if strcmp(templateSource,"other")
                    fprintf(this.FID,'%s = %s("%s","%s","%s");\n',...
                    varName,DOMClassName,pageType,...
                    getTemplatePath(this,this.Component.Template),docPartName);
                elseif strcmp(templateSource,"reportForm")
                    fprintf(this.FID,'%s = %s("%s",rptObj.Document,"%s");\n',...
                    varName,DOMClassName,pageType,docPartName);
                elseif strcmp(templateSource,"parentSubform")
                    parentName=this.RptFileConverter.VariableNameStack.top;
                    if strcmp(parentName,"rptObj")
                        parentName="rptObj.Document";
                    end
                    fprintf(this.FID,'%s = %s("%s",%s,"%s");\n',...
                    varName,DOMClassName,pageType,parentName,docPartName);
                end
            end
        end

        function convertComponentChildren(this)

            varName=getVariableName(this);
            children=getComponentChildren(this);
            nChild=numel(children);
            if nChild>0

                fprintf(this.FID,"open(%s);\n\n",varName);





                fprintf(this.FID,"%% Fill holes in the %s\n",getDOMClassName(this));
                fprintf(this.FID,'while ~strcmp(%s.CurrentHoleId,"#end#")\n',varName);
                fprintf(this.FID,"switch %s.CurrentHoleId\n",varName);



                convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(this)




                fprintf(this.FID,"end\n");
                fprintf(this.FID,"moveToNextHole(%s);\n",varName);
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"close(%s);\n\n",varName);
            end





            fprintf(this.FID,"%% Assign this %s to the page layout\n",...
            getDOMClassName(this));
            fprintf(this.FID,"%s = [%s %s];\n\n",...
            this.AssignTo,this.AssignTo,getVariableName(this));



            writeEndBanner(this);
        end

        function name=getVariableRootName(this)





            name=strcat("rpt",getDOMClassName(this));
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
            import mlreportgen.rpt2api.rptgen_cform_page_hdrFtr
            templateFolder=fullfile(rptgen_cform_page_hdrFtr.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
