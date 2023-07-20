classdef rptgen_sl_csl_auto_table<mlreportgen.rpt2api.ComponentConverter&slreportgen.rpt2api.rptgen_sl_rpt_auto_table



























    properties(Access=protected)
        autoTableObjectType="rptSlAutoTableObjectType";
        autoTableHeaderName="rptSlAutoTableName";
        autoTableObjectTarget="rptSlAutoTableTarget";
    end

    methods

        function obj=rptgen_sl_csl_auto_table(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)



            writeStartBanner(this);

            autoTableVarName=getVariableName(this);
            allowedContextList=["rptgen_sl.csl_sys_loop","rptgen_sl.csl_mdl_loop","rptgen_sl.csl_blk_loop",...
            "rptgen_sl.csl_sig_loop","rptgen_sl.CAnnotationLoop"];
            loopContext=getContext(this,allowedContextList);

            isAutoType=strcmpi(this.Component.ObjectType,'auto');
            if((isAutoType&&strcmpi(loopContext,"rptgen_sl.csl_mdl_loop"))...
                ||strcmpi(this.Component.ObjectType,'model'))
                fprintf(this.FID,"%s = rptState.CurrentModelHandle;\n",this.autoTableObjectTarget);
            elseif((isAutoType&&strcmpi(loopContext,"rptgen_sl.csl_sys_loop"))...
                ||strcmpi(this.Component.ObjectType,'system'))
                fprintf(this.FID,"%s = rptState.CurrentSystem.Object;\n",this.autoTableObjectTarget);
            elseif((isAutoType&&strcmpi(loopContext,"rptgen_sl.csl_blk_loop"))...
                ||strcmpi(this.Component.ObjectType,'block'))
                fprintf(this.FID,"%s = rptState.CurrentBlock.Object;\n",this.autoTableObjectTarget);
            elseif((isAutoType&&strcmpi(loopContext,"rptgen_sl.csl_sig_loop"))...
                ||strcmpi(this.Component.ObjectType,'signal'))
                fprintf(this.FID,"%s = rptState.CurrentSignal.Object;\n",this.autoTableObjectTarget);
            elseif((isAutoType&&strcmpi(loopContext,"rptgen_sl.CAnnotationLoop"))...
                ||strcmpi(this.Component.ObjectType,'annotation'))
                fprintf(this.FID,"%s = rptState.CurrentAnnotation.Object;\n",this.autoTableObjectTarget);
            else
                return;
            end

            fprintf(this.FID,'%s = slreportgen.utils.getObjectType(%s);\n',...
            this.autoTableObjectType,this.autoTableObjectTarget);
            if(this.Component.ShowFullName)
                fprintf(this.FID,'%s = slreportgen.utils.getDiagramPath(%s);\n',...
                this.autoTableHeaderName,this.autoTableObjectTarget);
            else
                fprintf(this.FID,'%s = mlreportgen.utils.safeGet(%s, "name");\n',...
                this.autoTableHeaderName,this.autoTableObjectTarget);
                fprintf(this.FID,'%s = mlreportgen.utils.normalizeString(%s{:});\n',this.autoTableHeaderName,this.autoTableHeaderName);
            end

            fprintf(this.FID,"if(~isempty(%s))\n",this.autoTableObjectTarget);
            fprintf(this.FID,"%s = SimulinkObjectProperties(%s);\n",autoTableVarName,this.autoTableObjectTarget);

            fprintf(this.FID,"%s.ShowPromptNames = %d;\n",autoTableVarName,this.Component.ShowNamePrompt);

            if(strcmpi(this.Component.PropertyListMode,'manual'))
                numPropertyList=length(this.Component.PropertyList);
                fprintf(this.FID,"rptSlAutoTablePropertyList = [");
                for idx=1:numPropertyList
                    fprintf(this.FID,'"%s",',this.Component.PropertyList{idx});
                end
                fprintf(this.FID,"];\n");
                fprintf(this.FID,"%s.Properties = rptSlAutoTablePropertyList;\n",autoTableVarName);
            else
                fprintf(this.FID,'rptSlAutoTableParams = slreportgen.utils.getSimulinkObjectParameters(%s,%s);\n',...
                this.autoTableObjectTarget,this.autoTableObjectType);
                fprintf(this.FID,"%s.Properties = string(rptSlAutoTableParams(:))';\n\n",autoTableVarName);
            end

            this.writeAutoTableProperties(autoTableVarName);
            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,'append(%s,%s);\n',parentName,autoTableVarName);
            fprintf(this.FID,"end\n\n");



            writeEndBanner(this);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptSlAutoTable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_auto_table.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_auto_table
            templateFolder=fullfile(rptgen_sl_csl_auto_table.getClassFolder,...
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


