classdef rptgen_lo_clo_if<mlreportgen.rpt2api.Parent































    methods

        function obj=rptgen_lo_clo_if(component,rptFileConverter)
            obj=obj@mlreportgen.rpt2api.Parent(component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.*



            writeStartBanner(this);


            condStr=fixGetReported(this.Component.ConditionalString);
            fprintf(this.FID,"if %s\n",condStr);
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


            fprintf(this.FID,"%s %% if\n\n","end");



            writeEndBanner(this);
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
            import mlreportgen.rpt2api.rptgen_lo_clo_if
            templateFolder=fullfile(rptgen_lo_clo_if.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
