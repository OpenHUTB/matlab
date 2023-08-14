classdef rptgen_sf_csf_obj_filter<mlreportgen.rpt2api.ComponentConverter



























    properties(Access=private,Constant)
        SupportedContexts=["csf_chart_loop",...
        "csf_obj_loop",...
        "csf_state_loop"];
    end

    methods

        function this=rptgen_sf_csf_obj_filter(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sf_csf_obj_filter



            context=getContext(this,this.SupportedContexts);
            if strcmp(context,"")
                fprintf(this.FID,"% Skipping Stateflow filter component with no chart, state, or object loop parent\n\n",context);
                return
            end

            writeStartBanner(this);

            fprintf(this.FID,"%% Get the current Stateflow object\n");
            if strcmp(context,"rptgen_sf.csf_chart_loop")
                fprintf(this.FID,"rptCurrentObject = %s.CurrentChart;\n\n",...
                this.RptStateVariable);
            elseif strcmp(context,"rptgen_sf.csf_state_loop")
                fprintf(this.FID,"rptCurrentObject = %s.CurrentState;\n\n",...
                this.RptStateVariable);
            else
                fprintf(this.FID,"rptCurrentObject = %s.CurrentStateflowObject;\n\n",...
                this.RptStateVariable);
            end

            varName=getVariableName(this);
            cmpn=this.Component;
            fprintf(this.FID,"%% Determine whether object meets filter requirements\n\n");


            fprintf(this.FID,"%% Object type must be %s\n",cmpn.ObjectType);
            fprintf(this.FID,"%s = strcmp(rptCurrentObject.Type,""Stateflow.%s"");\n\n",varName,cmpn.ObjectType);


            if cmpn.repMinChildren>0
                fprintf(this.FID,"%% Number of children should be at least %d\n",cmpn.repMinChildren);
                fprintf(this.FID,"rptNChildren = 0;\n");
                fprintf(this.FID,"rptCurrentChild = rptCurrentObject.Object.down;\n");
                fprintf(this.FID,"while ~isempty(rptCurrentChild) && rptNChildren < %d\n",...
                cmpn.repMinChildren);
                fprintf(this.FID,"rptNChildren = rptNChildren + 1;\n");
                fprintf(this.FID,"rptCurrentChild = rptCurrentChild.right;\n");
                fprintf(this.FID,"end\n");
                fprintf(this.FID,"%s = %s && (rptNChildren >= %d);\n\n",varName,varName,cmpn.repMinChildren);
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

            fprintf(this.FID,"end %% Stateflow filter\n\n");
            writeEndBanner(this);
        end

        function name=getVariableRootName(~)





            name="rptObjectMeetsRequirements";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sf_csf_obj_filter.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sf_csf_obj_filter
            templateFolder=fullfile(rptgen_sf_csf_obj_filter.getClassFolder,...
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