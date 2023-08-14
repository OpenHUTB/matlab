classdef rptgen_sl_csl_ccaller<mlreportgen.rpt2api.ComponentConverter&slreportgen.rpt2api.rptgen_sl_csl_c_blk_base



























    methods

        function obj=rptgen_sl_csl_ccaller(component,rptFileConverter)
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
                fprintf(this.FID,"rptCCallerTarget = rptState.CurrentModelHandle;\n");
                fprintf(this.FID,"rptCCallerFinder = BlockFinder(Container=rptCCallerTarget, ...\n");
                fprintf(this.FID,"BlockTypes=""CCaller"",SearchDepth=Inf);");
                fprintf(this.FID,'rptCCallerBlks = find(rptCCallerFinder);\n');
            elseif(strcmpi(loopContext,"rptgen_sl.csl_sys_loop"))
                fprintf(this.FID,"rptCCallerTarget = rptState.CurrentSystem.Object;\n");
                fprintf(this.FID,"rptCCallerFinder = BlockFinder(Container=rptCCallerTarget, ...\n");
                fprintf(this.FID,"BlockTypes=""CCaller"",SearchDepth=Inf);");
                fprintf(this.FID,'rptCCallerBlks = find(rptCCallerFinder);\n');
            elseif(strcmpi(loopContext,"rptgen_sl.csl_blk_loop"))
                fprintf(this.FID,'if(strcmpi(rptState.CurrentBlock.Type,"CCaller"))\n');
                fprintf(this.FID,"rptCCallerBlks = rptState.CurrentBlock;\n");
                fprintf(this.FID,"else\n");
                fprintf(this.FID,'rptCCallerBlks = [];\n');
                fprintf(this.FID,'end\n');
            else
                return;
            end

            fprintf(this.FID,"for rptCCallerIdx=1:length(rptCCallerBlks)\n");
            fprintf(this.FID,"%s = CCaller(rptCCallerBlks(rptCCallerIdx));\n",varName);
            fprintf(this.FID,"%s.IncludeObjectProperties = %d;\n",varName,this.Component.includeFcnProps);
            fprintf(this.FID,"%s.IncludeAvailableFunctions = %d;\n",varName,this.Component.includeAvailableFunctions);
            fprintf(this.FID,"%s.IncludeCode = %d;\n",varName,this.Component.includeCode);

            if(this.Component.includeAvailableFunctions)
                if(this.Component.availableFunctionsListType==1)
                    fprintf(this.FID,"%s.AvailableFunctionsListFormatter = mlreportgen.dom.UnorderedList;\n",varName);
                else
                    fprintf(this.FID,"%s.AvailableFunctionsListFormatter = mlreportgen.dom.OrderedList;\n",varName);
                end
            end

            if(strcmpi(this.Component.PortSpecificationTableTitleType,'manual'))
                fprintf(this.FID,'%s.PortSpecificationReporter.Title = "%s";\n',varName,this.Component.PortSpecificationTableTitle);
            end

            if~this.Component.hasBorderPortSpecificationTable


                registerHelperFunction(this.RptFileConverter,"removeTableGrids");

                fprintf(this.FID,"%s.PortSpecificationReporter.TableEntryUpdateFcn = @removeTableGrids;\n",...
                varName);
            end

            if(this.Component.spansPagePortSpecificationTable)
                fprintf(this.FID,'%s.PortSpecificationReporter.TableWidth = "100%%";\n',varName);
            else
                fprintf(this.FID,'%s.PortSpecificationReporter.TableWidth = [];\n',varName);
            end

            writeObjectProperties(this,varName);
            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,'append(%s,%s);\n',parentName,varName);
            fprintf(this.FID,"end\n\n");



            writeEndBanner(this);
        end

        function writeTypeAndName(this)
            fprintf(this.FID,'rptCBlockHeaderName = rptCCallerBlks(rptCCallerIdx).Name;\n');
            fprintf(this.FID,'rptCBlockType = "CCaller";\n');
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptCCaller";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_ccaller.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_ccaller
            templateFolder=fullfile(rptgen_sl_csl_ccaller.getClassFolder,...
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


