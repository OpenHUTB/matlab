classdef NullConverter<mlreportgen.rpt2api.ComponentConverter
















    methods

        function obj=NullConverter(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)
            import mlreportgen.rpt2api.NullConverter
            template=NullConverter.getTemplate('t');
            fprintf(obj.FID,template,class(obj.Component));
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
            import mlreportgen.rpt2api.NullConverter
            templateFolder=fullfile(NullConverter.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end

