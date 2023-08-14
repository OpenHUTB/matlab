classdef rptgen_lo_clo_else_if<mlreportgen.rpt2api.Parent































    methods

        function this=rptgen_lo_clo_else_if(component,rptFileConverter)
            this=this@mlreportgen.rpt2api.Parent(component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.*


            condStr=fixGetReported(this.Component.ConditionalString);
            fprintf(this.FID,"elseif %s\n",condStr);
        end

        function convertComponentChildren(this)



            import mlreportgen.rpt2api.exprstr.Parser

            children=getComponentChildren(this);
            if isempty(children)


                parentObjName=top(this.RptFileConverter.VariableNameStack);
                Parser.writeExprStr(this.FID,...
                this.Component.TrueText,"rptTextStr");
                fprintf(this.FID,"rptText = Text(rptTextStr);\n");
                fprintf(this.FID,"append(%s,rptText);\n\n",...
                parentObjName);
            else

                convertComponentChildren@mlreportgen.rpt2api.Parent(this);
            end
        end

        function name=getVariableName(~)
            name=[];
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_lo_clo_else_if
            templateFolder=fullfile(rptgen_lo_clo_else_if.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
