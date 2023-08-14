classdef rptgen_sl_csl_blk_loop<mlreportgen.rpt2api.LoopComponentConverter



























    properties(Access=private)
        Context="";
    end

    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_sig_loop",...
        "csl_blk_loop"];
    end

    methods

        function this=rptgen_sl_csl_blk_loop(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sl_csl_blk_loop

            writeStartBanner(this);
            writeSaveState(this);


            suffix=this.LoopVariableSuffix;

            if strcmp(this.Component.LoopType,"auto")
                writeAutomaticBlockList(this);
            else
                writeCustomBlockList(this);
            end


            if this.Component.isFilterList&&~isempty(this.Component.FilterTerms)
                writeFilterBlocks(this);
            end


            if~strcmp(this.Component.SortBy,"none")
                fwrite(this.FID,"% Sort reported blocks."+newline);
                fprintf(this.FID,"rptBlockList%s = sortBlocks(rptBlockList%s,""%s"");\n\n",...
                suffix,suffix,this.Component.SortBy);
            end

            fwrite(this.FID,"% Loop through list of blocks to be reported."+newline);
            fprintf(this.FID,"rptNBlocks%s = numel(rptBlockList%s);\n",suffix,suffix);
            fprintf(this.FID,"for rptIBlock%s = 1:rptNBlocks%s\n",suffix,suffix);
            fprintf(this.FID,"%s.CurrentBlock = rptBlockList%s(rptIBlock%s);\n\n",...
            this.RptStateVariable,suffix,suffix);

            writeObjectSectionCode(this);
        end

        function writeCustomBlockList(this)
            import mlreportgen.rpt2api.exprstr.Parser


            fwrite(this.FID,"% Loop on the specified blocks."+newline);
            objList=this.Component.ObjectList;
            nObj=numel(objList);
            if nObj>0
                fprintf(this.FID,"rptBlockList%s = [ ...\n",this.LoopVariableSuffix);

                for k=1:nObj
                    objExpr=objList{k};
                    if regexp(objExpr,'.*%<.+>')
                        p=Parser(objExpr);
                        parse(p);
                        fprintf(this.FID,"BlockResult("+p.FormatString+")",p.Expressions{:});
                        fprintf(this.FID,", ... %% converted from: %s\n",strrep(p.ExprStr,newline,'\n'));
                    else
                        fwrite(this.FID,"BlockResult("""+objExpr+"""), ..."+newline);
                    end
                end
                fwrite(this.FID,"];"+newline+newline);
            end
        end

        function writeAutomaticBlockList(this)
            ctx=getContext(this,this.SupportedContexts);

            switch ctx
            case "rptgen_sl.csl_mdl_loop"
                fwrite(this.FID,"% Report on all blocks in reported systems of current model."+newline);


                fprintf(this.FID,"rptBlockList%s = [];\n",this.LoopVariableSuffix);
                fprintf(this.FID,"rptN = numel(%s.CurrentModelReportedSystems);\n",this.RptStateVariable);
                fprintf(this.FID,"for rptI = 1:rptN\n");
                fprintf(this.FID,"rptBlockFinder = BlockFinder(%s.CurrentModelReportedSystems(rptI));\n",...
                this.RptStateVariable);
                fprintf(this.FID,"rptBlockList%s = [rptBlockList%s, find(rptBlockFinder)];\n\n",...
                this.LoopVariableSuffix,this.LoopVariableSuffix);
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"%% Remove subsystems that were searched\n");
                fprintf(this.FID,"rptReportedSystemsIdx = ismember([rptBlockList%s.BlockPath], ...\n",this.LoopVariableSuffix);
                fprintf(this.FID,"[%s.CurrentModelReportedSystems.Path]);\n",this.RptStateVariable);
                fprintf(this.FID,"rptBlockList%s(rptReportedSystemsIdx) = [];\n\n",this.LoopVariableSuffix);

            case "rptgen_sl.csl_sys_loop"

                fwrite(this.FID,"% Report on all blocks in the current system."+newline);
                fprintf(this.FID,"rptBlockFinder = BlockFinder(Container=%s.CurrentSystem);\n",...
                this.RptStateVariable);
                fprintf(this.FID,"rptBlockList%s = find(rptBlockFinder);\n\n",...
                this.LoopVariableSuffix);
            case "rptgen_sl.csl_blk_loop"
                fwrite(this.FID,"% Report on current block."+newline);
                fprintf(this.FID,"rptBlockList%s = %s.CurrentBlock;\n\n",...
                this.LoopVariableSuffix,this.RptStateVariable);

            case "rptgen_sl.csl_sig_loop"

                fwrite(this.FID,"% Report on blocks connected to the current signal."+newline);
                fprintf(this.FID,"rptBlockFinder = BlockFinder(...\n");
                fprintf(this.FID,"Container=get_param(%s.CurrentSignal.SourceBlock,""Parent""), ...\n",...
                this.RptStateVariable);
                fprintf(this.FID,"ConnectedSignal=%s.CurrentSignal);\n",this.RptStateVariable);
                fprintf(this.FID,"rptBlockList%s = find(rptBlockFinder);\n\n",...
                this.LoopVariableSuffix);

            otherwise

                fwrite(this.FID,"% Report on all blocks in all open models."+newline);
                fprintf(this.FID,"rptBlockList%s = [];\n",this.LoopVariableSuffix);
                fprintf(this.FID,"rptOpenModels = find_system(SearchDepth=0, ...\n"+...
                "Type=""block_diagram"", ...\n"+...
                "BlockDiagramType=""model"");\n");
                fprintf(this.FID,"rptN = numel(rptOpenModels);\n");
                fprintf(this.FID,"for rptI = 1:rptN\n");
                fprintf(this.FID,"rptBlockFinder = BlockFinder(Container=rptOpenModels{rptI},SearchDepth=Inf);\n");
                fprintf(this.FID,"rptBlockList%s = [rptBlockList%s, find(rptBlockFinder)];\n",...
                this.LoopVariableSuffix,this.LoopVariableSuffix);
                fprintf(this.FID,"end\n\n");
            end
        end

        function writeFilterBlocks(this)

            searchArgs=washSearchTerms(this.Component.FilterTerms(:)');

            fwrite(this.FID,"% Filter blocks based on specified Simulink properties."+newline);
            fprintf(this.FID,"rptBlockListPaths = [rptBlockList%s.BlockPath];\n",...
            this.LoopVariableSuffix);
            fprintf(this.FID,"rptBlockListFiltered = find_system(rptBlockListPaths, ...\n");
            fwrite(this.FID,"SearchDepth=0, ..."+newline);
            fwrite(this.FID,"Regexp=""on""");

            nTerms=numel(searchArgs);
            for k=1:2:nTerms
                fprintf(this.FID,", ...\n%s=""%s""",searchArgs{k},searchArgs{k+1});
            end
            fwrite(this.FID,");"+newline+newline);
            fprintf(this.FID,"%% Find indices of blocks that were not filtered\n");
            fprintf(this.FID,"rptBlockListIdx = ismember(rptBlockListPaths,rptBlockListFiltered);\n");
            fprintf(this.FID,"rptBlockList%s = rptBlockList%s(rptBlockListIdx);\n\n",...
            this.LoopVariableSuffix,this.LoopVariableSuffix);
        end

        function name=getVariableName(~)
            name=[];
        end

    end


    methods(Access=protected)

        function writeSectionTitleCode(this,titleVarName,~)
            fprintf(this.FID,"rptBlockName = %s.CurrentBlock.Name;\n",this.RptStateVariable);
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf(""Block - %s"",rptBlockName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptBlockName;"+newline);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = getReporterLinkTargetID(%s.CurrentBlock);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % block loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_blk_loop
            templateFolder=fullfile(rptgen_sl_csl_blk_loop.getClassFolder,...
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