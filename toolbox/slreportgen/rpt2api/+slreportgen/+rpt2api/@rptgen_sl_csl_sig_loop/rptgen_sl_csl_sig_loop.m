classdef rptgen_sl_csl_sig_loop<mlreportgen.rpt2api.LoopComponentConverter



























    properties(Access=private)
        Context="";
    end

    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_sig_loop",...
        "csl_blk_loop",...
        ];

        SkippedContexts=["rptgen_sl.CAnnotationLoop",...
        "rptgen_sl.csl_cfgset"];
    end

    methods

        function this=rptgen_sl_csl_sig_loop(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sl_csl_sig_loop

            this.Context=getContext(this,[this.SupportedContexts,this.SkippedContexts]);
            if ismember(this.Context,this.SkippedContexts)
                fprintf(this.FID,"% Signal loop with %s parent skipped.\n\n",this.Context);
                return
            end

            writeStartBanner(this);
            writeSaveState(this);


            suffix=this.LoopVariableSuffix;

            writeSignalList(this);


            sortBy=this.Component.SortBy;
            if~strcmp(sortBy,"none")
                if strcmp(sortBy,"alphabetical-exclude-empty")
                    fwrite(this.FID,"% Remove unnamed signals"+newline);
                    fprintf(this.FID,"rptSignalList%s([rptSignalList%s.Name] == """") = [];\n",suffix,suffix);
                    sortBy="alphabetical";
                end
                fwrite(this.FID,"% Sort signals"+newline);
                fprintf(this.FID,"rptSignalList%s = sortObjects(rptSignalList%s,""%s"");\n\n",suffix,suffix,sortBy);
            end

            fwrite(this.FID,"% Loop through list of signals to be reported."+newline);
            fprintf(this.FID,"rptNSignals%s = numel(rptSignalList%s);\n",suffix,suffix);
            fprintf(this.FID,"for rptISignal%s = 1:rptNSignals%s\n",suffix,suffix);
            fprintf(this.FID,"%s.CurrentSignal = rptSignalList%s(rptISignal%s);\n",...
            this.RptStateVariable,suffix,suffix);

            writeObjectSectionCode(this);
        end

        function writeSignalList(this)
            switch this.Context
            case "rptgen_sl.csl_mdl_loop"
                fwrite(this.FID,"% Report on all signals in reported systems of current model."+newline+newline);


                fwrite(this.FID,"% Create a finder to find signals in each system."+newline);
                fprintf(this.FID,"rptSignalFinder = SignalFinder(%s.CurrentModelHandle);\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder options."+newline);
                fwrite(this.FID,"rptSignalFinder.IncludeInternalSignals = true;"+newline);
                fwrite(this.FID,"rptSignalFinder.IncludeVirtualBlockSignals = true;"+newline);
                fwrite(this.FID,"rptSignalFinder.SearchDepth = 1;"+newline);

                fprintf(this.FID,"%% Loop through systems to find signals to report\n");
                fprintf(this.FID,"rptReportedSystems = %s.CurrentModelReportedSystems;\n",...
                this.RptStateVariable);
                fwrite(this.FID,"rptSignalNSystems = numel(rptReportedSystems);"+newline);
                fprintf(this.FID,"rptSignalList%s = [];\n",this.LoopVariableSuffix);
                fwrite(this.FID,"for rptI = 1:rptSignalNSystems"+newline);
                fwrite(this.FID,"rptSystemResult = rptReportedSystems(rptI);"+newline);
                fwrite(this.FID,"rptSignalFinder.Container = rptSystemResult.Object;"+newline);
                fwrite(this.FID,"% Add signals to signal list."+newline);
                fprintf(this.FID,"rptSignalList%s = [rptSignalList%s, find(rptSignalFinder)]; %%#ok<AGROW> \n",...
                this.LoopVariableSuffix,this.LoopVariableSuffix);
                fwrite(this.FID,"end"+newline+newline);

                fwrite(this.FID,"% Remove duplicate signals"+newline);
                fprintf(this.FID,"[~,rptSignalUniqueIdx,~] = unique([rptSignalList%s.Object],""stable"");\n",...
                this.LoopVariableSuffix);
                fprintf(this.FID,"rptSignalList%s = rptSignalList%s(rptSignalUniqueIdx);\n\n",...
                this.LoopVariableSuffix,this.LoopVariableSuffix);

            case "rptgen_sl.csl_sys_loop"

                fwrite(this.FID,"% Create a finder to find signals in the current system."+newline);

                fprintf(this.FID,"rptSignalFinder = SignalFinder(%s.CurrentSystem);\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder type options."+newline);

                fwrite(this.FID,"rptSignalFinder.IncludeVirtualBlockSignals = true;"+newline);
                if~this.Component.isSystemIncoming
                    fwrite(this.FID,"rptSignalFinder.IncludeInputSignals = false;"+newline);
                end
                if~this.Component.isSystemOutgoing
                    fwrite(this.FID,"rptSignalFinder.IncludeOutputSignals = false;"+newline);
                end
                if this.Component.isSystemInternal
                    fwrite(this.FID,"rptSignalFinder.IncludeInternalSignals = true;"+newline);
                end
                fwrite(this.FID,"rptSignalFinder.SearchDepth = 1;"+newline);

                fprintf(this.FID,"rptSignalList%s = find(rptSignalFinder);\n\n",this.LoopVariableSuffix);

            case "rptgen_sl.csl_blk_loop"

                fwrite(this.FID,"% Create a finder to find signals connected to the current block."+newline);

                fprintf(this.FID,"rptSignalFinder = SignalFinder(%s.CurrentBlock);\n",this.RptStateVariable);
                fwrite(this.FID,"% Set finder type options."+newline);

                fwrite(this.FID,"rptSignalFinder.IncludeVirtualBlockSignals = true;"+newline);
                if~this.Component.isBlockIncoming
                    fwrite(this.FID,"rptSignalFinder.IncludeInputSignals = false;"+newline);
                end
                if~this.Component.isBlockOutgoing
                    fwrite(this.FID,"rptSignalFinder.IncludeOutputSignals = false;"+newline);
                end
                fwrite(this.FID,"rptSignalFinder.SearchDepth = 1;"+newline);

                fprintf(this.FID,"rptSignalList%s = find(rptSignalFinder);\n\n",this.LoopVariableSuffix);

            case "rptgen_sl.csl_sig_loop"
                fwrite(this.FID,"% Report the current signal."+newline);
                fprintf(this.FID,"rptSignalList%s = %s.CurrentSignal;\n\n",...
                this.LoopVariableSuffix,this.RptStateVariable);

            otherwise

                fwrite(this.FID,"% Report on all signals in all open models."+newline);
                fprintf(this.FID,"rptSignalList%s = [];\n",this.LoopVariableSuffix);
                fwrite(this.FID,"% Find all open models."+newline);
                fwrite(this.FID,"rptSignalLoopModelList = find_system( ..."+newline);
                fwrite(this.FID,"SearchDepth=0, ..."+newline);
                fwrite(this.FID,"type=""block_diagram"", ..."+newline);
                fwrite(this.FID,"BlockDiagramType=""model"");"+newline+newline);
                fwrite(this.FID,"% Loop through open models."+newline);
                fwrite(this.FID,"rptN = numel(rptSignalLoopModelList);"+newline);
                fwrite(this.FID,"for rptI = 1:rptN"+newline);
                fwrite(this.FID,"% Create a finder to find systems in the current model."+newline);
                fprintf(this.FID,"rptSystemFinder = SystemDiagramFinder(rptSignalLoopModelList{rptI});\n");

                fwrite(this.FID,"% Loop through systems to find signals to report."+newline);
                fwrite(this.FID,"while hasNext(rptSystemFinder)"+newline);
                fwrite(this.FID,"rptSystemResult = next(rptSystemFinder);"+newline);
                fwrite(this.FID,"% Create an signal finder to find signals in each system."+newline);
                fprintf(this.FID,"rptSignalFinder = SignalFinder(rptSystemResult.Object);\n");
                fwrite(this.FID,"% Set finder options."+newline);
                fwrite(this.FID,"rptSignalFinder.IncludeInternalSignals = true;"+newline);
                fwrite(this.FID,"rptSignalFinder.IncludeVirtualBlockSignals = true;"+newline);
                fwrite(this.FID,"rptSignalFinder.SearchDepth = 1;"+newline);
                fwrite(this.FID,"rptSignalFinderResults = find(rptSignalFinder);"+newline);
                fprintf(this.FID,"rptSignalList%s = [rptSignalList%s, rptSignalFinderResults]; %%#ok<AGROW> \n",...
                this.LoopVariableSuffix,this.LoopVariableSuffix);
                fwrite(this.FID,"end"+newline);

                fwrite(this.FID,"end"+newline+newline);

                fwrite(this.FID,"% Remove duplicate signals"+newline);
                fprintf(this.FID,"[~,rptSignalUniqueIdx,~] = unique([rptSignalList%s.Object],""stable"");\n",this.LoopVariableSuffix);
                fprintf(this.FID,"rptSignalList%s = rptSignalList%s(rptSignalUniqueIdx);\n",this.LoopVariableSuffix,this.LoopVariableSuffix);
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
            fprintf(this.FID,"rptSignalName = %s.CurrentSignal.Name;\n",this.RptStateVariable);
            fwrite(this.FID,"if rptSignalName == """""+newline);
            fprintf(this.FID,"rptSignalParentName = normalizeString(get_param(%s.CurrentSignal.SourceBlock,""Name""));\n",this.RptStateVariable);
            fprintf(this.FID,"rptSignalNumber = %s.CurrentSignal.SourcePortNumber;\n",this.RptStateVariable);
            fwrite(this.FID,"rptSignalName = sprintf(""%s<%d>"",rptSignalParentName,rptSignalNumber);"+newline);
            fwrite(this.FID,"end"+newline);
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf(""Signal - %s"",rptSignalName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptSignalName;"+newline);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = getReporterLinkTargetID(%s.CurrentSignal);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % signal loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_sig_loop
            templateFolder=fullfile(rptgen_sl_csl_sig_loop.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,strcat(templateName,'.txt'));
            template=fileread(templatePath);
        end

    end

end