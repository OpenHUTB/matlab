classdef rptgen_sl_csl_prop_table<mlreportgen.rpt2api.ComponentConverter






























    properties(Access=private)


        CurrentObj;
    end

    methods
        function this=rptgen_sl_csl_prop_table(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end
    end

    methods(Access=protected)

        function write(this)



            writeStartBanner(this);

            objectType=this.Component.ObjectType;
            stateVariable=this.RptStateVariable;

            allowedContextList=["rptgen_sl.csl_mdl_loop",...
            "rptgen_sl.csl_sys_loop","rptgen_sl.csl_blk_loop",...
            "rptgen_sl.csl_sig_loop","rptgen_sl.CAnnotationLoop"];

            context=getContext(this,allowedContextList);

            if strcmp(context,"rptgen_sl.csl_mdl_loop")
                writePropTableInModelLoopContext(this,objectType,stateVariable)

            elseif strcmp(context,"rptgen_sl.csl_sys_loop")
                writePropTableInSystemLoopContext(this,objectType,stateVariable);

            elseif strcmp(context,"rptgen_sl.csl_blk_loop")
                writePropTableInBlockLoopContext(this,objectType,stateVariable);

            elseif strcmp(context,"rptgen_sl.csl_sig_loop")
                writePropTableInSignalLoopContext(this,objectType,stateVariable);

            elseif strcmp(context,"rptgen_sl.CAnnotationLoop")
                writePropTableInAnnotationLoopContext(this,objectType,stateVariable);
            end




            writeEndBanner(this);
        end

        function writePropNames(this)





            propNames=arrayfun(@(cell)sprintf('%s',getPropName(this,cell.Text)),...
            this.Component.TableContent,'UniformOutput',false);

            fwrite(this.FID,"% Create a string array that specifies the names of object properties"+newline);
            fwrite(this.FID,"% to be reported."+newline);
            fprintf(this.FID,...
            'rptReportedProperties%d = [%s];\n',this.getVariableNameCounter,strtrim(sprintf('"%s" ',propNames{:})));
        end

        function propName=getPropName(~,name)


            import mlreportgen.rpt2api.exprstr.Parser

            parser=Parser(name);
            parse(parser);

            if~isempty(parser.Expressions)







                propName=string(parser.Expressions{1});
            else
                propName="";
            end
        end

        function appendPropertyTable(this)



            varName=this.getVariableName;
            parentName=this.RptFileConverter.VariableNameStack.top;

            fprintf(this.FID,"append(%s,%s);\n\n",parentName,varName);
        end

        function writeSLPropertyTable(this,slObj)




            varName=this.getVariableName;


            fwrite(this.FID,"% Create a reporter that generates a table listing the property values"+newline);
            fwrite(this.FID,"% of the specified Simulink object."+newline);
            fprintf(this.FID,"%s = SimulinkObjectProperties(%s);\n\n",varName,slObj);


            titleVarName=strcat(varName,"Title");
            writeBaseTableTitle(this,varName,titleVarName);



            writePropNames(this);
            fprintf(this.FID,"%s.Properties = rptReportedProperties%d;\n\n",...
            varName,this.getVariableNameCounter);


            fprintf(this.FID,"%s.ShowEmptyValues = true;\n",varName);

        end

        function writeBaseTableTitle(this,varName,titleVarName)


            import mlreportgen.rpt2api.exprstr.Parser

            name=this.Component.TableTitle.Text;
            parser=Parser(name);
            parse(parser);
            propName=parser.Expressions;

            if~isempty(propName)
                fprintf(this.FID,...
                "rptPropName = safeGet(%s,""%s"");\n",...
                this.CurrentObj,propName{1});
                fprintf(this.FID,...
                "%s = strrep(sprintf(""%s"",rptPropName{1}),newline,' ');\n",titleVarName,...
                parser.FormatString);
            else
                Parser.writeExprStr(this.FID,name,titleVarName);
            end
            fwrite(this.FID,"% Set the title of the reporter."+newline);
            fprintf(this.FID,...
            "%s.PropertyTable.Title = %s;\n\n",varName,titleVarName);
        end

        function writePropTableInModelLoopContext(this,objectType,stateVariable)



            currentMdlHdlVarName=strcat(stateVariable,".","CurrentModelHandle");

            switch(objectType)

            case "Model"




                this.CurrentObj=currentMdlHdlVarName;


                writeSLPropertyTable(this,currentMdlHdlVarName);


                appendPropertyTable(this);

            case{"Signal","Annotation","System"}

                if strcmp(objectType,"System")
                    fwrite(this.FID,"% Create a finder to find systems in the current model"+newline);
                    fprintf(this.FID,"rptFinder = SystemDiagramFinder(%s);\n",currentMdlHdlVarName);
                elseif strcmp(objectType,"Signal")
                    fwrite(this.FID,"% Create a finder to find signals in the current model"+newline);
                    fprintf(this.FID,"rptFinder = SignalFinder(%s);\n",currentMdlHdlVarName);
                else
                    fwrite(this.FID,"% Create a finder to find annotations in the current model"+newline);
                    fprintf(this.FID,"rptFinder = AnnotationFinder(%s);\n",currentMdlHdlVarName);
                end

                fwrite(this.FID,"rptResults = find(rptFinder);"+newline);
                fwrite(this.FID,"% Loop through the list of results to be reported."+newline);
                fwrite(this.FID,"rptN = numel(rptResults);"+newline);
                fwrite(this.FID,"for rptI = 1:rptN"+newline);
                fprintf(this.FID,"rptCurrentResultObject%d = rptResults(rptI);\n",this.getVariableNameCounter);

                currentResultObject=strcat("rptCurrentResultObject",num2str(this.getVariableNameCounter),".Object");




                this.CurrentObj=currentResultObject;


                writeSLPropertyTable(this,currentResultObject);


                appendPropertyTable(this);

                fwrite(this.FID,"end"+newline);

            case "Block"


            end
        end

        function writePropTableInSystemLoopContext(this,objectType,stateVariable)



            contextName="CurrentSystem";
            currentResultObject=strcat("rptCurrentResultObject",num2str(this.getVariableNameCounter),".Object");

            switch(objectType)

            case{"System","Model"}

                if strcmp(objectType,"System")

                    fprintf(this.FID,"rptCurrentResultObject%d = %s.%s;\n",this.getVariableNameCounter,stateVariable,contextName);




                    this.CurrentObj=currentResultObject;


                    writeSLPropertyTable(this,currentResultObject);
                else
                    currentMdlHdlVarName="rptCurrentModelHandle";
                    fprintf(this.FID,"%s = slreportgen.utils.getModelHandle(%s.%s);\n",currentMdlHdlVarName,stateVariable,contextName);




                    this.CurrentObj=currentMdlHdlVarName;


                    writeSLPropertyTable(this,currentMdlHdlVarName);
                end


                appendPropertyTable(this);

            case{"Signal","Annotation"}

                if strcmp(objectType,"Signal")
                    fwrite(this.FID,"% Create a finder to find signals in the current system"+newline);
                    fprintf(this.FID,"rptFinder = SignalFinder(%s.%s.Object);\n",stateVariable,contextName);
                else
                    fwrite(this.FID,"% Create a finder to find annotations in the current system"+newline);
                    fprintf(this.FID,"rptFinder = AnnotationFinder(%s.%s.Object);\n",stateVariable,contextName);
                end

                fwrite(this.FID,"rptResults = find(rptFinder);"+newline);
                fwrite(this.FID,"rptN = numel(rptResults);"+newline);
                fwrite(this.FID,"for rptI = 1:rptN"+newline);
                fprintf(this.FID,"rptCurrentResultObject%d = rptResults(rptI);\n",this.getVariableNameCounter);




                this.CurrentObj=currentResultObject;


                writeSLPropertyTable(this,currentResultObject);


                appendPropertyTable(this);

                fprintf(this.FID,"end\n");
            case "Block"



            end
        end

        function writePropTableInBlockLoopContext(this,objectType,stateVariable)




            contextName="CurrentBlock";
            switch(objectType)

            case{"Model","Block"}

                if strcmp(objectType,"Model")

                    currentMdlHdlVarName="rptCurrentModelHandle";
                    fprintf(this.FID,"%s = slreportgen.utils.getModelHandle(%s.%s);\n",currentMdlHdlVarName,stateVariable,contextName);




                    this.CurrentObj=currentMdlHdlVarName;


                    writeSLPropertyTable(this,currentMdlHdlVarName);
                else
                    currentBlockVarName="rptCurrentBlockObject";
                    fprintf(this.FID,"%s = %s.CurrentBlock.Object;\n",currentBlockVarName,stateVariable);

                    this.CurrentObj=currentBlockVarName;


                    writeSLPropertyTable(this,currentBlockVarName);
                end

                appendPropertyTable(this);

            case{"Signal","Annotation","System"}


            end
        end

        function writePropTableInSignalLoopContext(this,objectType,stateVariable)




            contextName="CurrentSignal";

            switch(objectType)

            case "Model"

                if strcmp(objectType,"Model")
                    currentMdlHdlVarName="rptCurrentModelHandle";
                    fprintf(this.FID,"%s = slreportgen.utils.getModelHandle(%s.%s);\n",currentMdlHdlVarName,stateVariable,contextName);




                    this.CurrentObj=currentMdlHdlVarName;


                    writeSLPropertyTable(this,currentMdlHdlVarName);

                    appendPropertyTable(this);
                end

            case "Signal"
                fprintf(this.FID,"rptCurrentResultObject%d = %s.%s;\n",this.getVariableNameCounter,stateVariable,contextName);
                currentResultObject=strcat("rptCurrentResultObject",num2str(this.getVariableNameCounter),".Object");




                this.CurrentObj=currentResultObject;


                writeSLPropertyTable(this,currentResultObject);

                appendPropertyTable(this);

            case{"Block","System","Annotation"}


            end

        end

        function writePropTableInAnnotationLoopContext(this,objectType,stateVariable)




            contextName="CurrentAnnotation";
            switch(objectType)

            case{"Model","Annotation"}

                if strcmp(objectType,"Model")

                    currentMdlHdlVarName="rptCurrentModelHandle";
                    fprintf(this.FID,"%s = slreportgen.utils.getModelHandle(%s.%s);\n",currentMdlHdlVarName,stateVariable,contextName);




                    this.CurrentObj=currentMdlHdlVarName;


                    writeSLPropertyTable(this,currentMdlHdlVarName);
                else

                    fprintf(this.FID,"rptCurrentResultObject%d = %s.%s;\n",this.getVariableNameCounter,stateVariable,contextName);
                    currentResultObject=strcat("rptCurrentResultObject",num2str(this.getVariableNameCounter),".Object");




                    this.CurrentObj=currentResultObject;


                    writeSLPropertyTable(this,currentResultObject);
                end

                appendPropertyTable(this);

            case{"System","Block","Signal"}


            end

        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_prop_table.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

        function name=getVariableRootName(this)






            objectType=string(this.Component.ObjectType);
            if strcmp(objectType,"Model")
                name="rptModelPropTable";
            elseif strcmp(objectType,"System")
                name="rptSystemPropTable";
            elseif strcmp(objectType,"Block")
                name="rptBlockPropTable";
            elseif strcmp(objectType,"Signal")
                name="rptSignalPropTable";
            else
                name="rptAnnotationPropTable";
            end
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_prop_table
            templateFolder=fullfile(rptgen_sl_csl_prop_table.getClassFolder,...
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
