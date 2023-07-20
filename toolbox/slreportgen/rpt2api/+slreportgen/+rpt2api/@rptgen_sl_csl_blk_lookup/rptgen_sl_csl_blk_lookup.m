classdef rptgen_sl_csl_blk_lookup<mlreportgen.rpt2api.ComponentConverter































    methods

        function this=rptgen_sl_csl_blk_lookup(component,rptFileConverter)
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
            "rptgen_sl.csl_sig_loop"];
            stateVariable=this.RptStateVariable;

            lutContext=getContext(this,allowedContextList);
            if strcmp(lutContext,"rptgen_sl.csl_blk_loop")
                fprintf(this.FID,...
                "rptCurrentBlockObject = %s.CurrentBlock.Object;\n",stateVariable);
                fwrite(this.FID,...
                "if isLookupTable(rptCurrentBlockObject)"+newline);


                writeLookupTable(this);

                fwrite(this.FID,"end"+newline+newline);
            else


                if strcmp(lutContext,"rptgen_sl.csl_sys_loop")
                    fwrite(this.FID,...
                    "% Report on all Lookup Table blocks in the current system."+newline);
                    fprintf(this.FID,...
                    "rptLookupBlockFinder = BlockFinder(%s.CurrentSystem);\n",...
                    stateVariable);
                    fprintf(this.FID,"rptAllReportedBlocks = find(rptLookupBlockFinder);\n");
                elseif strcmp(lutContext,"rptgen_sl.csl_sig_loop")
                    fwrite(this.FID,...
                    "% Report on all Lookup Table blocks connected to the current signal."+newline);
                    fprintf(this.FID,...
                    "rptLookupBlockFinder = BlockFinder(...\n");
                    fprintf(this.FID,...
                    "Container=get_param(%s.CurrentSignal.SourceBlock,""Parent""), ...\n",...
                    stateVariable);
                    fprintf(this.FID,...
                    "ConnectedSignal=%s.CurrentSignal);\n",stateVariable);
                    fprintf(this.FID,...
                    "rptAllReportedBlocks = find(rptLookupBlockFinder);\n");
                elseif strcmp(lutContext,"rptgen_sl.csl_mdl_loop")
                    fwrite(this.FID,...
                    "% Report on all Lookup Table blocks in the current model."+newline);
                    fprintf(this.FID,"rptAllReportedBlocks = [];\n");
                    fprintf(this.FID,"rptN = numel(%s.CurrentModelReportedSystems);\n",stateVariable);
                    fprintf(this.FID,"for rptI = 1:rptN\n");
                    fprintf(this.FID,...
                    "rptLookupBlockFinder = BlockFinder(%s.CurrentModelReportedSystems(rptI));\n",...
                    stateVariable);
                    fprintf(this.FID,"rptAllReportedBlocks = [rptAllReportedBlocks, find(rptLookupBlockFinder)]; %%#ok<AGROW> \n");
                    fprintf(this.FID,"end\n");
                else


                    fwrite(this.FID,"% Report on all Lookup Table blocks in all open models."+newline);
                    fprintf(this.FID,"rptAllReportedBlocks = [];\n");
                    fprintf(this.FID,...
                    "rptOpenModels = find_system(SearchDepth=0, ...\n"+...
                    "Type=""block_diagram"", ...\n"+...
                    "BlockDiagramType=""model"");\n");
                    fprintf(this.FID,"rptNModels = numel(rptOpenModels);\n");
                    fprintf(this.FID,"for rptIModel = 1:rptNModels\n");
                    fprintf(this.FID,...
                    "rptLookupBlockFinder = BlockFinder(Container=rptOpenModels{rptIModel},SearchDepth=Inf);\n");
                    fprintf(this.FID,...
                    "rptAllReportedBlocks = [rptAllReportedBlocks, find(rptLookupBlockFinder)]; %%#ok<AGROW> \n");
                    fprintf(this.FID,"end\n");
                end


                fwrite(this.FID,...
                "rptLutIdx = arrayfun(@(obj) isLookupTable(obj),rptAllReportedBlocks);"+newline);
                fwrite(this.FID,...
                "rptLutList = rptAllReportedBlocks(rptLutIdx);"+newline+newline);


                fwrite(this.FID,...
                "% Loop through list of Lookup Table blocks to be reported."+newline);
                fwrite(this.FID,...
                "rptNLutBlocks = numel(rptLutList);"+newline);
                fwrite(this.FID,...
                "for rptILutBlock = 1:rptNLutBlocks"+newline);
                fwrite(this.FID,...
                "rptCurrentBlockObject = rptLutList(rptILutBlock).Object;"+newline);
                fprintf(this.FID,...
                "%s.CurrentBlock = rptLutList(rptILutBlock);\n\n",stateVariable);


                writeLookupTable(this);

                fwrite(this.FID,"end"+newline+newline);
            end



            writeEndBanner(this);
        end

        function name=getVariableRootName(~)





            name="rptLookupTable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_blk_lookup.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end
    end

    methods(Access=private)

        function writeLookupTable(this)


            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);
            parentName=this.RptFileConverter.VariableNameStack.top;


            fwrite(this.FID,...
            "% Create LookupTable reporter."+newline);
            fprintf(this.FID,...
            "%s = LookupTable(rptCurrentBlockObject);\n",varName);


            if this.Component.isSinglePlot||this.Component.isDoublePlot
                fprintf(this.FID,"%s.IncludePlot = true;\n",varName);




                if this.Component.isDoublePlot
                    if strcmp(this.Component.DoublePlotType,"surfaceplot")
                        fprintf(this.FID,...
                        '%s.PlotType = "Surface Plot";\n',varName);
                    else
                        fprintf(this.FID,...
                        '%s.PlotType = "Mesh Plot";\n',varName);
                    end
                end







                imgFormat="svg";
                if~strcmpi(this.Component.ImageFormat,"ps")
                    plotSnapshotFormat=...
                    string(lower(this.Component.ImageFormat(1:3)));
                    switch plotSnapshotFormat
                    case "jpe"
                        imgFormat="jpeg";
                    case "tif"
                        imgFormat="tiff";
                    case{"bmp","pdf","png","emf"}
                        imgFormat=plotSnapshotFormat;
                    end
                end
                fprintf(this.FID,...
                '%s.PlotReporter.SnapshotFormat = "%s";\n',...
                varName,imgFormat);


                imgUnits=...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits);
                fprintf(this.FID,...
                '%s.PlotReporter.Scaling = "custom";\n',varName);
                fprintf(this.FID,'%s.PlotReporter.Width = "%s";\n',...
                varName,...
                strcat(string(this.Component.PrintSize(1)),imgUnits));
                fprintf(this.FID,'%s.PlotReporter.Height = "%s";\n',...
                varName,...
                strcat(string(this.Component.PrintSize(2)),imgUnits));


                if strcmp(this.Component.InvertHardcopy,"off")
                    fprintf(this.FID,...
                    "%s.PlotReporter.PreserveBackgroundColor = true;\n",...
                    varName);
                end


                captionType=this.Component.CaptionType;
                if strcmp(captionType,"auto")

                    fprintf(this.FID,...
                    '%s.PlotReporter.Snapshot.Caption = get_param(rptCurrentBlockObject,"Description");\n',...
                    varName);
                else
                    caption=this.Component.Caption;
                    if~isempty(caption)
                        Parser.writeExprStr(this.FID,...
                        caption,"rptLutPlotCaption");
                        fprintf(this.FID,...
                        "%s.PlotReporter.Snapshot.Caption = rptLutPlotCaption;\n",...
                        varName);
                    end
                end
            else

                fprintf(this.FID,"%s.IncludePlot = false;\n",varName);
            end


            if this.Component.isSingleTable||...
                this.Component.isDoubleTable||...
                this.Component.isMultiTable
                fprintf(this.FID,"%s.IncludeTable = true;\n",varName);
            else

                fprintf(this.FID,"%s.IncludeTable = false;\n",varName);
            end





            fprintf(this.FID,"append(%s,%s);\n",parentName,varName);
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_blk_lookup
            templateFolder=fullfile(rptgen_sl_csl_blk_lookup.getClassFolder,...
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