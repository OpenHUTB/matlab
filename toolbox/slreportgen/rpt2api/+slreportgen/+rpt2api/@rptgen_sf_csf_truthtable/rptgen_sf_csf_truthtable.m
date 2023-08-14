classdef rptgen_sf_csf_truthtable<mlreportgen.rpt2api.ComponentConverter
































    methods
        function this=rptgen_sf_csf_truthtable(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end
    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser



            writeStartBanner(this);

            allowedContextList=["rptgen_sl.csl_mdl_loop",...
            "rptgen_sl.csl_sys_loop",...
            "rptgen_sl.csl_blk_loop",...
            "rptgen_sl.csl_sig_loop",...
            "rptgen_sf.csf_state_loop"];
            stateVariable=this.RptStateVariable;

            ttContext=getContext(this,allowedContextList);
            if strcmp(ttContext,"rptgen_sl.csl_blk_loop")
                fprintf(this.FID,...
                "rptCurrentBlockObject = %s.CurrentBlock.Object;\n",stateVariable);
                fwrite(this.FID,...
                "if isTruthTable(rptCurrentBlockObject)"+newline);


                writeTruthTable(this);

                fwrite(this.FID,"end"+newline+newline);
            elseif strcmp(ttContext,"rptgen_sf.csf_state_loop")
                fprintf(this.FID,...
                "rptCurrentBlockObject = %s.CurrentState.Object;\n",stateVariable);
                fwrite(this.FID,...
                "if isTruthTable(rptCurrentBlockObject)"+newline);


                writeTruthTable(this);

                fwrite(this.FID,"end"+newline+newline);
            else


                if strcmp(ttContext,"rptgen_sl.csl_sys_loop")
                    fwrite(this.FID,...
                    "% Report on all Truth Table blocks in the current system."+newline);
                    fprintf(this.FID,...
                    "rptTTBlockFinder = BlockFinder(%s.CurrentSystem);\n",...
                    stateVariable);
                    fprintf(this.FID,...
                    "rptAllReportedBlocks = find(rptTTBlockFinder);\n");
                elseif strcmp(ttContext,"rptgen_sl.csl_sig_loop")
                    fwrite(this.FID,...
                    "% Report on all Truth Table blocks connected to the current signal."+newline);
                    fprintf(this.FID,...
                    "rptTTBlockFinder = BlockFinder(...\n");
                    fprintf(this.FID,...
                    "Container=get_param(%s.CurrentSignal.SourceBlock,""Parent""), ...\n",...
                    stateVariable);
                    fprintf(this.FID,...
                    "ConnectedSignal=%s.CurrentSignal);\n",stateVariable);
                    fprintf(this.FID,...
                    "rptAllReportedBlocks = find(rptTTBlockFinder);\n");
                else
                    fwrite(this.FID,...
                    "% Report on all Truth Table blocks in the current model."+newline);
                    fprintf(this.FID,"rptAllReportedBlocks = [];\n");
                    fprintf(this.FID,...
                    "rptN = numel(%s.CurrentModelReportedSystems);\n",stateVariable);
                    fprintf(this.FID,"for rptI = 1:rptN\n");
                    fprintf(this.FID,...
                    "rptTTBlockFinder = BlockFinder(%s.CurrentModelReportedSystems(rptI));\n",...
                    stateVariable);
                    fprintf(this.FID,...
                    "rptAllReportedBlocks = [rptAllReportedBlocks, find(rptTTBlockFinder)]; %%#ok<AGROW> \n");
                    fprintf(this.FID,"end\n");
                end


                fwrite(this.FID,...
                "rptTTIdx = arrayfun(@(obj) isTruthTable(obj),rptAllReportedBlocks);"+newline);
                fwrite(this.FID,...
                "rptTTList = rptAllReportedBlocks(rptTTIdx);"+newline+newline);


                fwrite(this.FID,...
                "% Loop through list of Truth Table blocks to be reported."+newline);
                fwrite(this.FID,...
                "rptNTTBlocks = numel(rptTTList);"+newline);
                fwrite(this.FID,...
                "for rptITTBlock = 1:rptNTTBlocks"+newline);
                fwrite(this.FID,...
                "rptCurrentBlockObject = rptTTList(rptITTBlock).Object;"+newline);
                fprintf(this.FID,...
                "%s.CurrentBlock = rptTTList(rptITTBlock);\n\n",stateVariable);


                writeTruthTable(this);

                fwrite(this.FID,"end"+newline+newline);
            end



            writeEndBanner(this);
        end

        function name=getVariableRootName(~)





            name="rptTruthTable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sf_csf_truthtable.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end
    end

    methods(Access=private)

        function writeTruthTable(this)


            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);
            parentName=this.RptFileConverter.VariableNameStack.top;


            fwrite(this.FID,...
            "% Create TruthTable reporter."+newline);
            fprintf(this.FID,...
            "%s = TruthTable(rptCurrentBlockObject);\n",varName);










            if~this.Component.ShowConditionHeader
                fprintf(this.FID,...
                "%s.IncludeConditionTableHeader = false;\n",varName);
            end


            if~this.Component.ShowConditionNumber
                fprintf(this.FID,...
                "%s.IncludeConditionTableRowNumber = false;\n",varName);
            end



            if~this.Component.ShowConditionCode
                fprintf(this.FID,...
                "%s.IncludeConditionTableConditionCol = false;\n",varName);
            end



            if~this.Component.ShowConditionDescription
                fprintf(this.FID,...
                "%s.IncludeConditionTableDescriptionCol = false;\n",varName);
            end



            nRepeatCols=this.Component.ShowConditionNumber+...
            this.Component.ShowConditionCode+...
            this.Component.ShowConditionDescription;
            if nRepeatCols>0
                fprintf(this.FID,...
                "%s.ConditionTableReporter.RepeatCols  = %d;\n",...
                varName,nRepeatCols);
            end
            maxColsPerTable=nRepeatCols+this.Component.ConditionWrapLimit;
            fprintf(this.FID,...
            "%s.ConditionTableReporter.MaxCols = %d;\n",...
            varName,maxColsPerTable);


            if~this.Component.ShowActionHeader
                fprintf(this.FID,...
                "%s.IncludeActionTableHeader = false;\n",varName);
            end


            if~this.Component.ShowActionNumber
                fprintf(this.FID,...
                "%s.IncludeActionTableRowNumber = false;\n",varName);
            end



            if~this.Component.ShowActionCode
                fprintf(this.FID,...
                "%s.IncludeActionTableActionCol = false;\n",varName);
            end



            if~this.Component.ShowActionDescription
                fprintf(this.FID,...
                "%s.IncludeActionTableDescriptionCol = false;\n",varName);
            end


            fprintf(this.FID,"append(%s,%s);\n",parentName,varName);
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sf_csf_truthtable
            templateFolder=fullfile(rptgen_sf_csf_truthtable.getClassFolder,...
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