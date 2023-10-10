classdef rptgen_sf_csf_auto_table<mlreportgen.rpt2api.ComponentConverter&slreportgen.rpt2api.rptgen_sl_rpt_auto_table

    properties(Access=protected)
        autoTableObjectType="rptSlAutoTableObjectType";
        autoTableHeaderName="rptSlAutoTableName";
        autoTableObjectTarget="rptSlAutoTableTarget";
    end

    methods

        function obj=rptgen_sf_csf_auto_table(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)



            writeStartBanner(this);

            sfAutoTableVarName=getVariableName(this);
            allowedContextList=["rptgen_sf.csf_chart_loop","rptgen_sf.csf_obj_loop","rptgen_sf.csf_state_loop"];
            loopContext=getContext(this,allowedContextList);


            if(strcmpi(loopContext,'rptgen_sf.csf_chart_loop'))
                fprintf(this.FID,"%s = rptState.CurrentChart;\n",this.autoTableObjectTarget);
            elseif(strcmpi(loopContext,'rptgen_sf.csf_obj_loop'))
                fprintf(this.FID,"%s = rptState.CurrentStateflowObject;\n",this.autoTableObjectTarget);
            elseif(strcmpi(loopContext,'rptgen_sf.csf_state_loop'))
                fprintf(this.FID,"%s = rptState.CurrentState;\n",this.autoTableObjectTarget);
            else
                return;
            end

            fprintf(this.FID,"if(~isempty(%s))\n",this.autoTableObjectTarget);
            fprintf(this.FID,"%s = StateflowObjectProperties(%s.Object);\n",sfAutoTableVarName,this.autoTableObjectTarget);

            fprintf(this.FID,'%s = getObjectType(%s.Object);\n',...
            this.autoTableObjectType,this.autoTableObjectTarget);
            switch this.Component.NameType
            case 'name'
                fprintf(this.FID,'%s = %s.Name;\n',...
                this.autoTableHeaderName,this.autoTableObjectTarget);
                fprintf(this.FID,'%s = normalizeString(%s{:});\n',...
                this.autoTableHeaderName,this.autoTableHeaderName);
            case 'slsfname'
                fprintf(this.FID,'%s = %s.Path;\n',...
                this.autoTableHeaderName,this.autoTableObjectTarget);
            otherwise
                fprintf(this.FID,'rptAutoTableSfName = %s.Name;\n',this.autoTableObjectTarget);






                [filepath,~,~]=fileparts(this.RptFileConverter.ScriptPath);
                template=slreportgen.rpt2api.rptgen_sf_csf_auto_table.getTemplate('getSfPath');
                path=fullfile(filepath,"getSfPath.m");

                fileID=fopen(path,"w","n","UTF-8");
                fprintf(fileID,"%s",template);
                fclose(fileID);
                fprintf(this.FID,'%s = getSfPath(%s.Object,rptAutoTableSfName);\n',...
                this.autoTableHeaderName,this.autoTableObjectTarget);
            end

            fprintf(this.FID,'sfAutoTableParams = getStateflowObjectParameters(%s.Object,%s);\n',...
            this.autoTableObjectTarget,this.autoTableObjectType);
            fprintf(this.FID,"%s.Properties = string(sfAutoTableParams(:))';\n\n",sfAutoTableVarName);

            this.writeAutoTableProperties(sfAutoTableVarName);

            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,'append(%s,%s);\n',parentName,sfAutoTableVarName);
            fprintf(this.FID,"end\n\n");



            writeEndBanner(this);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptSfAutoTable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sf_csf_auto_table.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sf_csf_auto_table
            templateFolder=fullfile(rptgen_sf_csf_auto_table.getClassFolder,...
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


