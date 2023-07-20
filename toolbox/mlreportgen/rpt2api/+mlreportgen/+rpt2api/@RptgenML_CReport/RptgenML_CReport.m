classdef RptgenML_CReport<mlreportgen.rpt2api.Rptgen_CReport




































































    methods

        function obj=RptgenML_CReport(component,rptFileConverter)
            obj@mlreportgen.rpt2api.Rptgen_CReport(component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function writeImportStatements(this)
            import mlreportgen.rpt2api.RptgenML_CReport
            template=RptgenML_CReport.getTemplate('importStatements');
            fprintf(this.FID,"%s",template);
        end

        function writeCreateReport(this)
            fprintf(this.FID,"%% Create Report object to contain generated content.\n");
            fprintf(this.FID,"rptObj = Report(rptPath,rptOutputType);\n\n");

            fwrite(this.FID,"% Initialize variables to keep track of the report generation state."+newline);
            fwrite(this.FID,"% The rptState variable holds references to the current figure, axes, "+newline);
            fwrite(this.FID,"% etc. being reported. Report execution does not begin inside any loop"+newline);
            fwrite(this.FID,"% context, so the first ReportState is empty."+newline);
            fwrite(this.FID,"% Upon entering a new loop, the current state is preserved "+newline);
            fwrite(this.FID,"% by pushing the current state onto the rptStateStack. Upon exiting a loop,"+newline);
            fwrite(this.FID,"% the report state is restored to what it was before entering the loop by"+newline);
            fwrite(this.FID,"% popping the previous state off the top of the state stack."+newline);
            fwrite(this.FID,"rptStateStack = mlreportgen.utils.Stack();"+newline);
            fwrite(this.FID,"rptState = mlreportgen.rpt2api.ReportState();"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.RptgenML_CReport
            templateFolder=fullfile(RptgenML_CReport.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end




