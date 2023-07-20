classdef rptgen_sf_csf_chart_loop<mlreportgen.rpt2api.LoopComponentConverter



























    properties(Access=private)
        Context="";
    end

    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_sig_loop",...
        "csf_machine_loop",...
        "csf_chart_loop"];
    end

    methods

        function this=rptgen_sf_csf_chart_loop(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

        function writeAutomaticChartList(this,listVarName)
            ctx=getContext(this,this.SupportedContexts);

            switch ctx
            case "rptgen_sl.csl_mdl_loop"

                fprintf(this.FID,"if %s.CurrentModelOptions.ReportStartingSystemOnly\n",this.RptStateVariable);
                fprintf(this.FID,"%s = [];\n",listVarName);

                fwrite(this.FID,"else"+newline);


                fwrite(this.FID,"% Create a finder to find charts in the current model"+newline);

                fprintf(this.FID,"rptChartFinder = ChartDiagramFinder(%s.CurrentModelHandle);\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder options"+newline);
                fwrite(this.FID,"rptChartFinder.IncludeReferencedModels = false; % Reference models are already found by model loop"+newline);


                fwrite(this.FID,"% Find charts and add them to the chart list"+newline);
                fprintf(this.FID,"%s = find(rptChartFinder);\n",listVarName);


                fwrite(this.FID,"end"+newline+newline);

            case "rptgen_sl.csl_sys_loop"

                fwrite(this.FID,"% Create a finder to find charts in the current system"+newline);

                fprintf(this.FID,"rptChartFinder = ChartDiagramFinder(%s.CurrentSystem.Object);\n",this.RptStateVariable);
                fwrite(this.FID,"% Find charts only in this system"+newline);
                fwrite(this.FID,"rptChartFinder.SearchDepth = 1;"+newline);

                fwrite(this.FID,"% Find charts and add them to the chart list"+newline);
                fprintf(this.FID,"%s = find(rptChartFinder);\n\n",listVarName);

            case "rptgen_sf.csf_machine_loop"


            case "rptgen_sl.csl_sig_loop"
                fwrite(this.FID,"% Report on charts connected to the current signal."+newline);
                fprintf(this.FID,"rptConnectedBlockList = [{%s.CurrentSignal.SourceBlock}; ...\n",...
                this.RptStateVariable);
                fprintf(this.FID,"traceSignal(%s.CurrentSignal.Object,Nonvirtual=false)];\n",this.RptStateVariable);
                fprintf(this.FID,"%% Remove blocks that are not charts from the list.\n");
                fprintf(this.FID,"rptChartObjectList = block2chart(rptConnectedBlockList);\n");
                fprintf(this.FID,"rptNChartObjects = numel(rptChartObjectList);\n");
                fprintf(this.FID,"%s = DiagramResult.empty(0,rptNChartObjects);\n",listVarName);
                fprintf(this.FID,"for rptI = 1:rptNChartObjects\n");
                fprintf(this.FID,"%s(rptI) = DiagramResult(rptChartObjectList(rptI));\n",...
                listVarName);
                fprintf(this.FID,"end\n\n");

            case "rptgen_sf.csf_chart_loop"
                fwrite(this.FID,"% Use current chart"+newline);
                fprintf(this.FID,"%s = rptState.CurrentChart;\n\n",listVarName);

            otherwise

                fwrite(this.FID,"% Report on all charts in all open models"+newline);
                fprintf(this.FID,"%s = [];\n",listVarName);
                fwrite(this.FID,"% Find all open models"+newline);
                fwrite(this.FID,"rptChartLoopModelList = find_system( ..."+newline);
                fwrite(this.FID,"SearchDepth=0, ..."+newline);
                fwrite(this.FID,"type=""block_diagram"", ..."+newline);
                fwrite(this.FID,"BlockDiagramType=""model"");"+newline+newline);
                fwrite(this.FID,"% Loop through open models"+newline);
                fwrite(this.FID,"rptN = numel(rptChartLoopModelList);"+newline);
                fwrite(this.FID,"for rptI = 1:rptN"+newline);
                fwrite(this.FID,"% Create a chart finder"+newline);
                fwrite(this.FID,"rptChartFinder = ChartDiagramFinder(rptChartLoopModelList{rptI});"+newline);
                fwrite(this.FID,"% Get finder results and add them to the chart list"+newline);
                fprintf(this.FID,"%s = [%s, find(rptChartFinder)]; %%#ok<AGROW> \n",...
                listVarName,listVarName);
                fwrite(this.FID,"end"+newline+newline);
            end
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sf_csf_chart_loop

            writeStartBanner(this);
            writeSaveState(this);


            suffix=this.LoopVariableSuffix;

            if strcmp(this.Component.LoopType,"auto")
                writeAutomaticChartList(this,"rptChartList"+suffix);
            else
                writeCustomChartList(this);
            end


            if this.Component.isFilterList&&~isempty(this.Component.FilterTerms)
                writeFilterCharts(this);
            end


            if this.Component.isSFFilterList&&~isempty(this.Component.SFFilterTerms)
                writeSFFilterCharts(this);
            end


            if~strcmp(this.Component.SortBy,"none")
                fwrite(this.FID,"% Sort reported chart blocks"+newline);
                fprintf(this.FID,"rptChartList%s = sortBlocks(rptChartList%s,""%s"");\n\n",...
                suffix,suffix,this.Component.SortBy);
            end

            fwrite(this.FID,"% Loop through list of charts to be reported."+newline);
            fprintf(this.FID,"rptNCharts%s = numel(rptChartList%s);\n",suffix,suffix);
            fprintf(this.FID,"for rptIChart%s = 1:rptNCharts%s\n",suffix,suffix);
            fprintf(this.FID,"%s.CurrentChart = rptChartList%s(rptIChart%s);\n",...
            this.RptStateVariable,suffix,suffix);

            writeObjectSectionCode(this);
        end

        function writeCustomChartList(this)
            import mlreportgen.rpt2api.exprstr.Parser


            fwrite(this.FID,"% Loop on the specified charts"+newline);
            objList=this.Component.ObjectList;
            nObj=numel(objList);
            if nObj>0
                fprintf(this.FID,"rptChartList%s = [ ...\n",this.LoopVariableSuffix);

                for k=1:nObj
                    objExpr=objList{k};
                    if regexp(objExpr,'.*%<.+>')
                        p=Parser(objExpr);
                        parse(p);
                        fprintf(this.FID,"DiagramResult("+p.FormatString+")",p.Expressions{:});
                        fprintf(this.FID,", ... %% converted from: %s\n",strrep(p.ExprStr,newline,'\n'));
                    else
                        fwrite(this.FID,"DiagramResult("""+objExpr+"""), ..."+newline);
                    end
                end
                fwrite(this.FID,"];"+newline+newline);
            end
        end

        function writeFilterCharts(this)

            searchArgs=washSearchTerms(this.Component.FilterTerms(:)');

            fwrite(this.FID,"% Filter charts based on specified Simulink properties"+newline);
            fprintf(this.FID,"rptChartListPaths = [rptChartList%s.Path];\n",...
            this.LoopVariableSuffix);
            fprintf(this.FID,"rptChartListFiltered = find_system(rptChartListPaths, ...\n");
            fwrite(this.FID,"SearchDepth=0, ..."+newline);
            fwrite(this.FID,"Regexp=""on""");

            nTerms=numel(searchArgs);
            for k=1:2:nTerms
                fprintf(this.FID,", ...\n%s=""%s""",searchArgs{k},searchArgs{k+1});
            end
            fwrite(this.FID,");"+newline+newline);
            fprintf(this.FID,"%% Find indices of charts that were not filtered\n");
            fprintf(this.FID,"rptChartListIdx = ismember(rptChartListPaths,rptChartListFiltered);\n");
            fprintf(this.FID,"rptChartList%s = rptChartList%s(rptChartListIdx);\n\n",...
            this.LoopVariableSuffix,this.LoopVariableSuffix);
        end

        function writeSFFilterCharts(this)

            searchArgs=washSearchTerms(this.Component.SFFilterTerms(:)');

            fwrite(this.FID,"% Filter charts based on specified Stateflow properties"+newline);

            fprintf(this.FID,"if ~isempty(rptChartList%s)\n",this.LoopVariableSuffix);
            fprintf(this.FID,"rptChartListObjects = [rptChartList%s.Object];\n",...
            this.LoopVariableSuffix);
            fprintf(this.FID,"rptChartListFiltered = find(rptChartListObjects, ...\n");
            fwrite(this.FID,"""-depth"",0,""-regexp""");

            nTerms=numel(searchArgs);
            for k=1:2:nTerms
                propIdx=k;
                valIdx=propIdx+1;


                propName=string(searchArgs{propIdx});
                if startsWith(propName,".")

                    propName=extractAfter(propName,".");
                end
                fprintf(this.FID,", ...\n%s=",propName);



                val=searchArgs{valIdx};
                if strcmp(propName,'-function')


                    valFormatStr="%s";
                else



                    strAsDouble=str2double(val);
                    if~isnan(strAsDouble)
                        valFormatStr="%s";
                    else
                        valFormatStr="""%s""";
                    end
                end

                fprintf(this.FID,valFormatStr,val);
            end
            fwrite(this.FID,");"+newline);
            fprintf(this.FID,"%% Find indices of charts that were not filtered\n");
            fprintf(this.FID,"rptChartListIdx = ismember(rptChartListObjects,rptChartListFiltered);\n");
            fprintf(this.FID,"rptChartList%s = rptChartList%s(rptChartListIdx);\n\n",...
            this.LoopVariableSuffix,this.LoopVariableSuffix);
            fwrite(this.FID,"end"+newline+newline);
        end

        function name=getVariableName(~)
            name=[];
        end

    end


    methods(Access=protected)

        function writeSectionTitleCode(this,titleVarName,~)
            fprintf(this.FID,"rptChartName = %s.CurrentChart.Name;\n",this.RptStateVariable);
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf(""Chart - %s"",rptChartName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptChartName;"+newline);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = getReporterLinkTargetID(%s.CurrentChart);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % chart loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sf_csf_chart_loop
            templateFolder=fullfile(rptgen_sf_csf_chart_loop.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,strcat(templateName,'.txt'));
            template=fileread(templatePath);
        end

    end

end

function t=washSearchTerms(t)
    numTerms=length(t);
    if rem(numTerms,2)>0

        t{end+1}='';
        numTerms=numTerms+1;
    end

    emptyCells=find(cellfun('isempty',t));
    emptyNames=emptyCells(1:2:end-1);
    emptyNames=emptyNames(:);

    removeCells=[emptyNames;emptyNames+1];
    okCells=setdiff([1:numTerms],removeCells);

    t=t(okCells);
end