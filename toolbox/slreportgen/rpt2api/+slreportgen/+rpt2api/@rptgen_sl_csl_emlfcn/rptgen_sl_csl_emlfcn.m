classdef rptgen_sl_csl_emlfcn<mlreportgen.rpt2api.ComponentConverter































    methods

        function this=rptgen_sl_csl_emlfcn(component,rptFileConverter)
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
            "rptgen_sf.csf_state_loop"];
            stateVariable=this.RptStateVariable;

            mlFcnContext=getContext(this,allowedContextList);
            if strcmp(mlFcnContext,"rptgen_sl.csl_blk_loop")
                fprintf(this.FID,...
                "rptCurrentBlockObject = %s.CurrentBlock.Object;\n",stateVariable);
                fwrite(this.FID,...
                "if isMATLABFunction(rptCurrentBlockObject)"+newline);


                writeMATLABFunction(this);

                fwrite(this.FID,"end"+newline+newline);
            elseif strcmp(mlFcnContext,"rptgen_sf.csf_state_loop")
                fprintf(this.FID,...
                "rptCurrentBlockObject = %s.CurrentState.Object;\n",stateVariable);
                fwrite(this.FID,...
                "if isMATLABFunction(rptCurrentBlockObject)"+newline);


                writeMATLABFunction(this);

                fwrite(this.FID,"end"+newline+newline);
            else


                if strcmp(mlFcnContext,"rptgen_sl.csl_sys_loop")
                    fwrite(this.FID,...
                    "% Report on all MATLAB Function blocks in the current system."+newline);
                    fprintf(this.FID,...
                    "rptMLFcnBlockFinder = BlockFinder(%s.CurrentSystem);\n",...
                    stateVariable);
                    fprintf(this.FID,"rptAllReportedBlocks = find(rptMLFcnBlockFinder);\n");
                else
                    fwrite(this.FID,...
                    "% Report on all MATLAB Function blocks in the current model."+newline);
                    fprintf(this.FID,"rptAllReportedBlocks = [];\n");
                    fprintf(this.FID,"rptN = numel(%s.CurrentModelReportedSystems);\n",stateVariable);
                    fprintf(this.FID,"for rptI = 1:rptN\n");
                    fprintf(this.FID,...
                    "rptMLFcnBlockFinder = BlockFinder(%s.CurrentModelReportedSystems(rptI));\n",...
                    stateVariable);
                    fprintf(this.FID,"rptAllReportedBlocks = [rptAllReportedBlocks, find(rptMLFcnBlockFinder)]; %%#ok<AGROW> \n");
                    fprintf(this.FID,"end\n");
                end


                fwrite(this.FID,...
                "rptMLFcnIdx = arrayfun(@(obj) isMATLABFunction(obj),rptAllReportedBlocks);"+newline);
                fwrite(this.FID,...
                "rptMLFcnList = rptAllReportedBlocks(rptMLFcnIdx);"+newline+newline);


                fwrite(this.FID,...
                "% Loop through list of MATLAB Function blocks to be reported."+newline);
                fwrite(this.FID,...
                "rptNMLFcnBlocks = numel(rptMLFcnList);"+newline);
                fwrite(this.FID,...
                "for rptIMLFcnBlock = 1:rptNMLFcnBlocks"+newline);
                fwrite(this.FID,...
                "rptCurrentBlockObject = rptMLFcnList(rptIMLFcnBlock).Object;"+newline);
                fprintf(this.FID,...
                "%s.CurrentBlock = rptMLFcnList(rptIMLFcnBlock);\n\n",stateVariable);


                writeMATLABFunction(this);

                fwrite(this.FID,"end"+newline+newline);
            end



            writeEndBanner(this);
        end

        function name=getVariableRootName(~)





            name="rptMATLABFunction";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_emlfcn.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end
    end

    methods(Access=private)

        function writeMATLABFunction(this)


            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);
            parentName=this.RptFileConverter.VariableNameStack.top;


            fwrite(this.FID,...
            "% Create MATLABFunction reporter."+newline);
            fprintf(this.FID,...
            "%s = MATLABFunction(rptCurrentBlockObject);\n",varName);


            writeFunctionProperties(this);


            writeArgumentSummary(this);


            writeArgumentDetails(this);


            writeFunctionScript(this);


            writeSymbolData(this);


            writeSupportingFcns(this);


            writeSupportingFcnsCode(this);




            updateImpl(this);



            fprintf(this.FID,...
            "%% Append MATLABFunction reporter's implementation object to the report.\n");
            fprintf(this.FID,"append(%s,rptMLFcnImpl);\n",parentName);
        end

        function writeFunctionProperties(this)

            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);

            if~this.Component.includeFcnProps

                fprintf(this.FID,"%s.IncludeObjectProperties = false;\n",...
                varName);
            else

                if~strcmp(this.Component.FcnPropsTableTitleType,"auto")
                    Parser.writeExprStr(this.FID,...
                    this.Component.FcnPropsTableTitle,...
                    sprintf("%s.ObjectPropertiesReporter.Title",varName));
                end



                if this.Component.spansPageFcnPropTable
                    fprintf(this.FID,'%s = "%s";\n',...
                    sprintf("%s.ObjectPropertiesReporter.TableWidth",varName),...
                    "100%");
                end


                if~this.Component.hasBorderFcnPropTable


                    registerHelperFunction(this.RptFileConverter,"removeTableGrids");
                    fprintf(this.FID,...
                    "%s.ObjectPropertiesReporter.TableEntryUpdateFcn = @removeTableGrids;\n",...
                    varName);
                end





            end
        end

        function writeArgumentSummary(this)

            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);

            if~this.Component.includeArgSummTable

                fprintf(this.FID,"%s.IncludeArgumentSummary = false;\n",...
                varName);
            else

                if~strcmp(this.Component.ArgSummTableTitleType,"auto")
                    Parser.writeExprStr(this.FID,...
                    this.Component.ArgSummTableTitle,...
                    sprintf("%s.ArgumentSummaryReporter.Title",varName));
                end


                argSummProps=this.Component.ArgSummTableProps;
                nArgSummProps=numel(argSummProps);
                if nArgSummProps==1
                    fprintf(this.FID,...
                    '%s.ArgumentSummaryProperties = "%s";\n',...
                    varName,argSummProps{1});
                else
                    fprintf(this.FID,"rptMLFcnArgSummProps = [%s%s];\n",...
                    sprintf('"%s" ',argSummProps{1:end-1}),...
                    sprintf('"%s"',argSummProps{end}));
                    fprintf(this.FID,...
                    "%s.ArgumentSummaryProperties = rptMLFcnArgSummProps;\n",...
                    varName);
                end


                if this.Component.spansPageArgSummTable
                    fprintf(this.FID,'%s = "%s";\n',...
                    sprintf("%s.ArgumentSummaryReporter.TableWidth",varName),...
                    "100%");
                end


                if~this.Component.hasBorderArgSummTable


                    registerHelperFunction(this.RptFileConverter,"removeTableGrids");
                    fprintf(this.FID,...
                    "%s.ArgumentSummaryReporter.TableEntryUpdateFcn = @removeTableGrids;\n",...
                    varName);
                end





            end
        end

        function writeArgumentDetails(this)

            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);

            if this.Component.includeArgDetails

                fprintf(this.FID,"%s.IncludeArgumentProperties = true;\n",...
                varName);


                if~strcmp(this.Component.ArgPropTableTitleType,"auto")
                    Parser.writeExprStr(this.FID,...
                    this.Component.ArgPropTableTitle,...
                    sprintf("%s.ArgumentPropertiesReporter.Title",varName));
                end


                if this.Component.spansPageArgPropTable
                    fprintf(this.FID,'%s = "%s";\n',...
                    sprintf("%s.ArgumentPropertiesReporter.TableWidth",varName),...
                    "100%");
                end


                if~this.Component.hasBorderArgPropTable


                    registerHelperFunction(this.RptFileConverter,"removeTableGrids");
                    fprintf(this.FID,...
                    "%s.ArgumentPropertiesReporter.TableEntryUpdateFcn = @removeTableGrids;\n",...
                    varName);
                end






            end
        end

        function writeFunctionScript(this)

            varName=getVariableName(this);

            if~this.Component.includeScript

                fprintf(this.FID,"%s.IncludeFunctionScript = false;\n",...
                varName);
            else
                if~this.Component.highlightScriptSyntax


                    fprintf(this.FID,"%s.HighlightScriptSyntax = false;\n",...
                    varName);
                end
            end
        end

        function writeSymbolData(this)

            if this.Component.includeFcnSymbData
                fprintf(this.FID,"%s.IncludeFunctionSymbolData = true;\n",...
                getVariableName(this));
            end
        end

        function writeSupportingFcns(this)

            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);

            if this.Component.includeSupportingFunctions

                fprintf(this.FID,"%s.IncludeSupportingFunctions = true;\n",...
                varName);


                if this.Component.supportFunctionsToInclude==1
                    fprintf(this.FID,...
                    '%s.SupportingFunctionsType = ["MATLAB", "user-defined"];\n',...
                    varName);
                elseif this.Component.supportFunctionsToInclude==2
                    fprintf(this.FID,...
                    '%s.SupportingFunctionsType = "user-defined";\n',...
                    varName);
                end


                if~strcmp(this.Component.SupportFcnTableTitleType,"auto")
                    Parser.writeExprStr(this.FID,...
                    this.Component.SupportFcnTableTitle,...
                    sprintf("%s.SupportingFunctionsReporter.Title",varName));
                end



                if this.Component.spansPageSupportFcnTable
                    fprintf(this.FID,'%s = "%s";\n',...
                    sprintf("%s.SupportingFunctionsReporter.TableWidth",varName),...
                    "100%");
                end


                if~this.Component.hasBorderSupportFcnTable


                    registerHelperFunction(this.RptFileConverter,"removeTableGrids");
                    fprintf(this.FID,...
                    "%s.SupportingFunctionsReporter.TableEntryUpdateFcn = @removeTableGrids;\n",...
                    varName);
                end





            end
        end

        function writeSupportingFcnsCode(this)

            if this.Component.includeSupportingFunctionsCode
                fprintf(this.FID,"%s.IncludeSupportingFunctionsCode = true;\n",...
                getVariableName(this));
            end
        end

        function updateImpl(this)


            varName=getVariableName(this);

            fprintf(this.FID,"\n");
            fprintf(this.FID,...
            "%% Update MATLABFunction reporter's implementation object.\n");


            fprintf(this.FID,"rptMLFcnImpl = getImpl(%s,rptObj);\n",...
            varName);
            fprintf(this.FID,"if(~isempty(rptMLFcnImpl))\n");


            fprintf(this.FID,...
            "%% Get all the DOM FormalTable objects from the reporter's implementation object.\n");
            fprintf(this.FID,"rptMLFcnTableIdx = ...\n");
            fprintf(this.FID,...
            'arrayfun(@(x) isa(x,"mlreportgen.dom.FormalTable"),rptMLFcnImpl.Children);\n');
            fprintf(this.FID,...
            "rptMLFcnDOMTables = rptMLFcnImpl.Children(rptMLFcnTableIdx);\n\n");


            updateFunctionPropertiesImpl(this);


            updateArgumentSummaryImpl(this);


            updateArgumentDetailsImpl(this)


            updateSupportingFcnsImpl(this)

            fprintf(this.FID,"end\n\n");
        end

        function updateFunctionPropertiesImpl(this)


            if this.Component.includeFcnProps
                fprintf(this.FID,"%% Update Function properties DOM FormalTable object.\n");


                fprintf(this.FID,"rptMLFcnPropTblIdx = ...\n");
                fprintf(this.FID,...
                'arrayfun(@(x) strcmp(x.StyleName,"MATLABFunctionObjectPropertiesTable"),rptMLFcnDOMTables);\n');
                fprintf(this.FID,...
                "rptMLFcnPropTbl = rptMLFcnDOMTables(rptMLFcnPropTblIdx);\n");


                fprintf(this.FID,...
                'rptMLFcnPropTbl.Header.entry(1,1).Children.Content = "%s";\n',...
                this.Component.FcnPropsTablePropColHeader);
                fprintf(this.FID,...
                'rptMLFcnPropTbl.Header.entry(1,2).Children.Content = "%s";\n',...
                this.Component.FcnPropsTableValueColHeader);


                propColWidth=this.Component.FcnPropsTablePropColWidth;
                valueColWidth=this.Component.FcnPropsTableValueColWidth;
                totalWidth=propColWidth+valueColWidth;
                propColPercentWidth=...
                strcat(num2str(propColWidth/totalWidth*100),"%");
                valueColPercentWidth=...
                strcat(num2str(valueColWidth/totalWidth*100),"%");
                fprintf(this.FID,"rptMLFcnPropTblGrps(1) = TableColSpecGroup;\n");
                fprintf(this.FID,"specs(1) = TableColSpec;\n");
                fprintf(this.FID,'specs(1).Style = {Width("%s")};\n',propColPercentWidth);
                fprintf(this.FID,"specs(2) = TableColSpec;\n");
                fprintf(this.FID,'specs(2).Style = {Width("%s")};\n',valueColPercentWidth);
                fprintf(this.FID,"rptMLFcnPropTblGrps(1).ColSpecs = specs;\n");
                fprintf(this.FID,"rptMLFcnPropTbl.ColSpecGroups = rptMLFcnPropTblGrps;\n\n");
            end
        end

        function updateArgumentSummaryImpl(this)


            if this.Component.includeArgSummTable
                fprintf(this.FID,"%% Update Argument Summary DOM FormalTable object.\n");


                fprintf(this.FID,"rptMLFcnArgSummTblIdx = ...\n");
                fprintf(this.FID,...
                'arrayfun(@(x) strcmp(x.StyleName,"MATLABFunctionArgumentSummaryTable"),rptMLFcnDOMTables);\n');
                fprintf(this.FID,...
                "rptMLFcnArgSummTbl = rptMLFcnDOMTables(rptMLFcnArgSummTblIdx);\n");


                alignment=this.Component.ArgSummTableAlign;
                if~strcmpi(alignment,"justify")
                    fprintf(this.FID,...
                    'rptMLFcnArgSummTbl.TableEntriesHAlign = "%s";\n',...
                    alignment);
                end


                argSummColHeaders=this.Component.ArgSummTableColHeaders;
                nArgSummColHeaders=numel(argSummColHeaders);
                for iEntry=1:nArgSummColHeaders
                    fprintf(this.FID,...
                    'rptMLFcnArgSummTbl.Header.entry(1,%d).Children.Content = "%s";\n',...
                    iEntry,argSummColHeaders{iEntry});
                end


                argSummColWidths=this.Component.ArgSummTableColWidths;
                totalWidth=sum(argSummColWidths);
                nCols=numel(argSummColWidths);
                fprintf(this.FID,"rptMLFcnArgSummTblGrps(1) = TableColSpecGroup;\n");
                for iCol=1:nCols

                    currColPercentWidth=...
                    strcat(num2str(argSummColWidths(iCol)/totalWidth*100),"%");
                    fprintf(this.FID,"specs(%d) = TableColSpec;\n",iCol);
                    fprintf(this.FID,'specs(%d).Style = {Width("%s")};\n',...
                    iCol,currColPercentWidth);
                end
                fprintf(this.FID,"rptMLFcnArgSummTblGrps(1).ColSpecs = specs;\n");
                fprintf(this.FID,"rptMLFcnArgSummTbl.ColSpecGroups = rptMLFcnArgSummTblGrps;\n\n");
            end
        end

        function updateArgumentDetailsImpl(this)


            if this.Component.includeArgDetails
                fprintf(this.FID,"%% Update Argument properties DOM FormalTable objects.\n");
                fprintf(this.FID,"rptMLFcnArgDetailsTblIdx = ...\n");
                fprintf(this.FID,...
                'arrayfun(@(x) strcmp(x.StyleName,"MATLABFunctionArgumentPropertiesTable"),rptMLFcnDOMTables);\n');
                fprintf(this.FID,...
                "rptMLFcnArgDetailsTbls = rptMLFcnDOMTables(rptMLFcnArgDetailsTblIdx);\n");

                fprintf(this.FID,"nArgDetailsTbl = numel(rptMLFcnArgDetailsTbls);\n");
                fprintf(this.FID,"for iTbl = 1:nArgDetailsTbl\n");
                fprintf(this.FID,"rptMLFcnCurrArgDetailsTbl = rptMLFcnArgDetailsTbls(iTbl);\n");


                fprintf(this.FID,...
                'rptMLFcnCurrArgDetailsTbl.Header.entry(1,1).Children.Content = "%s";\n',...
                this.Component.ArgPropTablePropColHeader);
                fprintf(this.FID,...
                'rptMLFcnCurrArgDetailsTbl.Header.entry(1,2).Children.Content = "%s";\n',...
                this.Component.ArgPropTableValueColHeader);


                propColWidth=this.Component.ArgPropTablePropColWidth;
                valueColWidth=this.Component.ArgPropTableValueColWidth;
                totalWidth=propColWidth+valueColWidth;
                propColPercentWidth=...
                strcat(num2str(propColWidth/totalWidth*100),"%");
                valueColPercentWidth=...
                strcat(num2str(valueColWidth/totalWidth*100),"%");
                fprintf(this.FID,"rptMLFcnCurrArgDetailsTblGrps(1) = TableColSpecGroup;\n");
                fprintf(this.FID,"specs(1) = TableColSpec;\n");
                fprintf(this.FID,'specs(1).Style = {Width("%s")};\n',propColPercentWidth);
                fprintf(this.FID,"specs(2) = TableColSpec;\n");
                fprintf(this.FID,'specs(2).Style = {Width("%s")};\n',valueColPercentWidth);
                fprintf(this.FID,"rptMLFcnCurrArgDetailsTblGrps(1).ColSpecs = specs;\n");
                fprintf(this.FID,"rptMLFcnCurrArgDetailsTbl.ColSpecGroups = rptMLFcnCurrArgDetailsTblGrps;\n");
                fprintf(this.FID,"end\n\n");
            end
        end

        function updateSupportingFcnsImpl(this)


            if this.Component.includeSupportingFunctions
                fprintf(this.FID,"%% Update Supporting functions DOM FormalTable object.\n");


                fprintf(this.FID,"rptMLFcnSuppFcnsTblIdx = ...\n");
                fprintf(this.FID,...
                'arrayfun(@(x) strcmp(x.StyleName,"MATLABFunctionSupportingFunctionsTable"),rptMLFcnDOMTables);\n');
                fprintf(this.FID,"if any(rptMLFcnSuppFcnsTblIdx)\n");
                fprintf(this.FID,...
                "rptMLFcnSuppFcnsTbl = rptMLFcnDOMTables(rptMLFcnSuppFcnsTblIdx);\n");


                fprintf(this.FID,...
                'rptMLFcnSuppFcnsTbl.Header.entry(1,1).Children.Content = "%s";\n',...
                this.Component.SupportFcnTableNameColHeader);
                fprintf(this.FID,...
                'rptMLFcnSuppFcnsTbl.Header.entry(1,2).Children.Content = "%s";\n',...
                this.Component.SupportFcnTableDefinedByColHeader);
                fprintf(this.FID,...
                'rptMLFcnSuppFcnsTbl.Header.entry(1,3).Children.Content = "%s";\n',...
                this.Component.SupportFcnTablePathColHeader);


                fcnNameColWidth=this.Component.SupportFcnTableNameColWidth;
                definedByColWidth=this.Component.SupportFcnTableDefinedByColWidth;
                pathColWidth=this.Component.SupportFcnTablePathColWidth;
                totalWidth=fcnNameColWidth+definedByColWidth+pathColWidth;
                fcnNameColPercentWidth=...
                strcat(num2str(fcnNameColWidth/totalWidth*100),"%");
                definedByColPercentWidth=...
                strcat(num2str(definedByColWidth/totalWidth*100),"%");
                pathColPercentWidth=...
                strcat(num2str(pathColWidth/totalWidth*100),"%");
                fprintf(this.FID,"rptMLFcnSuppFcnsTblGrps(1) = TableColSpecGroup;\n");
                fprintf(this.FID,"specs(1) = TableColSpec;\n");
                fprintf(this.FID,'specs(1).Style = {Width("%s")};\n',fcnNameColPercentWidth);
                fprintf(this.FID,"specs(2) = TableColSpec;\n");
                fprintf(this.FID,'specs(2).Style = {Width("%s")};\n',definedByColPercentWidth);
                fprintf(this.FID,"specs(3) = TableColSpec;\n");
                fprintf(this.FID,'specs(3).Style = {Width("%s")};\n',pathColPercentWidth);
                fprintf(this.FID,"rptMLFcnSuppFcnsTblGrps(1).ColSpecs = specs;\n");
                fprintf(this.FID,"rptMLFcnSuppFcnsTbl.ColSpecGroups = rptMLFcnSuppFcnsTblGrps;\n");

                fprintf(this.FID,"end\n");
            end
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_emlfcn
            templateFolder=fullfile(rptgen_sl_csl_emlfcn.getClassFolder,...
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