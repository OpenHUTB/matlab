classdef rptgen_sf_csf_obj_snap<mlreportgen.rpt2api.ComponentConverter&slreportgen.rpt2api.rptgen_sl_csl_graphic_snap



























    methods

        function obj=rptgen_sf_csf_obj_snap(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)



            writeStartBanner(this);

            varName=getVariableName(this);


            allowedContextList=["rptgen_sf.csf_chart_loop","rptgen_sf.csf_obj_loop","rptgen_sf.csf_state_loop"];
            loopContext=getContext(this,allowedContextList);
            if(strcmpi(loopContext,"rptgen_sf.csf_chart_loop"))
                fprintf(this.FID,"rptSfSnapshotTarget = rptState.CurrentChart;\n");
                isDiagramElement=false;
            elseif(strcmpi(loopContext,'rptgen_sf.csf_obj_loop'))
                fprintf(this.FID,"rptSfSnapshotTarget = rptState.CurrentStateflowObject;\n");
                isDiagramElement=true;
            elseif(strcmpi(loopContext,'rptgen_sf.csf_state_loop'))
                fprintf(this.FID,"rptSfSnapshotTarget = rptState.CurrentState;\n");
                isDiagramElement=true;
            else
                return;
            end









            [filepath,~,~]=fileparts(this.RptFileConverter.ScriptPath);
            template=slreportgen.rpt2api.rptgen_sf_csf_obj_snap.getTemplate('verifyChildCount');
            path=fullfile(filepath,"verifyChildCount.m");

            fileID=fopen(path,"w","n","UTF-8");
            fprintf(fileID,"%s",template);
            fclose(fileID);
            fprintf(this.FID,"rptSfSnapshotHasMinChildren = verifyChildCount(rptSfSnapshotTarget.Object,%d);\n",...
            this.Component.picMinChildren);

            fprintf(this.FID,"if rptSfSnapshotHasMinChildren\n");

            if isDiagramElement
                fprintf(this.FID,"%s = ElementDiagram(rptSfSnapshotTarget.Object);\n",varName);
            else
                fprintf(this.FID,"%s = rptSfSnapshotTarget.getReporter();\n",varName);
            end

            if strcmp(this.Component.CaptionType,'manual')
                if~isempty(this.Component.Caption)
                    fprintf(this.FID,'%s.Snapshot.Caption = "%s";\n',varName,this.Component.Caption);
                end
            elseif strcmp(this.Component.CaptionType,'auto')
                fprintf(this.FID,'rptSfSnapshotDescription= mlreportgen.utils.safeGet(rptSfSnapshotTarget.Object,"description");\n');
                fprintf(this.FID,'%s.Snapshot.Caption = rptSfSnapshotDescription;\n',varName);
            else

                fprintf(this.FID,'%s.Snapshot.Caption = [];\n',varName);
            end

            if strcmp(this.Component.imageSizing,'manual')
                fprintf(this.FID,'%s.Scaling = "custom";\n',varName);
                fprintf(this.FID,'%s.Width = "%s";\n',varName,strcat(string(this.Component.PrintSize(1)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
                fprintf(this.FID,'%s.Height = "%s";\n',varName,strcat(string(this.Component.PrintSize(2)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
            elseif strcmp(this.Component.imageSizing,'zoom')
                fprintf(this.FID,'%s.Scaling = "zoom";\n',varName);
                fprintf(this.FID,'%s.Zoom = "%s%%";\n',varName,string(this.Component.PrintZoom));
                fprintf(this.FID,'%s.MaxWidth = "%s";\n',varName,strcat(string(this.Component.MaxPrintSize(1)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
                fprintf(this.FID,'%s.MaxHeight = "%s";\n',varName,strcat(string(this.Component.MaxPrintSize(2)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
            end

            writeGraphicsSnapshotProperties(this,varName,this.Component.ImageFormat);

            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,'append(%s,%s);\n',parentName,varName);
            fprintf(this.FID,"end\n\n");



            writeEndBanner(this);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptSfSnapshot";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sf_csf_obj_snap.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sf_csf_obj_snap
            templateFolder=fullfile(rptgen_sf_csf_obj_snap.getClassFolder,...
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


