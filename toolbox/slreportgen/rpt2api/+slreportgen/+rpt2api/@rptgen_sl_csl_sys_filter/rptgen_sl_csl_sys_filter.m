classdef rptgen_sl_csl_sys_filter<mlreportgen.rpt2api.ComponentConverter



























    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop"];
    end

    methods

        function this=rptgen_sl_csl_sys_filter(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sl_csl_sys_filter



            context=getContext(this,this.SupportedContexts);
            if strcmp(context,"")
                fprintf(this.FID,"% Skipping system filter component with no model or system loop parent\n\n",context);
                return
            end

            writeStartBanner(this);

            fprintf(this.FID,"%% Get full path of current system\n");
            isModel=false;
            if strcmp(context,"rptgen_sl.csl_mdl_loop")
                fprintf(this.FID,"rptCurrentSystem = getfullname(%s.CurrentModelHandle);\n\n",...
                this.RptStateVariable);
                isModel=true;
            else
                fprintf(this.FID,"rptCurrentSystem = getfullname(%s.CurrentSystem.Object);\n\n",...
                this.RptStateVariable);
            end

            varName=getVariableName(this);
            cmpn=this.Component;
            fprintf(this.FID,"%% Determine whether system meets filter requirements\n\n");


            if cmpn.minNumBlocks>0
                fprintf(this.FID,"%% Number of blocks in the system should be at least %d\n",cmpn.minNumBlocks);
                fprintf(this.FID,"rptBlocksInSystem = get_param(rptCurrentSystem,""blocks"");\n");
                fprintf(this.FID,"%s = numel(rptBlocksInSystem) >= %d;\n\n",varName,cmpn.minNumBlocks);
            else
                fprintf(this.FID,"%s = true;\n",varName);
            end


            if cmpn.minNumSubSystems>0
                fprintf(this.FID,"%% Number of subsystems in the system should be at least %d\n",cmpn.minNumSubSystems);
                fprintf(this.FID,"rptSubsystemFinder = BlockFinder(Container=rptCurrentSystem, ...\n");
                fprintf(this.FID,"BlockTypes=""SubSystem"");\n");
                fprintf(this.FID,"rptSubsystemsInSystem = find(rptSubsystemFinder);\n");
                fprintf(this.FID,"%s = %s && (numel(rptSubsystemsInSystem) >= %d);\n\n",varName,varName,cmpn.minNumSubSystems);
            end


            if~isModel
                if strcmp(cmpn.isMask,"yes")
                    fprintf(this.FID,"%% System must be masked\n");
                    fprintf(this.FID,"%s = %s && isMaskedSystem(rptCurrentSystem);\n\n",...
                    varName,varName);
                elseif strcmp(cmpn.isMask,"no")
                    fprintf(this.FID,"%% System must not be masked\n");
                    fprintf(this.FID,"%s = %s && ~isMaskedSystem(rptCurrentSystem);\n\n",...
                    varName,varName);
                end
            end


            if~isempty(cmpn.customFilterCode)


                lines=strsplit(cmpn.customFilterCode,newline);
                if~all(startsWith(lines,"%"))
                    fprintf(this.FID,"%% Evaluate custom filter code\n");
                    fprintf(this.FID,"currentSystem = rptCurrentSystem;\n");
                    fwrite(this.FID,cmpn.customFilterCode);
                    fprintf(this.FID,"\nif exist(""isFiltered"",""var"")\n");
                    fprintf(this.FID,"%s = %s && ~isFiltered;\n",varName,varName);
                    fprintf(this.FID,"end\n\n");
                end
            end
        end

        function convertComponentChildren(this)
            fprintf(this.FID,"%% Only execute child components if filter requirements are met\n");
            fprintf(this.FID,"if %s\n",getVariableName(this));

            children=getComponentChildren(this);
            n=numel(children);
            for i=1:n
                cmpn=children{i};
                c=getConverter(this.RptFileConverter.ConverterFactory,...
                cmpn,this.RptFileConverter);
                convert(c);
            end

            fprintf(this.FID,"end %% system filter\n\n");
            writeEndBanner(this);
        end

        function name=getVariableRootName(~)





            name="rptSystemMeetsRequirements";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_sys_filter.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_sys_filter
            templateFolder=fullfile(rptgen_sl_csl_sys_filter.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,strcat(templateName,'.txt'));
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