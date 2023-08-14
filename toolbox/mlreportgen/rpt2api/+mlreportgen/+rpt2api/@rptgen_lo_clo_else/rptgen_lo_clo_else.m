classdef rptgen_lo_clo_else<mlreportgen.rpt2api.Parent































    methods

        function this=rptgen_lo_clo_else(component,rptFileConverter)
            this=this@mlreportgen.rpt2api.Parent(component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)

            fprintf(this.FID,"else \n");
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
            import mlreportgen.rpt2api.rptgen_lo_clo_else
            templateFolder=fullfile(rptgen_lo_clo_else.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
