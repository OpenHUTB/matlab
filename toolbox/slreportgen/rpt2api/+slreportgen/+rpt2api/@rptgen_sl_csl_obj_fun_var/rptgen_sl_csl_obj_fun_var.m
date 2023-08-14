classdef rptgen_sl_csl_obj_fun_var<mlreportgen.rpt2api.ComponentConverter




























    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_blk_loop",...
        "csl_sig_loop"];

        SkippedContexts=["rptgen_sl.CAnnotationLoop",...
        "rptgen_sl.csl_ws_var_loop"]
    end

    methods

        function obj=rptgen_sl_csl_obj_fun_var(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            context=getContext(this,[this.SupportedContexts,this.SkippedContexts]);
            if ismember(context,this.SkippedContexts)
                fprintf(this.FID,"% Simulink Functions and Variables with %s parent skipped.\n\n",context);
                return
            end

            writeStartBanner(this);

            if this.Component.isVariableTable
                writeVariableTable(this,context);
            end

            if this.Component.isFunctionTable
                writeFunctionTable(this,context)
            end

            writeEndBanner(this);
        end

        function writeVariableTable(this,context)
            import mlreportgen.rpt2api.exprstr.Parser

            varName=strcat(getVariableName(this),"_Variables");
            cmpn=this.Component;


            varListName="rptVariableResults";
            if strcmp(context,"rptgen_sl.csl_sig_loop")
                fprintf(this.FID,"%% Find variables used by blocks connected to the current signal\n");
                fprintf(this.FID,"%s = [];\n",varListName);
                fprintf(this.FID,"rptFcnVarBlockFinder = BlockFinder(...\n");
                fprintf(this.FID,"Container=get_param(%s.CurrentSignal.SourceBlock,""Parent""), ...\n",this.RptStateVariable);
                fprintf(this.FID,"ConnectedSignal=%s.CurrentSignal);\n",this.RptStateVariable);
                fprintf(this.FID,"rptFcnVarBlockResults = find(rptFcnVarBlockFinder);\n");
                fprintf(this.FID,"rptFcnVarNBlocks = numel(rptFcnVarBlockResults);\n");
                fprintf(this.FID,"for rptI = 1:rptFcnVarNBlocks\n");
                fprintf(this.FID,"%% Find variables used by the current block\n");
                fprintf(this.FID,"rptVarBlock = rptFcnVarBlockResults(rptI);\n");
                fprintf(this.FID,"rptVariableFinder = ModelVariableFinder(bdroot(rptVarBlock.Object));\n");
                fwrite(this.FID,"% Set finder options."+newline);
                fwrite(this.FID,"if ~rptObj.CompileModelBeforeReporting"+newline);
                fwrite(this.FID,"rptVariableFinder.SearchMethod = ""cached"";"+newline);
                fwrite(this.FID,"end"+newline);
                fwrite(this.FID,"% Find only variables used by the current block and its children"+newline);
                fprintf(this.FID,"rptVariableFinder.Users = rptVarBlock.BlockPath;\n");
                fprintf(this.FID,"rptVariableFinder.Regexp = true;\n");
                fprintf(this.FID,"%s = [%s, find(rptVariableFinder)]; %%#ok<AGROW>\n",...
                varListName,varListName);
                fprintf(this.FID,"end\n");
            else




                wsLoop=slreportgen.rpt2api.rptgen_sl_csl_ws_var_loop(this.Component,this.RptFileConverter);
                wsLoop.Context=context;
                writeVariableList(wsLoop,varListName,false);
            end

            if cmpn.isWorkspaceIO&&strcmp(context,"rptgen_sl.csl_mdl_loop")
                fprintf(this.FID,"%% Including workspace I/O parameters is not supported\n\n");
            end

            fprintf(this.FID,"%% Create a table to summarize variables\n");
            fprintf(this.FID,"if ~isempty(%s)\n",varListName);
            fprintf(this.FID,"%s = SummaryTable(%s);\n",varName,varListName);

            if~strcmp(cmpn.VariableTableTitleType,"auto")
                titleExpr=cmpn.VariableTableTitle;
                if regexp(titleExpr,'.*%<.+>')
                    p=Parser(titleExpr);
                    parse(p);
                    fprintf(this.FID,"%% Title converted from: %s\n",strrep(p.ExprStr,newline,'\n'));
                    fprintf(this.FID,"rptVariableTableTitle = "+p.FormatString+";\n",p.Expressions{:});
                else
                    fprintf(this.FID,"rptVariableTableTitle = ""%s"";\n",titleExpr);
                end
                fprintf(this.FID,"%s.Title = rptVariableTableTitle;\n\n",varName);
            end

            fprintf(this.FID,"%% Set variable properties to report\n");
            props="Name";
            if cmpn.VariableTableParentBlock
                props=[props,"Users"];
            end
            if cmpn.VariableTableCallingString
                props=[props,"Calling String"];
            end
            if cmpn.isShowVariableSize
                props=[props,"Size"];
            end
            if cmpn.isShowVariableMemory
                props=[props,"Bytes"];
            end
            if cmpn.isShowVariableClass
                props=[props,"Class"];
            end
            if cmpn.isShowVariableValue
                props=[props,"Value"];
            end
            if cmpn.isShowTunableProps
                props=[props,"Storage Class"];
            end

            if~isempty(cmpn.ParameterProps)
                props=[props,string(cmpn.ParameterProps')];
            end


            propsStr=strjoin(props,""", ..."+newline+"""");
            fprintf(this.FID,"%s.Properties = [""%s""];\n\n",...
            varName,propsStr);

            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n",parentName,varName);

            fprintf(this.FID,"end\n\n");
        end

        function writeFunctionTable(this,context)
            import mlreportgen.rpt2api.exprstr.Parser


            writeFunctionReferenceFinder(this,context)

            varName=strcat(getVariableName(this),"_Functions");
            fprintf(this.FID,"%% Create a table to summarize referenced functions\n");
            fprintf(this.FID,"if ~isempty(rptFunctionResults)\n");
            fprintf(this.FID,"%s = SummaryTable(rptFunctionResults);\n",varName);

            cmpn=this.Component;
            if~strcmp(cmpn.FunctionTableTitleType,"auto")
                titleExpr=cmpn.FunctionTableTitle;
                if regexp(titleExpr,'.*%<.+>')
                    p=Parser(titleExpr);
                    parse(p);
                    fprintf(this.FID,"%% Title converted from: %s\n",strrep(p.ExprStr,newline,'\n'));
                    fprintf(this.FID,"rptFunctionTableTitle = "+p.FormatString+";\n",p.Expressions{:});
                else
                    fprintf(this.FID,"rptFunctionTableTitle = ""%s"";\n",titleExpr);
                end
                fprintf(this.FID,"%s.Title = rptFunctionTableTitle;\n\n",varName);

            end

            fprintf(this.FID,"%% Set function properties to report\n");
            props="Function Name";
            if cmpn.FunctionTableParentBlock
                props=[props,"Calling Blocks"];
            end
            if cmpn.FunctionTableCallingString
                props=[props,"Calling Expressions"];
            end
            propsStr=strjoin(props,""", ..."+newline+"""");
            fprintf(this.FID,"%s.Properties = [""%s""];\n\n",...
            varName,propsStr);

            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n",parentName,varName);

            fprintf(this.FID,"end\n\n");
        end

        function writeFunctionReferenceFinder(this,context)
            switch context
            case "rptgen_sl.csl_mdl_loop"
                fprintf(this.FID,"%% Find functions used by blocks in the current model\n");
                fprintf(this.FID,"rptFunctionFinder = FunctionReferenceFinder(%s.CurrentModelHandle);\n",...
                this.RptStateVariable);
                fprintf(this.FID,"%% Set finder options\n");
                fprintf(this.FID,"rptFunctionFinder.SearchReferencedModels = false;\n");
                fprintf(this.FID,"rptFunctionFinder.LookUnderMasks = %s.CurrentModelOptions.IncludeMaskedSubsystems;\n",...
                this.RptStateVariable);
                fprintf(this.FID,"rptFunctionFinder.FollowLibraryLinks = %s.CurrentModelOptions.IncludeUserLibraryLinks;\n",...
                this.RptStateVariable);
                fprintf(this.FID,"rptFunctionFinder.IncludeInactiveVariants = %s.CurrentModelOptions.IncludeVariants;\n\n",...
                this.RptStateVariable);

                fprintf(this.FID,"rptFunctionResults = find(rptFunctionFinder);\n");

            case "rptgen_sl.csl_sys_loop"
                fprintf(this.FID,"%% Find functions used by blocks in the current system\n");
                fprintf(this.FID,"rptFunctionFinder = FunctionReferenceFinder(Container=%s.CurrentSystem, ...\n",...
                this.RptStateVariable);
                fprintf(this.FID,"SearchDepth=1);\n");
                fprintf(this.FID,"rptFunctionResults = find(rptFunctionFinder);\n\n");
            case "rptgen_sl.csl_blk_loop"
                fprintf(this.FID,"%% Find functions used by the current block\n");
                fprintf(this.FID,"rptFunctionFinder = FunctionReferenceFinder(Container=%s.CurrentBlock, ...\n",...
                this.RptStateVariable);
                fprintf(this.FID,"SearchDepth=0);\n");
                fprintf(this.FID,"rptFunctionResults = find(rptFunctionFinder);\n\n");
            case "rptgen_sl.csl_sig_loop"
                fprintf(this.FID,"%% Find functions used by blocks connected to the current signal\n");
                fprintf(this.FID,"rptFunctionResults = [];\n");
                if~this.Component.isVariableTable





                    fprintf(this.FID,"rptFcnVarBlockFinder = BlockFinder(%s.CurrentSignal);\n",this.RptStateVariable);
                    fprintf(this.FID,"rptFcnVarBlockResults = find(rptFcnVarBlockFinder);\n");
                    fprintf(this.FID,"rptFcnVarNBlocks = numel(rptFcnVarBlockResults);\n");
                end
                fprintf(this.FID,"for rptI = 1:rptFcnVarNBlocks\n");
                fprintf(this.FID,"%% Find functions used by the current block\n");
                fprintf(this.FID,"rptFunctionFinder = FunctionReferenceFinder(Container=rptFcnVarBlockResults(rptI), ...\n");
                fprintf(this.FID,"SearchDepth=0);\n");
                fprintf(this.FID,"rptFunctionResults = [rptFunctionResults, find(rptFunctionFinder)]; %%#ok<AGROW>\n");
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"rptFunctionResults = unique(rptFunctionResults);\n\n");
            otherwise
                fprintf(this.FID,"%% Find functions used by blocks in all open models\n");
                fprintf(this.FID,"rptFunctionResults = [];\n");
                fprintf(this.FID,"rptOpenModels = find_system(SearchDepth=0, ...\n"+...
                "Type=""block_diagram"", ...\n"+...
                "BlockDiagramType=""model"");\n");
                fprintf(this.FID,"rptN = numel(rptOpenModels);\n");
                fprintf(this.FID,"for rptI = 1:rptN\n");
                fprintf(this.FID,"rptFunctionFinder = FunctionReferenceFinder(Container=rptOpenModels{rptI}, ...\n");
                fprintf(this.FID,"SearchDepth=inf);\n");
                fprintf(this.FID,"rptFunctionResults = [rptFunctionResults, find(rptFunctionFinder)]; %%#ok<AGROW> \n");
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"rptFunctionResults = unique(rptFunctionResults);\n\n");
            end
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptSimulinkFcnsAndVars";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_obj_fun_var.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_obj_fun_var
            templateFolder=fullfile(rptgen_sl_csl_obj_fun_var.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,strcat(templateName,'.txt'));
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

