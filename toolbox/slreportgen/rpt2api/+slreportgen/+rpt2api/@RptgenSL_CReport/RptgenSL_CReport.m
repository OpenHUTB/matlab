classdef RptgenSL_CReport<mlreportgen.rpt2api.Rptgen_CReport





































































    methods

        function obj=RptgenSL_CReport(component,rptFileConverter)
            obj@mlreportgen.rpt2api.Rptgen_CReport(component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function writeImportStatements(this)
            import slreportgen.rpt2api.RptgenSL_CReport
            template=RptgenSL_CReport.getTemplate('importStatements');
            fwrite(this.FID,template);
        end

        function writeCreateReport(this)
            import slreportgen.rpt2api.RptgenSL_CReport

            template=RptgenSL_CReport.getTemplate('tReportCreationComment');
            fwrite(this.FID,template);
            fwrite(this.FID,"rptObj = slreportgen.report.Report(rptPath, rptOutputType);"+newline+newline);

            if~this.Component.CompileModel
                fwrite(this.FID,"% Compile model to report on compiled information"+newline);
                fwrite(this.FID,"rptObj.CompileModelBeforeReporting = false;"+newline+newline);
            end

            fwrite(this.FID,"% Cache the current system at start of report generation"+newline);
            fwrite(this.FID,"% so as to reset it as the current system at end of report generation."+newline);
            fwrite(this.FID,"rptPreRunCurrentSystem = get_param(0,""CurrentSystem"");"+newline+newline);

            fwrite(this.FID,"% Initialize variables to keep track of the report generation state."+newline);
            fwrite(this.FID,"% The rptState variable holds references to the current model, system, block, "+newline);
            fwrite(this.FID,"% etc. being reported based on the loop(s) being executed. "+newline);
            fwrite(this.FID,"% Report execution does not begin inside any loop context, so "+newline);
            fwrite(this.FID,"% the first ReportState is empty."+newline);
            fwrite(this.FID,"% Upon entering a new loop, the current state is preserved "+newline);
            fwrite(this.FID,"% by pushing the current state onto the rptStateStack. Upon exiting a loop,"+newline);
            fwrite(this.FID,"% the report state is restored to what it was before entering the loop by"+newline);
            fwrite(this.FID,"% popping the previous state off the top of the state stack."+newline);
            fwrite(this.FID,"rptStateStack = mlreportgen.utils.Stack();"+newline);
            fwrite(this.FID,"rptState = slreportgen.rpt2api.ReportState();"+newline+newline);
        end

        function writeCleanupCode(this)
            writeCleanupCode@mlreportgen.rpt2api.Rptgen_CReport(this);
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.RptgenSL_CReport
            templateFolder=fullfile(RptgenSL_CReport.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end




