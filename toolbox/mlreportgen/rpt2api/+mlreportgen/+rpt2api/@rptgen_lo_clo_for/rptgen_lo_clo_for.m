classdef rptgen_lo_clo_for<mlreportgen.rpt2api.ComponentConverter





























    methods

        function obj=rptgen_lo_clo_for(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)
            import mlreportgen.rpt2api.rptgen_lo_clo_for
            import mlreportgen.rpt2api.exprstr.Parser

            writeStartBanner(obj)

            if obj.Component.LoopType=="increment"
                parser=Parser(obj.Component.StartNumber);
                parse(parser);
                startCounter=str2double(parser.FormatString);
                if isnan(startCounter)
                    fprintf(obj.FID,"rptLoopStart = %s;\n",parser.FormatString);
                else
                    fprintf(obj.FID,"rptLoopStart = %d;\n",startCounter);
                end

                parser=Parser(obj.Component.IncrementNumber);
                parse(parser);
                incrCounter=str2double(parser.FormatString);
                if isnan(incrCounter)
                    fprintf(obj.FID,"rptLoopIncr = %s;\n",parser.FormatString);
                else
                    fprintf(obj.FID,"rptLoopIncr = %d;\n",incrCounter);
                end

                parser=Parser(obj.Component.EndNumber);
                parse(parser);
                endCounter=str2double(parser.FormatString);
                if isnan(endCounter)
                    fprintf(obj.FID,"rptLoopEnd = %s;\n",parser.FormatString);
                else
                    fprintf(obj.FID,"rptLoopEnd = %d;\n",endCounter);
                end

                fprintf(obj.FID,'for %s = ...\nrptLoopStart: ...\nrptLoopIncr: ...\nrptLoopEnd\n\n',...
                obj.Component.VariableName);
            else
                Parser.writeExprStr(obj.FID,...
                obj.Component.LoopVector,'rptLoopIndices');
                fprintf(obj.FID,"for %s = eval(rptLoopIndices)\n",...
                obj.Component.VariableName);
            end

        end

        function convertComponentChildren(obj)
            children=getComponentChildren(obj);
            n=numel(children);
            for i=1:n
                cmpn=children{i};
                c=getConverter(obj.RptFileConverter.ConverterFactory,...
                cmpn,obj.RptFileConverter);
                convert(c);
            end

            fprintf(obj.FID,"end\n\n");

            writeEndBanner(obj)
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
            import mlreportgen.rpt2api.rptgen_lo_clo_for
            templateFolder=fullfile(rptgen_lo_clo_for.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end

