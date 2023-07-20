classdef rptgen_sf_csf_obj_loop<mlreportgen.rpt2api.LoopComponentConverter



























    properties(Access=private)
        Context="";
    end

    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_blk_loop",...
        "csf_obj_loop",...
        "csf_machine_loop",...
        "csf_chart_loop",...
        "csf_state_loop",...
        ];

        SkippedContexts=["rptgen_sl.csl_sig_loop",...
        "rptgen_sl.CAnnotationLoop"]
    end

    methods

        function this=rptgen_sf_csf_obj_loop(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sf_csf_obj_loop

            this.Context=getContext(this,[this.SupportedContexts,this.SkippedContexts]);
            if ismember(this.Context,this.SkippedContexts)
                fprintf(this.FID,"% Object loop with %s parent skipped.\n\n",this.Context);
                return
            end

            writeStartBanner(this);
            writeSaveState(this);


            suffix=this.LoopVariableSuffix;

            writeObjectList(this);





            if this.Component.isSFFilterList&&~isempty(this.Component.SFFilterTerms)
                writeSFFilterObjects(this);
            end


            fprintf(this.FID,"if ~isempty(rptStateflowObjectList%s)\n",this.LoopVariableSuffix);
            fprintf(this.FID,"%% Sort objects by name\n");
            fprintf(this.FID,"rptStateflowObjectNames = lower([rptStateflowObjectList%s.Name]);\n",this.LoopVariableSuffix);
            fprintf(this.FID,"[~,rptSortIdx] = sort(rptStateflowObjectNames);\n");
            fprintf(this.FID,"rptStateflowObjectList%s = rptStateflowObjectList%s(rptSortIdx);\n",...
            this.LoopVariableSuffix,this.LoopVariableSuffix);
            fprintf(this.FID,"end\n\n");

            fwrite(this.FID,"% Loop through list of objects to be reported."+newline);
            fprintf(this.FID,"rptNStateflowObjects%s = numel(rptStateflowObjectList%s);\n",suffix,suffix);
            fprintf(this.FID,"for rptIStateflowObject%s = 1:rptNStateflowObjects%s\n",suffix,suffix);
            fprintf(this.FID,"%s.CurrentStateflowObject = rptStateflowObjectList%s(rptIStateflowObject%s);\n",...
            this.RptStateVariable,suffix,suffix);

            writeObjectSectionCode(this);
        end

        function writeObjectList(this)
            ctx=this.Context;

            types=getTypes(this);

            unsupportedIdx=ismember(types,["data","event","target"]);
            if any(unsupportedIdx)
                fprintf(this.FID,"%% Finding Stateflow data, event, and target objects is not supported\n");
                types(unsupportedIdx)=[];
            end
            if isempty(types)
                fprintf(this.FID,"%% No supported object types are specified, so no objects will be reported\n");
                fprintf(this.FID,"rptStateflowObjectList%s = [];\n",this.LoopVariableSuffix);
                return
            end


            switch ctx
            case "rptgen_sl.csl_mdl_loop"
                fwrite(this.FID,"% Create a finder to find charts in the current model"+newline);
                fprintf(this.FID,"rptChartFinder = ChartDiagramFinder(%s.CurrentModelHandle);\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder options"+newline);
                fprintf(this.FID,"%% Searching reference models is redundant because they are already searched by model loop\n");
                fwrite(this.FID,"rptChartFinder.IncludeReferencedModels = false;"+newline);
                fwrite(this.FID,"% Find charts in the model and search each for Stateflow objects"+newline);
                fprintf(this.FID,"rptAllSFObjects = [];\n");
                fprintf(this.FID,"rptSFObjectChartList = find(rptChartFinder);\n");
                fprintf(this.FID,"rptNSFObjectCharts = numel(rptSFObjectChartList);\n");
                fprintf(this.FID,"for rptISFObjectCharts = 1:rptNSFObjectCharts\n");



                constructorInput="rptSFObjectChartList(rptISFObjectCharts)";
                commentObjectType="current chart";
                writeFinderCode(this,commentObjectType,constructorInput,types)

                fprintf(this.FID,"rptAllSFObjects = [rptAllSFObjects, rptStateflowObjectList%s]; %%#ok<AGROW> \n",this.LoopVariableSuffix);
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"rptStateflowObjectList%s = rptAllSFObjects;\n",this.LoopVariableSuffix);

            case "rptgen_sl.csl_sys_loop"
                fwrite(this.FID,"% Create a finder to find charts in the current system"+newline);
                fprintf(this.FID,"rptChartFinder = ChartDiagramFinder(%s.CurrentSystem.Object);\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder options"+newline);
                fprintf(this.FID,"%% Searching reference models is redundant because they are already searched by system loop\n");
                fwrite(this.FID,"rptChartFinder.IncludeReferencedModels = false;"+newline);
                fwrite(this.FID,"% Find charts in the system and search each for Stateflow objects"+newline);
                fprintf(this.FID,"rptAllSFObjects = [];\n");
                fprintf(this.FID,"rptSFObjectChartList = find(rptChartFinder);\n");
                fprintf(this.FID,"rptNSFObjectCharts = numel(rptSFObjectChartList);\n");
                fprintf(this.FID,"for rptISFObjectCharts = 1:rptNSFObjectCharts\n");



                constructorInput="rptSFObjectChartList(rptISFObjectCharts)";
                commentObjectType="current chart";
                writeFinderCode(this,commentObjectType,constructorInput,types)

                fprintf(this.FID,"rptAllSFObjects = [rptAllSFObjects, rptStateflowObjectList%s]; %%#ok<AGROW> \n",this.LoopVariableSuffix);
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"rptStateflowObjectList%s = rptAllSFObjects;\n",this.LoopVariableSuffix);

            case "rptgen_sl.csl_blk_loop"
                constructorInput=this.RptStateVariable+".CurrentBlock.Object";
                commentObjectType="current block";
                writeFinderCode(this,commentObjectType,constructorInput,types)

            case "rptgen_sf.csf_machine_loop"


            case "rptgen_sf.csf_chart_loop"
                constructorInput=this.RptStateVariable+".CurrentChart.Object";
                commentObjectType="current chart";
                writeFinderCode(this,commentObjectType,constructorInput,types)

            case "rptgen_sf.csf_state_loop"
                fprintf(this.FID,"rptStateflowObjectList%s = [];\n",...
                this.LoopVariableSuffix);


            case "rptgen_sf.csf_obj_loop"
                fprintf(this.FID,"%% Use the current object\n");
                fprintf(this.FID,"rptStateflowObjectList%s = %s.CurrentStateflowObject;\n",...
                this.LoopVariableSuffix,this.RptStateVariable);

            otherwise


                fwrite(this.FID,"% Find charts in all open models"+newline);
                fprintf(this.FID,"rptSFObjectChartList = find(slroot,""-isa"",""Stateflow.Chart"");\n");
                fwrite(this.FID,"% Search each chart for Stateflow objects"+newline);
                fprintf(this.FID,"rptAllSFObjects = [];\n");
                fprintf(this.FID,"rptNSFObjectCharts = numel(rptSFObjectChartList);\n");
                fprintf(this.FID,"for rptISFObjectCharts = 1:rptNSFObjectCharts\n");



                constructorInput="rptSFObjectChartList(rptISFObjectCharts)";
                commentObjectType="current chart";
                writeFinderCode(this,commentObjectType,constructorInput,types)

                fprintf(this.FID,"rptAllSFObjects = [rptAllSFObjects, rptStateflowObjectList%s]; %%#ok<AGROW> \n",this.LoopVariableSuffix);
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"rptStateflowObjectList%s = rptAllSFObjects;\n",this.LoopVariableSuffix);
            end


            fprintf(this.FID,"\n");
        end

        function writeFinderCode(this,commentObjectType,constructorInput,types)

            fprintf(this.FID,"%% Find Stateflow objects in %s\n",commentObjectType);
            fprintf(this.FID,"rptObjectFinder = StateflowDiagramElementFinder(%s);\n",constructorInput);
            fprintf(this.FID,"%% Set finder options\n");

            nTypes=numel(types);
            fprintf(this.FID,"rptObjectFinder.Types = [");
            for idx=1:nTypes-1
                fprintf(this.FID,"""%s"", ...\n",types(idx));
            end
            fprintf(this.FID,"""%s""];\n",types(end));
            if strcmp(this.Component.Depth,"local")
                fprintf(this.FID,"rptObjectFinder.SearchDepth = 1;\n");
            else
                fprintf(this.FID,"rptObjectFinder.SearchDepth = Inf;\n");
            end
            fprintf(this.FID,"rptStateflowObjectList%s = find(rptObjectFinder);\n\n",this.LoopVariableSuffix);




            if this.Component.RemoveRedundant
                fprintf(this.FID,"%% Remove objects that only contain information that can be captured in a snapshot\n");
                fprintf(this.FID,"rptTypesToCheck = strcat(""Stateflow."",[""Transition"",""Junction"",""Note"",""Annotation"",""Port""]);\n");
                fprintf(this.FID,"rptN = numel(rptStateflowObjectList%s);\n",this.LoopVariableSuffix);
                fprintf(this.FID,"rptToRemoveIdx = false(1,rptN);\n");
                fprintf(this.FID,"for rptI = 1:rptN\n");
                fprintf(this.FID,"rptCurrentSFObject = rptStateflowObjectList%s(rptI);\n",this.LoopVariableSuffix);
                fprintf(this.FID,"if ismember(rptCurrentSFObject.Type,rptTypesToCheck)\n");
                fprintf(this.FID,"rptToRemoveIdx(rptI) = isempty(rptCurrentSFObject.Object.Description) ...\n");
                fprintf(this.FID,"&& isempty(rptCurrentSFObject.Object.Document);\n");
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"rptStateflowObjectList%s(rptToRemoveIdx) = [];\n",this.LoopVariableSuffix);
            end
        end

        function types=getTypes(this)
            cmpn=this.Component;
            types=[];
            if cmpn.isReportData
                types="data";
            end
            if cmpn.isReportEvent
                types=[types,"event"];
            end
            if cmpn.isReportTransition
                types=[types,"transition"];
            end
            if cmpn.isReportJunction
                types=[types,"junction"];
            end
            if cmpn.isReportTarget
                types=[types,"target"];
            end
            if cmpn.isReportAnnotation
                types=[types,"annotation"];
            end
            if cmpn.isReportPort
                types=[types,"port"];
            end
        end

        function writeSFFilterObjects(this)

            searchArgs=washSearchTerms(this.Component.SFFilterTerms(:)');

            fwrite(this.FID,"% Filter objects based on specified Stateflow properties"+newline);
            fprintf(this.FID,"if ~isempty(rptStateflowObjectList%s)\n",this.LoopVariableSuffix);
            fprintf(this.FID,"rptStateflowResultObjects = [rptStateflowObjectList%s.Object];\n",this.LoopVariableSuffix);
            fprintf(this.FID,"rptStateflowResultObjectsFiltered = find(rptStateflowResultObjects, ...\n");
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
            fprintf(this.FID,"%% Find indices of objects that were not filtered\n");
            fprintf(this.FID,"rptSFObjectListIdx = ismember(rptStateflowResultObjects,rptStateflowResultObjectsFiltered);\n");
            fprintf(this.FID,"rptStateflowObjectList%s = rptStateflowObjectList%s(rptSFObjectListIdx);\n\n",...
            this.LoopVariableSuffix,this.LoopVariableSuffix);
            fwrite(this.FID,"end"+newline+newline);
        end

        function convertComponentChildren(this)


            if~ismember(this.Context,this.SkippedContexts)
                convertComponentChildren@mlreportgen.rpt2api.LoopComponentConverter(this);
            end
        end

        function name=getVariableName(~)
            name=[];
        end

    end


    methods(Access=protected)

        function writeSectionTitleCode(this,titleVarName,~)
            fprintf(this.FID,"rptSFObjectName = %s.CurrentStateflowObject.Name;\n",this.RptStateVariable);
            fprintf(this.FID,"rptSFObjectType = extractAfter(%s.CurrentStateflowObject.Type,""Stateflow."");\n",this.RptStateVariable);
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf(""%s - %s"", rptSFObjectType, rptSFObjectName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptSFObjectName;"+newline);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = getReporterLinkTargetID(%s.CurrentStateflowObject);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % object loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sf_csf_obj_loop
            templateFolder=fullfile(rptgen_sf_csf_obj_loop.getClassFolder,...
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