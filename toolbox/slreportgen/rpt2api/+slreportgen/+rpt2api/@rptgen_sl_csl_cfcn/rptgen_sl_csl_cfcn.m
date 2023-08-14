classdef rptgen_sl_csl_cfcn<mlreportgen.rpt2api.ComponentConverter&slreportgen.rpt2api.rptgen_sl_csl_c_blk_base



























    methods

        function obj=rptgen_sl_csl_cfcn(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)



            writeStartBanner(this);

            varName=getVariableName(this);
            allowedContextList=["rptgen_sl.csl_sys_loop","rptgen_sl.csl_mdl_loop","rptgen_sl.csl_blk_loop"];
            loopContext=getContext(this,allowedContextList);

            if(strcmpi(loopContext,"rptgen_sl.csl_mdl_loop"))
                fprintf(this.FID,"rptCFcnTarget = rptState.CurrentModelHandle;\n");
                fprintf(this.FID,"rptCFcnFinder = BlockFinder(Container=rptCFcnTarget, ...\n");
                fprintf(this.FID,"BlockTypes=""CFunction"",SearchDepth=Inf);");
                fprintf(this.FID,'rptCFcnBlks = find(rptCFcnFinder);\n');
            elseif(strcmpi(loopContext,"rptgen_sl.csl_sys_loop"))
                fprintf(this.FID,"rptCFcnTarget = rptState.CurrentSystem.Object;\n");
                fprintf(this.FID,"rptCFcnFinder = BlockFinder(Container=rptCFcnTarget, ...\n");
                fprintf(this.FID,"BlockTypes=""CFunction"",SearchDepth=Inf);");
                fprintf(this.FID,'rptCFcnBlks = find(rptCFcnFinder);\n');
            elseif(strcmpi(loopContext,"rptgen_sl.csl_blk_loop"))
                fprintf(this.FID,'if strcmpi(rptState.CurrentBlock.Type,"CFunction")\n');
                fprintf(this.FID,"rptCFcnBlks = rptState.CurrentBlock;\n");
                fprintf(this.FID,"else\n");
                fprintf(this.FID,'rptCFcnBlks = [];\n');
                fprintf(this.FID,'end\n');
            else
                return;
            end

            fprintf(this.FID,"for rptCFcnIdx=1:length(rptCFcnBlks)\n");
            fprintf(this.FID,"%s = CFunction(rptCFcnBlks(rptCFcnIdx));\n",varName);
            fprintf(this.FID,"%s.IncludeObjectProperties = %d;\n",varName,this.Component.includeFcnProps);
            fprintf(this.FID,"%s.IncludeSymbols = %d;\n",varName,this.Component.includeSymbolsTable);
            fprintf(this.FID,"%s.IncludeOutputCode = %d;\n",varName,this.Component.includeOutputCode);
            fprintf(this.FID,"%s.IncludeStartCode = %d;\n",varName,this.Component.includeStartCode);
            fprintf(this.FID,"%s.IncludeTerminateCode = %d;\n",varName,this.Component.includeTerminateCode);

            if(this.Component.includeSymbolsTable)
                if(strcmpi(this.Component.SymbolsTableTitleType,'manual'))
                    fprintf(this.FID,'%s.SymbolsReporter.Title = "%s";\n',varName,this.Component.SymbolsTableTitle);
                end

                if~this.Component.hasBorderSymbolsTable


                    registerHelperFunction(this.RptFileConverter,"removeTableGrids");

                    fprintf(this.FID,"%s.SymbolsReporter.TableEntryUpdateFcn = @removeTableGrids;\n",...
                    varName);
                end

                if(this.Component.spansPageSymbolsTable)
                    fprintf(this.FID,'%s.SymbolsReporter.TableWidth = "100%%";\n',varName);
                end
            end

            writeObjectProperties(this,varName);
            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,'append(%s,%s);\n',parentName,varName);
            fprintf(this.FID,"end\n\n");



            writeEndBanner(this);
        end

        function writeTypeAndName(this)
            fprintf(this.FID,'rptCBlockHeaderName = rptCFcnBlks(rptCFcnIdx).Name;\n');
            fprintf(this.FID,'rptCBlockType = "CFunction";\n');
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptCFcn";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_cfcn.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_cfcn
            templateFolder=fullfile(rptgen_sl_csl_cfcn.getClassFolder,...
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


