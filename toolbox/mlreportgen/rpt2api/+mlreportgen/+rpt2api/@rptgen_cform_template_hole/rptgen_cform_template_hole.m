classdef rptgen_cform_template_hole<mlreportgen.rpt2api.Parent


































    methods

        function this=rptgen_cform_template_hole(component,rptFileConverter)
            this=this@mlreportgen.rpt2api.Parent(component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)






            fprintf(this.FID,'case "%s"\n',this.Component.HoleId);
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
            import mlreportgen.rpt2api.rptgen_cform_template_hole
            templateFolder=fullfile(rptgen_cform_template_hole.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
