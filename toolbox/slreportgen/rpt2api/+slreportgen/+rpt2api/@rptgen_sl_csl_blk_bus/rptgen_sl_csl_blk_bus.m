classdef rptgen_sl_csl_blk_bus<mlreportgen.rpt2api.ComponentConverter





























    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_blk_loop",...
        "csl_sig_loop"];

        SkippedContexts=["rptgen_sl.CAnnotationLoop",...
        "rptgen_sl.csl_ws_var_loop"]
    end

    methods

        function obj=rptgen_sl_csl_blk_bus(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            context=getContext(this,[this.SupportedContexts,this.SkippedContexts]);
            if ismember(context,this.SkippedContexts)
                fprintf(this.FID,"% Bus List with %s parent skipped.\n\n",context);
                return
            end

            writeStartBanner(this);

            switch context
            case "rptgen_sl.csl_mdl_loop"
                writeBusReporter(this,this.RptStateVariable+".CurrentModelHandle");

            case "rptgen_sl.csl_sys_loop"
                writeBusReporter(this,this.RptStateVariable+".CurrentSystem");

            case "rptgen_sl.csl_sig_loop"
                writeBusReporter(this,this.RptStateVariable+".CurrentSignal");

            case "rptgen_sl.csl_blk_loop"
                writeBusReporter(this,this.RptStateVariable+".CurrentBlock");

            otherwise

                fwrite(this.FID,"% Report on all Bus Selectors in all open models"+newline);
                fwrite(this.FID,"rptBusModelList = find_system( ..."+newline);
                fwrite(this.FID,"SearchDepth=0, ..."+newline);
                fwrite(this.FID,"type=""block_diagram"", ..."+newline);
                fwrite(this.FID,"BlockDiagramType=""model"");"+newline+newline);
                fwrite(this.FID,"% Loop through open models"+newline);
                fwrite(this.FID,"rptN = numel(rptBusModelList);"+newline);
                fwrite(this.FID,"for rptI = 1:rptN"+newline);
                writeBusReporter(this,"rptBusModelList{rptI}");
                fwrite(this.FID,"end"+newline+newline);

            end

            writeEndBanner(this);
        end

        function writeBusReporter(this,constructorArg)
            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);
            parentName=this.RptFileConverter.VariableNameStack.top;

            fprintf(this.FID,"%% Create a Bus reporter\n");
            fprintf(this.FID,"%s = Bus(%s);\n",...
            varName,constructorArg);

            fprintf(this.FID,"%% Set reporter options\n");
            fprintf(this.FID,"%s.ReportedBlockType = [""BusSelector"",""Inport""];\n",varName);

            if this.Component.isHierarchy

                fprintf(this.FID,"%s.IncludeNestedBuses = true;\n",varName);
            end

            listTitle=this.Component.ListTitle;
            if~strcmp(listTitle,"")
                if regexp(listTitle,'.*%<.+>')
                    p=Parser(listTitle);
                    parse(p);
                    fprintf(this.FID,"%% Converted from: %s\n",strrep(p.ExprStr,newline,'\n'));
                    fprintf(this.FID,"rptBusListTitleContent = "+p.FormatString+";\n",p.Expressions{:});
                else
                    fwrite(this.FID,"rptBusListTitleContent = """+listTitle+""";"+newline);
                end
                fprintf(this.FID,"%s.Title = rptBusListTitleContent;\n",varName);
            end

            fprintf(this.FID,"append(%s,%s);\n",parentName,varName);


            fprintf(this.FID,"\n");
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptBusList";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_blk_bus.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_blk_bus
            templateFolder=fullfile(rptgen_sl_csl_blk_bus.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,strcat(templateName,".txt"));
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

