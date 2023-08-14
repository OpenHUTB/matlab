classdef rptgen_sl_csl_blk_sort_list<mlreportgen.rpt2api.ComponentConverter































    methods

        function this=rptgen_sl_csl_blk_sort_list(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            allowedContextList=["rptgen_sl.csl_mdl_loop",...
            "rptgen_sl.csl_sys_loop"];
            ctx=getContext(this,allowedContextList);
            if strcmp(ctx,"")
                fprintf(this.FID,"%% Skipping Block Execution Order List component that is not in a model or system loop\n\n");
                return;
            end



            writeStartBanner(this);

            stateVariable=this.RptStateVariable;
            if strcmp(ctx,"rptgen_sl.csl_sys_loop")
                fprintf(this.FID,"rptExecutionOrderSystem = %s.CurrentSystem.Path;\n",stateVariable);
                fprintf(this.FID,"%% Only report the execution order of models and nonvirtual subsystems\n");
                fprintf(this.FID,"if isModel(rptExecutionOrderSystem) || ...\n");
                fprintf(this.FID,"strcmp(get_param(rptExecutionOrderSystem,""IsSubsystemVirtual""),""off"")\n");
                writeEOReporter(this,"rptExecutionOrderSystem",ctx);
                fprintf(this.FID,"end\n");
            else
                writeEOReporter(this,stateVariable+".CurrentModelHandle",ctx);
            end

            fprintf(this.FID,"\n");



            writeEndBanner(this);
        end

        function name=getVariableRootName(~)





            name="rptExecutionOrder";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_blk_sort_list.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end
    end

    methods(Access=private)

        function writeEOReporter(this,systemVarName,ctx)


            import mlreportgen.rpt2api.exprstr.Parser

            cmpn=this.Component;
            varName=getVariableName(this);
            parentName=this.RptFileConverter.VariableNameStack.top;
            titleParaSuffix=extractAfter(varName,getVariableRootName(this));
            titleParaVarName=getVariableRootName(this)+"Title"+titleParaSuffix;

            fprintf(this.FID,"%% Create a paragraph for the execution order title\n");
            if strcmp(this.Component.ListTitleMode,"auto")
                fprintf(this.FID,"rptEOSystemName = getfullname(%s);\n",systemVarName);
                fprintf(this.FID,'rptTitleParaContent = sprintf("Sorted List for ""%%s""",rptEOSystemName);\n');
            else
                titleStr=cmpn.ListTitle;
                if regexp(titleStr,'.*%<.+>')
                    p=Parser(titleStr);
                    parse(p);
                    fprintf(this.FID,"%% Converted from: %s\n",strrep(p.ExprStr,newline,'\n'));
                    fprintf(this.FID,"rptTitleParaContent = """+p.FormatString+""";\n",p.Expressions{:});
                else
                    fprintf(this.FID,"rptTitleParaContent = """+titleStr+""";\n");
                end
            end
            fprintf(this.FID,"%s = Paragraph(rptTitleParaContent);\n",titleParaVarName);
            fprintf(this.FID,"%s.StyleName = ""ExecutionOrderLabel"";\n",titleParaVarName);
            fprintf(this.FID,"%% Append the title to the report\n");
            fprintf(this.FID,"append(%s,%s);\n\n",parentName,titleParaVarName);


            fprintf(this.FID,"%% Create an ExecutionOrder reporter\n");
            fprintf(this.FID,"%s = ExecutionOrder(%s);\n",...
            varName,systemVarName);

            fprintf(this.FID,"%% Set reporter properties\n");
            fprintf(this.FID,"%s.ShowBlockType = %d;\n",varName,cmpn.isBlockType);
            switch cmpn.FollowNonVirtual
            case "on"
                fprintf(this.FID,"%s.IncludeSubsystemBlocks = true;\n",...
                varName);
                fprintf(this.FID,"%s.SubsystemBlocksDisplayPolicy = ""NestedList"";\n",...
                varName);
            case "off"
                fprintf(this.FID,"%s.IncludeSubsystemBlocks = false;\n",...
                varName);
            otherwise
                if strcmp(ctx,"rptgen_sl.csl_sys_loop")
                    fprintf(this.FID,"%s.IncludeSubsystemBlocks = false;\n",...
                    varName);
                else
                    fprintf(this.FID,"%s.IncludeSubsystemBlocks = true;\n",...
                    varName);
                    fprintf(this.FID,"%s.SubsystemBlocksDisplayPolicy = ""NestedList"";\n",...
                    varName);
                end
            end


            fprintf(this.FID,"append(%s,%s);\n",parentName,varName);
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_blk_sort_list
            templateFolder=fullfile(rptgen_sl_csl_blk_sort_list.getClassFolder,...
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