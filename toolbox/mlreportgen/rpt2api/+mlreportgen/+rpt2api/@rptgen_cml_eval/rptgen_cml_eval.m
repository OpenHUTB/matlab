classdef rptgen_cml_eval<mlreportgen.rpt2api.ComponentConverter





























    methods

        function obj=rptgen_cml_eval(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)



            import mlreportgen.rpt2api.rptgen_cml_eval

            writeStartBanner(obj)

            fprintf(obj.FID,"%% Expression to be evaluated:\n");

            isCatch=obj.Component.isCatch;
            if isCatch
                fprintf(obj.FID,"try\n");
            end

            evalString=strrep(obj.Component.EvalString,'\','\\');
            evalString=strrep(evalString,newline,'\n');
            evalString=strrep(evalString,'%','%%');

            if obj.Component.isDiary
                parentName=top(obj.RptFileConverter.VariableNameStack);
                fprintf(obj.FID,'rptEvalString = ''%s'';\n',...
                evalString);
                fprintf(obj.FID,"rptEvalOutputString = evalc(sprintf(rptEvalString));\n");
                fprintf(obj.FID,"disp(rptEvalOutputString);\n\n");
                fprintf(obj.FID,"%% Add command line result of evaluation to report\n");
                fprintf(obj.FID,'append(%s, Preformatted(rptEvalOutputString));\n\n',...
                parentName);

            else
                fprintf(obj.FID,evalString);
                fprintf(obj.FID,"\n");
            end

            if isCatch
                fprintf(obj.FID,"catch evalException\n");
                catchString=strrep(obj.Component.CatchString,'\','\\');
                catchString=strrep(catchString,newline,'\n');
                catchString=strrep(catchString,'%','%%');
                fprintf(obj.FID,catchString);
                fprintf(obj.FID,"\nend\n\n");
            end

            if obj.Component.isInsertString
                parentName=top(obj.RptFileConverter.VariableNameStack);
                fprintf(obj.FID,"%% Add expression to be evaluated to the report\n");
                fprintf(obj.FID,'rptEvalString = sprintf("%s");\n',...
                evalString);
                fprintf(obj.FID,'append(%s, Preformatted(rptEvalString));\n\n',...
                parentName);
            end

            writeEndBanner(obj)

        end

        function name=getVariableName(~)




            name=[];
        end

        function convertComponentChildren(~)
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cml_eval
            templateFolder=fullfile(rptgen_cml_eval.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end

