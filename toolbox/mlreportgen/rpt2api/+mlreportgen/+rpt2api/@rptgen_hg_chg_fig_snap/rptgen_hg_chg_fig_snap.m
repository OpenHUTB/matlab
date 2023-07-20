classdef rptgen_hg_chg_fig_snap<mlreportgen.rpt2api.ComponentConverter&mlreportgen.rpt2api.rptgen_hg_chg_hg_snap





























    methods

        function obj=rptgen_hg_chg_fig_snap(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            figVarName=getVariableName(this);
            fprintf(this.FID,"%s = mlreportgen.report.Figure(rptState.CurrentFigure);\n",figVarName);
            writeHandleGraphicsSnapshotProperties(this,figVarName);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptFigureRptr";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_hg_chg_fig_snap.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_hg_chg_fig_snap
            templateFolder=fullfile(rptgen_hg_chg_fig_snap.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
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

