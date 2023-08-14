classdef rptgen_cfr_line_break<mlreportgen.rpt2api.ComponentConverter




























    methods

        function obj=rptgen_cfr_line_break(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)
            parentName=obj.RptFileConverter.VariableNameStack.top;
            fprintf(obj.FID,'append(%s,LineBreak);\n\n',parentName);
        end

        function convertComponentChildren(~)

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
            import mlreportgen.rpt2api.rptgen_cfr_line_break
            templateFolder=fullfile(rptgen_cfr_line_break.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end

