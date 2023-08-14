classdef rptgen_sf_csf_state_loop<mlreportgen.rpt2api.LoopComponentConverter



























    properties(Access=private)
        Context="";
    end

    properties(Access=private,Constant)
        SupportedContexts=["csf_chart_loop",...
        "csf_machine_loop",...
        "csf_state_loop",...
        "csf_obj_loop"];
    end

    methods

        function this=rptgen_sf_csf_state_loop(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            writeStartBanner(this);
            writeSaveState(this);


            suffix=this.LoopVariableSuffix;

            writeStateList(this);


            if this.Component.isSFFilterList&&~isempty(this.Component.SFFilterTerms)
                writeSFFilterStates(this);
            end

            fwrite(this.FID,"% Loop through list of states to be reported."+newline);
            fprintf(this.FID,"rptNStates%s = numel(rptStateList%s);\n",suffix,suffix);
            fprintf(this.FID,"for rptIState%s = 1:rptNStates%s\n",suffix,suffix);
            fprintf(this.FID,"%s.CurrentState = rptStateList%s(rptIState%s);\n",...
            this.RptStateVariable,suffix,suffix);

            writeObjectSectionCode(this);
        end

        function writeStateList(this)
            ctx=getContext(this,this.SupportedContexts);
            types=getTypes(this);
            if isempty(types)
                fprintf(this.FID,"%% No state types specified\n");
                fprintf(this.FID,"rptStateList%s = [];\n\n",this.LoopVariableSuffix);
                return
            end

            switch ctx
            case "rptgen_sf.csf_machine_loop"


            case "rptgen_sf.csf_obj_loop"
                fprintf(this.FID,"%% Use the parent state of the current object\n");
                fprintf(this.FID,"rptObjectParent = %s.CurrentStateflowObject.Object.up;\n",this.RptStateVariable);
                fprintf(this.FID,"if ismember(class(rptObjectParent), ...\n[");
                nTypes=numel(types);
                fprintf(this.FID,"""%s""",types(1));
                for idx=2:nTypes
                    fprintf(this.FID,", ...\n""%s""",types(idx));
                end
                fprintf(this.FID,"])\n");
                fprintf(this.FID,"rptStateList%s = DiagramElementResult(rptObjectParent);\n",...
                this.LoopVariableSuffix);
                fprintf(this.FID,"else\n");
                fprintf(this.FID,"rptStateList%s = [];\n",...
                this.LoopVariableSuffix);
                fprintf(this.FID,"end\n");


            case "rptgen_sf.csf_chart_loop"
                fwrite(this.FID,"% Report on states in the current chart"+newline);
                constructorInput=sprintf("%s.CurrentChart.Object",this.RptStateVariable);
                writeFinderCode(this,constructorInput,types);

            case "rptgen_sf.csf_state_loop"




                fwrite(this.FID,"% Search the current state"+newline);
                fprintf(this.FID,"rptStateListObjects = find(%s.CurrentState.Object",...
                this.RptStateVariable);
                nTypes=numel(types);
                fprintf(this.FID,", ...\n""-isa"",""%s""",types(1));
                for idx=2:nTypes
                    fprintf(this.FID,", ...\n""-or"",""-isa"",""%s""",types(idx));
                end
                if~strcmp(this.Component.Depth,"deep")
                    fprintf(this.FID,", ...\n""-depth"",1");
                end
                fprintf(this.FID,");\n\n");

                fprintf(this.FID,"%% Remove the parent state that was searched\n");
                fprintf(this.FID,"if ~isempty(rptStateListObjects) && ...\n");
                fprintf(this.FID,"rptStateListObjects(1) == %s.CurrentState.Object\n",this.RptStateVariable);
                fprintf(this.FID,"rptStateListObjects(1) = [];\n");
                fprintf(this.FID,"end\n");

                fprintf(this.FID,"rptNStates%s = numel(rptStateListObjects);\n",...
                this.LoopVariableSuffix);
                fprintf(this.FID,"rptStateList%s = DiagramElementResult.empty(0,rptNStates);\n",...
                this.LoopVariableSuffix);
                fprintf(this.FID,"for rptI = 1:rptNStates%s\n",this.LoopVariableSuffix);
                fprintf(this.FID,"rptStateList%s(rptI) = DiagramElementResult(rptStateListObjects(rptI));\n",...
                this.LoopVariableSuffix);
                fprintf(this.FID,"end\n");

            otherwise


                chartLoop=slreportgen.rpt2api.rptgen_sf_csf_chart_loop(this.Component,this.RptFileConverter);
                chartListName="rptStateLoopChartList";
                writeAutomaticChartList(chartLoop,chartListName);

                fwrite(this.FID,"% Search each chart for Stateflow states"+newline);
                fprintf(this.FID,"rptAllStates = [];\n");
                fprintf(this.FID,"rptNStateLoopCharts = numel(rptStateLoopChartList);\n");
                fprintf(this.FID,"for rptIStateLoopCharts = 1:rptNStateLoopCharts\n");


                constructorInput="rptStateLoopChartList(rptIStateLoopCharts).Object";
                writeFinderCode(this,constructorInput,types)

                fprintf(this.FID,"rptAllStates = [rptAllStates, rptStateList%s]; %%#ok<AGROW> \n",this.LoopVariableSuffix);
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"rptStateList%s = rptAllStates;\n",this.LoopVariableSuffix);
            end
            fprintf(this.FID,"\n");
        end

        function writeFinderCode(this,constructorInput,types)

            fprintf(this.FID,"%% Create a finder to find Stateflow states\n");
            fprintf(this.FID,"rptStateFinder = StateflowDiagramElementFinder(%s);\n",constructorInput);

            fprintf(this.FID,"%% Set finder options\n");
            nTypes=numel(types);
            fprintf(this.FID,"rptStateFinder.Types = [");
            for idx=1:nTypes-1
                fprintf(this.FID,"""%s"", ...\n",types(idx));
            end
            fprintf(this.FID,"""%s""];\n",types(end));
            if strcmp(this.Component.Depth,"local")
                fprintf(this.FID,"rptStateFinder.SearchDepth = 1;\n");
            end

            fprintf(this.FID,"rptStateList%s = find(rptStateFinder);\n\n",this.LoopVariableSuffix);



        end

        function types=getTypes(this)
            cmpn=this.Component;
            types=[];
            if cmpn.isAndOrStates
                types="Stateflow.State";
            end
            if cmpn.isBoxStates
                types=[types,"Stateflow.Box"];
            end
            if cmpn.isFcnStates
                types=[types,"Stateflow.Function"];
            end
            if cmpn.isTruthTables
                types=[types,"Stateflow.TruthTable"];
            end
            if cmpn.isEMFunctions
                types=[types,"Stateflow.EMFunction"];
            end
            if cmpn.isSLFunctions
                types=[types,"Stateflow.SLFunction"];
            end
        end

        function writeSFFilterStates(this)

            searchArgs=washSearchTerms(this.Component.SFFilterTerms(:)');

            fwrite(this.FID,"% Filter states based on specified Stateflow properties"+newline);

            fprintf(this.FID,"if ~isempty(rptStateList%s)\n",this.LoopVariableSuffix);
            fprintf(this.FID,"rptStateListObjects = [rptStateList%s.Object];\n",...
            this.LoopVariableSuffix);
            fprintf(this.FID,"rptStateListFiltered = find(rptStateListObjects, ...\n");
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
            fprintf(this.FID,"%% Find indices of states that were not filtered\n");
            fprintf(this.FID,"rptStateListIdx = ismember(rptStateListObjects,rptStateListFiltered);\n");
            fprintf(this.FID,"rptStateList%s = rptStateList%s(rptStateListIdx);\n\n",...
            this.LoopVariableSuffix,this.LoopVariableSuffix);
            fwrite(this.FID,"end"+newline+newline);
        end

        function name=getVariableName(~)
            name=[];
        end

    end


    methods(Access=protected)

        function writeSectionTitleCode(this,titleVarName,~)
            fprintf(this.FID,"rptStateName = %s.CurrentState.Name;\n",this.RptStateVariable);
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf(""State - %s"",rptStateName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptStateName;"+newline);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = getReporterLinkTargetID(%s.CurrentState);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % state loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sf_csf_state_loop
            templateFolder=fullfile(rptgen_sf_csf_state_loop.getClassFolder,...
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