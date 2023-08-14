classdef rptgen_sl_csl_ws_var_loop<mlreportgen.rpt2api.LoopComponentConverter



























    properties(Access=public)
        Context="";
    end

    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_blk_loop",...
        "csl_ws_var_loop"];

        SkippedContexts=["rptgen_sl.CAnnotationLoop",...
        "rptgen_sl.csl_sig_loop"]
    end

    methods

        function this=rptgen_sl_csl_ws_var_loop(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

        function writeVariableList(this,listVarName,useFilterProps)
            switch this.Context
            case "rptgen_sl.csl_mdl_loop"
                fwrite(this.FID,"% Report workspace variables used by the current model"+newline+newline);


                fwrite(this.FID,"% Create a finder to find variables used by the model"+newline);
                fprintf(this.FID,"rptVariableFinder = ModelVariableFinder(%s.CurrentModelHandle);\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder options"+newline);
                fwrite(this.FID,"if ~rptObj.CompileModelBeforeReporting"+newline);
                fwrite(this.FID,"rptVariableFinder.SearchMethod = ""cached"";"+newline);
                fwrite(this.FID,"end"+newline);
                fprintf(this.FID,"rptVariableFinder.LookUnderMasks = %s.CurrentModelOptions.IncludeMaskedSubsystems;\n",this.RptStateVariable);
                fprintf(this.FID,"rptVariableFinder.FollowLibraryLinks = %s.CurrentModelOptions.IncludeUserLibraryLinks;\n",this.RptStateVariable);
                fwrite(this.FID,"rptVariableFinder.SearchReferencedModels = false; % Reference models are already found by model loop"+newline);
                fprintf(this.FID,"rptVariableFinder.IncludeInactiveVariants = %s.CurrentModelOptions.IncludeVariants;\n\n",...
                this.RptStateVariable);


                if useFilterProps
                    writeFilterProperties(this);
                end


                fprintf(this.FID,"if %s.CurrentModelOptions.ReportStartingSystemOnly\n",this.RptStateVariable);
                fwrite(this.FID,"% Find only variables used by the top level model"+newline);
                fwrite(this.FID,"% This pattern matches only block paths of direct children of the model"+newline);
                fprintf(this.FID,"rptVariableUsersPattern = getfullname(%s.CurrentModelHandle)+ ""/[/]?[^/]*$"";\n",this.RptStateVariable);
                fprintf(this.FID,"rptVariableFinder.Users = rptVariableUsersPattern;\n");
                fwrite(this.FID,"rptVariableFinder.Regexp = true;"+newline);
                fwrite(this.FID,"end"+newline+newline);


                fwrite(this.FID,"% Find variables used by the model"+newline);
                fprintf(this.FID,"%s = find(rptVariableFinder);\n\n",...
                listVarName);

            case "rptgen_sl.csl_sys_loop"

                fwrite(this.FID,"% Create a finder to find workspace variables used by the current system"+newline);

                fprintf(this.FID,"rptVariableFinder = ModelVariableFinder(bdroot(%s.CurrentSystem.Object));\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder options"+newline);
                fprintf(this.FID,"rptVariableFinder.IncludeInactiveVariants = true;\n");
                fwrite(this.FID,"if ~rptObj.CompileModelBeforeReporting"+newline);
                fwrite(this.FID,"rptVariableFinder.SearchMethod = ""cached"";"+newline);
                fwrite(this.FID,"end"+newline);
                fwrite(this.FID,"rptVariableFinder.Regexp = true;"+newline);
                fwrite(this.FID,"% This pattern matches only block paths of direct children of the current system"+newline);
                fprintf(this.FID,"rptVariableUsersPattern = getfullname(%s.CurrentSystem.Object) + ""/[/]?[^/]*$"";\n",this.RptStateVariable);
                fprintf(this.FID,"rptVariableFinder.Users = rptVariableUsersPattern;\n\n");

                if useFilterProps
                    writeFilterProperties(this);
                end

                fprintf(this.FID,"%s = find(rptVariableFinder);\n\n",listVarName);

            case "rptgen_sl.csl_blk_loop"


                fwrite(this.FID,"% Create a finder to find workspace variables used by the current block"+newline);

                fprintf(this.FID,"rptVariableFinder = ModelVariableFinder(bdroot(%s.CurrentBlock.Object));\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder options"+newline);
                fprintf(this.FID,"rptVariableFinder.IncludeInactiveVariants = true;\n");
                fwrite(this.FID,"if ~rptObj.CompileModelBeforeReporting"+newline);
                fwrite(this.FID,"rptVariableFinder.SearchMethod = ""cached"";"+newline);
                fwrite(this.FID,"end"+newline);
                fwrite(this.FID,"% Find only variables used by the current block"+newline);
                fprintf(this.FID,"rptVariableFinder.Users = %s.CurrentBlock.BlockPath;\n",this.RptStateVariable);

                if useFilterProps
                    writeFilterProperties(this);
                end

                fprintf(this.FID,"%s = find(rptVariableFinder);\n\n",listVarName);

            case "rptgen_sl.csl_ws_var_loop"
                fwrite(this.FID,"% Report the current workspace variable"+newline);
                fprintf(this.FID,"%s = rptState.CurrentModelVariable;\n\n",listVarName);
            otherwise

                fwrite(this.FID,"% Report on all workspace variables used by all open models"+newline);
                fprintf(this.FID,"%s = [];\n",listVarName);
                fwrite(this.FID,"% Find all open models"+newline);
                fwrite(this.FID,"rptVariableLoopModelList = find_system( ..."+newline);
                fwrite(this.FID,"SearchDepth=0, ..."+newline);
                fwrite(this.FID,"type=""block_diagram"", ..."+newline);
                fwrite(this.FID,"BlockDiagramType=""model"");"+newline+newline);
                fwrite(this.FID,"% Create a variable finder to find variables used by each model"+newline);
                fprintf(this.FID,"rptVariableFinder = ModelVariableFinder(gcs);\n");
                fwrite(this.FID,"% Set finder options"+newline);
                fprintf(this.FID,"rptVariableFinder.IncludeInactiveVariants = true;\n");
                fwrite(this.FID,"if ~rptObj.CompileModelBeforeReporting"+newline);
                fwrite(this.FID,"rptVariableFinder.SearchMethod = ""cached"";"+newline);
                fwrite(this.FID,"end"+newline);

                if useFilterProps
                    writeFilterProperties(this);
                end

                fwrite(this.FID,"% Loop through open models"+newline);
                fwrite(this.FID,"rptN = numel(rptVariableLoopModelList);"+newline);
                fwrite(this.FID,"for rptI = 1:rptN"+newline);
                fprintf(this.FID,"rptVariableFinder.Container = rptVariableLoopModelList{rptI};\n");
                fprintf(this.FID,"%s = [%s, find(rptVariableFinder)]; %%#ok<AGROW> \n",...
                listVarName,listVarName);

                fwrite(this.FID,"end"+newline+newline);
            end
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sl_csl_ws_var_loop



            this.Context=getContext(this,[this.SupportedContexts,this.SkippedContexts]);
            if ismember(this.Context,this.SkippedContexts)
                fprintf(this.FID,"% Simulink Workspace Variable loop with %s parent skipped.\n\n",this.Context);
                return
            end

            writeStartBanner(this);
            writeSaveState(this);


            suffix=this.LoopVariableSuffix;

            useFilterProps=this.Component.isFilterList...
            &&~isempty(this.Component.FilterTerms);
            writeVariableList(this,"rptModelVariableList"+suffix,useFilterProps);


            fprintf(this.FID,"if ~isempty(rptModelVariableList%s)\n",suffix);
            if strcmp(this.Component.SortBy,"alpha")
                fwrite(this.FID,"% Sort variables alphabetically"+newline);
                fprintf(this.FID,"rptVariableNames = [rptModelVariableList%s.Name];\n",suffix);
                fwrite(this.FID,"[~,rptSortIdx] = sort(rptVariableNames);"+newline);
                fprintf(this.FID,"rptModelVariableList%s = rptModelVariableList%s(rptSortIdx);\n",suffix,suffix);
            else

                fwrite(this.FID,"% Sort variables by data type"+newline);
                fprintf(this.FID,"rptVariableTypes = arrayfun(@(x)getPropertyValues(x,""Class"",ReturnType=""string""),rptModelVariableList%s);\n",suffix);
                fwrite(this.FID,"[~,rptSortIdx] = sort([rptVariableTypes{:}]);"+newline);
                fprintf(this.FID,"rptModelVariableList%s = rptModelVariableList%s(rptSortIdx);\n",suffix,suffix);
            end
            fprintf(this.FID,"end\n\n");

            fwrite(this.FID,"% Loop through list of variables to be reported"+newline);
            fprintf(this.FID,"rptNModelVariables%s = numel(rptModelVariableList%s);\n",suffix,suffix);
            fprintf(this.FID,"for rptIModelVariable%s = 1:rptNModelVariables%s\n",suffix,suffix);
            fprintf(this.FID,"%s.CurrentModelVariable = rptModelVariableList%s(rptIModelVariable%s);\n\n",...
            this.RptStateVariable,suffix,suffix);

            writeObjectSectionCode(this);
        end

        function writeFilterProperties(this)




            fwrite(this.FID,"% Filter variables based on specified properties"+newline);
            fwrite(this.FID,"rptVariableFinder.Regexp = true;"+newline);

            searchArgs=washSearchTerms(this.Component.FilterTerms(:)');
            nTerms=numel(searchArgs);
            otherProps=[];
            for k=1:2:nTerms
                prop=searchArgs{k};
                switch lower(prop)
                case "name"
                    fprintf(this.FID,"rptVariableFinder.Name = ""%s"";\n",searchArgs{k+1});
                case "users"
                    fprintf(this.FID,"rptVariableFinder.Users = ""%s"";\n",searchArgs{k+1});
                case "sourcetype"
                    fprintf(this.FID,"rptVariableFinder.SourceType = ""%s"";\n",searchArgs{k+1});
                otherwise
                    otherProps=[otherProps,sprintf("""%s"",""%s"", ...\n",searchArgs{k},searchArgs{k+1})];%#ok<AGROW>
                end
            end

            if~isempty(otherProps)
                fwrite(this.FID,"rptVariableFinder.Properties = {..."+newline);
                fprintf(this.FID,"%s",strjoin(otherProps));
                fwrite(this.FID,"}; %#ok<CLARRSTR> "+newline+newline);
            end
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
            fprintf(this.FID,"rptVariableName = %s.CurrentModelVariable.Name;\n",this.RptStateVariable);
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf(""Variable - %s"",rptVariableName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptVariableName;"+newline);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = getReporterLinkTargetID(%s.CurrentModelVariable);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % variable loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_ws_var_loop
            templateFolder=fullfile(rptgen_sl_csl_ws_var_loop.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
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