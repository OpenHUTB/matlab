classdef(Abstract)rptgen_cfr_ext_table_section<mlreportgen.rpt2api.ComponentConverter
































    properties(Abstract,Access=protected)


        SectionName;
    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser



            writeStartBanner(this);


            parentName=this.RptFileConverter.VariableNameStack.top;
            DOMTableVarName=sprintf("%s.Content",parentName);


            sectionVariableName=getVariableName(this);
            fprintf(this.FID,"%s = %s.%s;\n",...
            sectionVariableName,DOMTableVarName,this.SectionName);


            if strcmpi(this.Component.StyleNameType,"custom")...
                &&~isempty(this.Component.StyleName)
                Parser.writeExprStr(this.FID,...
                this.Component.StyleName,...
                sprintf("%s.StyleName",sectionVariableName));
            end


            fprintf(this.FID,'%s.TableEntriesVAlign = "%s";\n',...
            sectionVariableName,this.Component.VertAlign);
        end

        function convertComponentChildren(this)

            convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(this);



            writeEndBanner(this);
        end

        function name=getVariableRootName(this)





            name=strcat("rptTable",this.SectionName);
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_ext_table_section
            templateFolder=fullfile(rptgen_cfr_ext_table_section.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
