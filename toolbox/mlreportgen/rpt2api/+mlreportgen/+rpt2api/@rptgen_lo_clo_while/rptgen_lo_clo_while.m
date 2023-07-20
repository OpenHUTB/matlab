classdef rptgen_lo_clo_while<mlreportgen.rpt2api.ComponentConverter





























    properties(Access=private)


        LoopConverted=true;
    end

    methods

        function this=rptgen_lo_clo_while(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser

            if isempty(getComponentChildren(this))||...
                isempty(this.Component.EvalInitString)


                this.LoopConverted=false;
                return;
            end



            writeStartBanner(this);


            Parser.writeExprStr(this.FID,...
            this.Component.EvalInitString,"rptLoopInitString");
            fprintf(this.FID,"eval(rptLoopInitString);\n\n");

            conditionalString=this.Component.ConditionalString;
            if this.Component.isMaxIterations


                fprintf(this.FID,"rptLoopCurrIteration = 1;\n");
                fprintf(this.FID,"rptLoopMaxIterations = %d;\n\n",...
                this.Component.MaxIterations);
                conditionalString=strcat(conditionalString,...
                " && (rptLoopCurrIteration <= rptLoopMaxIterations)");
            end


            fprintf(this.FID,"while(%s)\n\n",conditionalString);
        end

        function convertComponentChildren(this)
            if this.LoopConverted

                children=getComponentChildren(this);
                nChild=numel(children);

                for iChild=1:nChild
                    cmpn=children{iChild};
                    c=getConverter(this.RptFileConverter.ConverterFactory,...
                    cmpn,this.RptFileConverter);
                    convert(c);
                end



                if this.Component.isMaxIterations
                    fprintf(this.FID,...
                    "rptLoopCurrIteration = rptLoopCurrIteration + 1;\n");
                end


                fprintf(this.FID,"end\n\n");



                writeEndBanner(this);
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
            import mlreportgen.rpt2api.rptgen_lo_clo_while
            templateFolder=fullfile(rptgen_lo_clo_while.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end

