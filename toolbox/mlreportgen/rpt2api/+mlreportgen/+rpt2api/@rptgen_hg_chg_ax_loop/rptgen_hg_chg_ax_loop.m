classdef rptgen_hg_chg_ax_loop<mlreportgen.rpt2api.LoopComponentConverter




























    methods

        function obj=rptgen_hg_chg_ax_loop(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.rptgen_hg_chg_ax_loop

            writeStartBanner(this);
            writeSaveState(this);
            axesVarName=rptgen_hg_chg_ax_loop.getListVariableName();

            if strcmp(this.Component.LoopType,'current')
                fwrite(this.FID,"% Loop through list of axes to be reported."+newline);

                fprintf(this.FID,"rptAxesCurrentFigure = get(0, 'CurrentFigure');\n");
                fprintf(this.FID,"%s = get(rptAxesCurrentFigure,'CurrentAxes');\n",axesVarName);
                fwrite(this.FID,"% Loop through list of axes to be reported."+newline);
                fwrite(this.FID,"rptNAxes = 1;"+newline);
                fprintf(this.FID,"for rptAxesLoopIdx=1:rptNAxes\n");
                fprintf(this.FID,"rptState.CurrentAxes = %s(rptAxesLoopIdx);"+newline,axesVarName);
            else
                fprintf(this.FID,"rptCurrentFigure = rptState.CurrentFigure;"+newline+newline);
                allowedContextList=["rptgen_hg.chg_obj_loop","rptgen_hg.chg_ax_loop","rptgen_hg.chg_fig_loop"];
                loopContext=getContext(this,allowedContextList);
                if isempty(loopContext)


                    fwrite(this.FID,"% Loop on all axes in 'CurrentFigure', since we not in context of a figure loop."+newline);
                    fprintf(this.FID,"rptFirstTerm=0;"+newline+newline);
                else


                    fwrite(this.FID,"% Loop on all axes based on context of the figure loop."+newline);
                    fprintf(this.FID,"rptFirstTerm=rptCurrentFigure;"+newline+newline);
                end

                fprintf(this.FID,"rptSearchTerms={"+newline);
                if(strcmpi(this.Component.IncludeHidden,'findobj'))
                    fprintf(this.FID,"'HandleVisibility',..."+newline);
                    fprintf(this.FID,"'on',..."+newline);
                end
                for idx=1:length(this.Component.SearchTerms)
                    fprintf(this.FID,"'%s',..."+newline,this.Component.SearchTerms{idx});
                end
                fprintf(this.FID,"};"+newline+newline);

                fprintf(this.FID,"if isempty(rptCurrentFigure)"+newline);
                fprintf(this.FID,"%s = [];"+newline,axesVarName);
                fprintf(this.FID,"else"+newline);
                fprintf(this.FID,"rptAxesFinder =  mlreportgen.finder.AxesFinder(rptFirstTerm);"+newline);
                fprintf(this.FID,"rptAxesFinder.Properties = rptSearchTerms;"+newline);
                fprintf(this.FID,"%s = find(rptAxesFinder);"+newline,axesVarName);
                fprintf(this.FID,"end"+newline+newline);

                fwrite(this.FID,"% Loop through list of axes to be reported."+newline);
                fprintf(this.FID,"rptAxesCount = length(%s);\n",axesVarName);
                fprintf(this.FID,"for rptAxesLoopIdx=1:rptAxesCount\n");
                fprintf(this.FID,"rptState.CurrentAxes = %s(rptAxesLoopIdx).Object;"+newline,axesVarName);
            end
            writeObjectSectionCode(this);
        end

        function name=getVariableName(~)
            name=[];
        end
    end


    methods(Access=protected)

        function writeSectionTitleCode(this,titleVarName,~)
            fprintf(this.FID,"rptAxesName = 'Axes';\n");
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf('Axes - %s', rptAxesName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptAxesName;"+newline);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = mlreportgen.report.Axes.getLinkTargetID(%s.CurrentAxes);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % axes loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function name=getListVariableName()
            name="rptAxesList";
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_hg_chg_ax_loop
            templateFolder=fullfile(rptgen_hg_chg_ax_loop.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.m']);
            template=fileread(templatePath);
        end
    end
end
