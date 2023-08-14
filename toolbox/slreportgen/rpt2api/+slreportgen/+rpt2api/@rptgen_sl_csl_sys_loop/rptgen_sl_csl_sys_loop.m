classdef rptgen_sl_csl_sys_loop<mlreportgen.rpt2api.LoopComponentConverter



























    properties(Access=private)
        Context="";
    end

    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_sig_loop",...
        "csl_blk_loop",...
        "CAnnotationLoop"];
    end

    methods

        function this=rptgen_sl_csl_sys_loop(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sl_csl_sys_loop

            writeStartBanner(this);
            writeSaveState(this);


            suffix=this.LoopVariableSuffix;

            if strcmp(this.Component.LoopType,"auto")
                writeAutomaticSystemList(this);
            else
                writeCustomSystemList(this);
            end


            if this.Component.isFilterList&&~isempty(this.Component.FilterTerms)
                writeFilterSystems(this);
            end


            if~this.Component.IncludeSlFunctions
                writeRemoveSLFunctionSubsystems(this);
            end


            sortBy=this.Component.SortBy;
            if~strcmp(sortBy,"none")
                fwrite(this.FID,"% Sort reported systems."+newline);
                fprintf(this.FID,"rptSystemList%s = sortSystems(rptSystemList%s,""%s"");\n\n",...
                suffix,suffix,sortBy);
            end

            fwrite(this.FID,"% Loop through list of systems to be reported."+newline);
            fprintf(this.FID,"rptNSystems%s = numel(rptSystemList%s);\n",suffix,suffix);
            fprintf(this.FID,"for rptISystem%s = 1:rptNSystems%s\n",suffix,suffix);
            fprintf(this.FID,"%s.CurrentSystem = rptSystemList%s(rptISystem%s);\n",...
            this.RptStateVariable,suffix,suffix);
            fprintf(this.FID,"set_param(0,""CurrentSystem"",%s.CurrentSystem.Object);\n\n",this.RptStateVariable);

            writeObjectSectionCode(this);
        end

        function writeCustomSystemList(this)
            import mlreportgen.rpt2api.exprstr.Parser


            fwrite(this.FID,"% Loop on the specified systems."+newline);
            objList=this.Component.ObjectList;
            nObj=numel(objList);
            if nObj>0
                fprintf(this.FID,"rptSystemList%s = [ ...\n",this.LoopVariableSuffix);

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
            end
            fwrite(this.FID,"];"+newline+newline);
        end

        function writeAutomaticSystemList(this)

            systemListVar="rptSystemList"+this.LoopVariableSuffix;

            ctx=getContext(this,this.SupportedContexts);

            switch ctx
            case "rptgen_sl.csl_mdl_loop"
                fprintf(this.FID,"rptSystemList%s = %s.CurrentModelReportedSystems;\n",...
                this.LoopVariableSuffix,this.RptStateVariable);

            case "rptgen_sl.csl_sys_loop"

                fwrite(this.FID,"% Report on the current system from the parent system loop."+newline);
                fprintf(this.FID,systemListVar+" = %s.CurrentSystem;\n\n",this.RptStateVariable);

            case "rptgen_sl.csl_blk_loop"

                fwrite(this.FID,"% Report on the parent system of the current block."+newline);
                fprintf(this.FID,systemListVar+" = DiagramResult(%s.CurrentBlock.DiagramPath);\n\n",this.RptStateVariable);

            case "rptgen_sl.csl_sig_loop"

                fwrite(this.FID,"% Report on the parent system of the current signal."+newline);
                fprintf(this.FID,"if isValidSlSystem(%s.CurrentSignal.SourceBlock)\n",this.RptStateVariable);
                fprintf(this.FID,systemListVar+" = DiagramResult(%s.CurrentSignal.SourceBlock);\n",this.RptStateVariable);
                fwrite(this.FID,"else"+newline);
                fprintf(this.FID,systemListVar+" = DiagramResult(get_param(%s.CurrentSignal.SourceBlock,""Parent""));\n",this.RptStateVariable);
                fwrite(this.FID,"end"+newline);

            case "rptgen_sl.CAnnotationLoop"

                fwrite(this.FID,"% Report on the parent system of the current annotation."+newline);
                fprintf(this.FID,systemListVar+" = DiagramResult(%s.CurrentAnnotation.DiagramPath);\n\n",this.RptStateVariable);

            otherwise

                fwrite(this.FID,"% Report on all systems in all open models."+newline);
                fprintf(this.FID,"rptSystemList%s = [];\n",this.LoopVariableSuffix);
                fwrite(this.FID,"% Find all open models."+newline);
                fwrite(this.FID,"rptSystemLoopModelList = find_system( ..."+newline);
                fwrite(this.FID,"SearchDepth=0, ..."+newline);
                fwrite(this.FID,"type=""block_diagram"", ..."+newline);
                fwrite(this.FID,"BlockDiagramType=""model"");"+newline+newline);
                fwrite(this.FID,"% Loop through open models."+newline);
                fwrite(this.FID,"rptN = numel(rptSystemLoopModelList);"+newline);
                fwrite(this.FID,"for rptI = 1:rptN"+newline);
                fwrite(this.FID,"% Create a system finder."+newline);
                fwrite(this.FID,"rptSystemFinder = SystemDiagramFinder(rptSystemLoopModelList{rptI});"+newline);
                fwrite(this.FID,"rptSystemFinder.IncludeReferencedModels = false;"+newline);
                fwrite(this.FID,"% Get finder results and add them to the system list."+newline);
                fwrite(this.FID,"rptSystemResults = find(rptSystemFinder);"+newline);
                fprintf(this.FID,"rptSystemList%s = [rptSystemList%s, rptSystemResults]; %%#ok<AGROW> \n",...
                this.LoopVariableSuffix,this.LoopVariableSuffix);
                fwrite(this.FID,"end"+newline+newline);

            end
        end

        function writeFilterSystems(this)

            searchArgs=washSearchTerms(this.Component.FilterTerms(:)');

            fwrite(this.FID,"% Filter systems based on specified properties."+newline);
            fprintf(this.FID,"rptSystemListObjects = [rptSystemList%s.Object];\n",...
            this.LoopVariableSuffix);
            fprintf(this.FID,"rptSystemListObjectsFiltered = find_system(rptSystemListObjects, ...\n");
            fwrite(this.FID,"SearchDepth=0, ..."+newline);
            fwrite(this.FID,"Regexp=""on""");

            nTerms=numel(searchArgs);
            for k=1:2:nTerms
                fprintf(this.FID,", ...\n%s=""%s""",searchArgs{k},searchArgs{k+1});
            end
            fwrite(this.FID,");"+newline);
            fprintf(this.FID,"%% Find indices of systems that were not filtered\n");
            fprintf(this.FID,"rptSystemListIdx = ismember(rptSystemListObjects,rptSystemListObjectsFiltered);\n");
            fprintf(this.FID,"rptSystemList%s = rptSystemList%s(rptSystemListIdx);\n\n",...
            this.LoopVariableSuffix,this.LoopVariableSuffix);
        end

        function writeRemoveSLFunctionSubsystems(this)

            fwrite(this.FID,"% Remove subsystems that are in Simulink functions."+newline);
            fprintf(this.FID,"rptN = numel(rptSystemList%s);\n",this.LoopVariableSuffix);
            fwrite(this.FID,"rptIsSlFunction = false(1,rptN);"+newline);
            fwrite(this.FID,"for rptI = 1:rptN"+newline);
            fwrite(this.FID,"rptCurrentSys = rptSystemList(rptI).Object;"+newline);
            fwrite(this.FID,"% Check this system and its containing systems to see if any are Simulink functions."+newline);
            fwrite(this.FID,"while ~isModel(rptCurrentSys)"+newline);
            fwrite(this.FID,"if isSimulinkFunction(rptCurrentSys)"+newline);
            fwrite(this.FID,"rptIsSlFunction(rptI) = true;"+newline);
            fwrite(this.FID,"break;"+newline);
            fwrite(this.FID,"end"+newline);
            fwrite(this.FID,"rptCurrentSys = get_param(rptCurrentSys,""Parent"");"+newline);
            fwrite(this.FID,"end"+newline);
            fwrite(this.FID,"end"+newline);
            fprintf(this.FID,"rptSystemList%s = rptSystemList%s(~rptIsSlFunction);\n\n",...
            this.LoopVariableSuffix,this.LoopVariableSuffix);
        end

        function name=getVariableName(~)
            name=[];
        end

    end


    methods(Access=protected)

        function writeSectionTitleCode(this,titleVarName,sectVariableName)
            fprintf(this.FID,"rptSystemName = %s.CurrentSystem.Name;\n",this.RptStateVariable);
            fwrite(this.FID,"rptSystemName = normalizeString(rptSystemName);"+newline);
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf(""System - %s"",rptSystemName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptSystemName;"+newline);
            end

            if this.Component.HierarchicalSectionNumbering
                fwrite(this.FID,"% Add system hierarchy number to section title."+newline);
                fprintf(this.FID,"%s.Numbered = false;\n",sectVariableName);
                fprintf(this.FID,"rptHierarchyNumber = HierarchyNumber(%s.CurrentModelHandle);\n",this.RptStateVariable);
                fprintf(this.FID,"%s = generateHierarchyNumber(rptHierarchyNumber,%s.CurrentSystem.Object) + ...\n",titleVarName,this.RptStateVariable);
                fprintf(this.FID,""" "" + %s;\n",titleVarName);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = getReporterLinkTargetID(%s.CurrentSystem);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % system loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_sys_loop
            templateFolder=fullfile(rptgen_sl_csl_sys_loop.getClassFolder,...
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