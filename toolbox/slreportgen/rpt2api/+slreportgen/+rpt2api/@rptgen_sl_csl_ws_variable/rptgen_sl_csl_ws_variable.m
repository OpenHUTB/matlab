classdef rptgen_sl_csl_ws_variable<mlreportgen.rpt2api.ComponentConverter





























    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop",...
        "csl_blk_loop",...
        "csl_ws_var_loop"];

        SkippedContexts=["rptgen_sl.CAnnotationLoop",...
        "rptgen_sl.csl_sig_loop"]
    end

    methods

        function obj=rptgen_sl_csl_ws_variable(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)



            context=getContext(this,[this.SupportedContexts,this.SkippedContexts]);
            if ismember(context,this.SkippedContexts)
                fprintf(this.FID,"% Simulink Workspace Variable with %s parent skipped.\n\n",context);
                return
            end

            writeStartBanner(this);
            varName=getVariableName(this);
            parentName=this.RptFileConverter.VariableNameStack.top;
            if strcmp(context,"rptgen_sl.csl_ws_var_loop")
                fprintf(this.FID,"%% Get the reporter from the current model variable\n");
                fprintf(this.FID,"%s = getReporter(%s.CurrentModelVariable);\n",varName,this.RptStateVariable);
                writeReporterProperties(this,varName);


                fprintf(this.FID,'append(%s,%s);\n\n',parentName,varName);
            else

                wsLoop=slreportgen.rpt2api.rptgen_sl_csl_ws_var_loop(this.Component,this.RptFileConverter);
                wsLoop.Context=context;
                varListName="rptWSVarList";
                writeVariableList(wsLoop,varListName,false);


                fwrite(this.FID,"% Loop through list of variables to be reported."+newline);
                fprintf(this.FID,"rptNWSVar = numel(%s);\n",varListName);
                fprintf(this.FID,"%s = ModelVariable.empty(1,0);\n",varName);
                fprintf(this.FID,"for rptIWSVar = 1:rptNWSVar\n");
                fprintf(this.FID,"rptWSVarCurrentVariable = %s(rptIWSVar);\n",...
                varListName);
                fprintf(this.FID,"%% Get the reporter for the current variable\n");



                currReporterName=varName+"(rptIWSVar)";
                fprintf(this.FID,"%s = getReporter(rptWSVarCurrentVariable);\n",currReporterName);
                writeReporterProperties(this,currReporterName);


                fprintf(this.FID,'append(%s,%s);\n',parentName,currReporterName);
                fprintf(this.FID,"end\n\n");
            end

            writeEndBanner(this);
        end

        function writeReporterProperties(this,varName)
            fprintf(this.FID,"%% Set options for ModelVariable reporter\n");
            fprintf(this.FID,"%s.ShowWorkspaceInfo = %d;\n",varName,this.Component.ShowWorkspace);
            fprintf(this.FID,"%s.ShowUsedBy = %d;\n",varName,this.Component.ShowUsedByBlocks);

            if this.Component.customFilteringEnabled
                fprintf(this.FID,"%s.PropertyFilterFcn = ""%s"";\n\n",...
                varName,this.Component.customFilteringCode);
            elseif~this.Component.filteredPropHash.isempty


                propertiesMap=this.Component.filteredPropHash;
                filterTerms=string.empty(1,0);
                filterClasses=propertiesMap.keys;



                starKeyIdx=strcmp(filterClasses,"*");
                filterClasses(starKeyIdx)=[];
                if any(starKeyIdx)&&~isempty(propertiesMap("*"))
                    props=string(propertiesMap("*"));
                    filterTerms=strcat("strcmpi(propertyName,""",props,""")");
                end

                nFilterClasses=numel(filterClasses);
                for idx=1:nFilterClasses
                    filterClass=filterClasses{idx};
                    props=string(propertiesMap(filterClass));
                    classFilterStr=sprintf("isa(variableObject,""%s"") && ...\n(",filterClass);
                    classFilterTerms=strcat("strcmpi(propertyName,""",props,""")");
                    fullFilterTerm=classFilterStr...
                    +strjoin(classFilterTerms,"|| ..."+newline)...
                    +")";
                    filterTerms(end+1)=fullFilterTerm;%#ok<AGROW>
                end


                fprintf(this.FID,"%s.PropertyFilterFcn = @(variableName,variableObject,propertyName)...\n",varName);
                filterFcnBody=strjoin(filterTerms," || ..."+newline);
                fprintf(this.FID,"%s;\n",filterFcnBody);
            end

            fprintf(this.FID,"\n");
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptSimulinkVariable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_ws_variable.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_ws_variable
            templateFolder=fullfile(rptgen_sl_csl_ws_variable.getClassFolder,...
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

