classdef rptgen_sl_csl_sys_snap<mlreportgen.rpt2api.ComponentConverter&slreportgen.rpt2api.rptgen_sl_csl_graphic_snap



























    methods

        function obj=rptgen_sl_csl_sys_snap(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)



            writeStartBanner(this);

            sysVarName=getVariableName(this);
            allowedContextList=["rptgen_sl.csl_sys_loop","rptgen_sl.csl_mdl_loop"];
            loopContext=getContext(this,allowedContextList);
            if(strcmpi(loopContext,"rptgen_sl.csl_mdl_loop"))
                fprintf(this.FID,"rptSlSystemSnapshotTarget = rptState.CurrentModelHandle;\n");
                fprintf(this.FID,"%s = slreportgen.report.Diagram(rptState.CurrentModelHandle);\n",sysVarName);
            elseif(strcmpi(loopContext,"rptgen_sl.csl_sys_loop"))
                fprintf(this.FID,"rptSlSystemSnapshotTarget = rptState.CurrentSystem.Object;\n");
                fprintf(this.FID,"%s = getReporter(rptState.CurrentSystem);\n",sysVarName);
            else
                return;
            end

            if strcmp(this.Component.CaptionType,'manual')
                if~isempty(this.Component.Caption)
                    fprintf(this.FID,'%s.Snapshot.Caption = "%s";\n',sysVarName,this.Component.Caption);
                end
            elseif strcmp(this.Component.CaptionType,'auto')
                fprintf(this.FID,'rptSystemSnapshotDescription= mlreportgen.utils.safeGet(rptSlSystemSnapshotTarget,"description");\n');
                fprintf(this.FID,'%s.Snapshot.Caption = rptSystemSnapshotDescription;\n',sysVarName);
            else
                fprintf(this.FID,'%s.Snapshot.Caption = [];\n',sysVarName);
            end

            if strcmp(this.Component.PaperExtentMode,'manual')
                fprintf(this.FID,'%s.Scaling = "custom";\n',sysVarName);
                fprintf(this.FID,'%s.Width = "%s";\n',sysVarName,strcat(string(this.Component.PaperExtent(1)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
                fprintf(this.FID,'%s.Height = "%s";\n',sysVarName,strcat(string(this.Component.PaperExtent(2)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));

            elseif strcmp(this.Component.PaperExtentMode,'zoom')
                fprintf(this.FID,'%s.Scaling = "zoom";\n',sysVarName);
                fprintf(this.FID,'%s.Zoom = "%s%%";\n',sysVarName,string(this.Component.PaperZoom));
                fprintf(this.FID,'%s.MaxWidth = "%s";\n',sysVarName,strcat(string(this.Component.MaxPaperExtent(1)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
                fprintf(this.FID,'%s.MaxHeight = "%s";\n',sysVarName,strcat(string(this.Component.MaxPaperExtent(2)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
            end

            writeGraphicsSnapshotProperties(this,sysVarName,this.Component.Format);

            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,'append(%s,%s);\n',parentName,sysVarName);



            writeEndBanner(this);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptSystemSnapshot";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_sys_snap.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_sys_snap
            templateFolder=fullfile(rptgen_sl_csl_sys_snap.getClassFolder,...
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


