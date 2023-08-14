classdef rptgen_hg_chg_ax_snap<mlreportgen.rpt2api.ComponentConverter&mlreportgen.rpt2api.rptgen_hg_chg_hg_snap




























    methods

        function obj=rptgen_hg_chg_ax_snap(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            axesVarName=getVariableName(this);
            fprintf(this.FID,"%s = mlreportgen.report.Axes(rptState.CurrentAxes);\n",axesVarName);
            writeHandleGraphicsSnapshotProperties(this,axesVarName);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptAxesRptr";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_hg_chg_ax_snap.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_hg_chg_ax_snap
            templateFolder=fullfile(rptgen_hg_chg_ax_snap.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.m']);
            template=fileread(templatePath);
        end
    end

    methods(Access=private,Static)
        function count=getCurrentCounter()


            persistent counter;
            if isempty(counter)


                counter=1;




                mlreportgen.rpt2api.ComponentConverter.classesToClearAfterConversion(mfilename);
            else

                counter=counter+1;
            end
            count=counter;
        end
    end

end

