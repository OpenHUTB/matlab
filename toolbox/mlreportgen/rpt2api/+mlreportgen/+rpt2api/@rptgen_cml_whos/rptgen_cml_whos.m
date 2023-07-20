classdef rptgen_cml_whos<mlreportgen.rpt2api.ComponentConverter
















































    methods

        function this=rptgen_cml_whos(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser



            writeStartBanner(this);

            source=this.Component.Source;
            switch source
            case "MATFILE"
                container=this.Component.Filename;
                parser=Parser(container);
                parse(parser);
                fprintf(this.FID,'rptVariableTableMATFile = "%s";\n',container);
                [~,matFile,matExt]=fileparts(container);
                tTitle=getString(message('mlreportgen:rpt2api:rptgen_cml_whos:filename',matFile,matExt));
            case "GLOBAL"
                container="Global";
                tTitle=getString(message('mlreportgen:rpt2api:rptgen_cml_whos:theGlobalWorkspaceLabel'));
            otherwise

                container="MATLAB";
                tTitle=getString(message('mlreportgen:rpt2api:rptgen_cml_whos:matlabWorkspaceLabel'));
            end

            fprintf(this.FID,'rptMATLABVariableFinder = MATLABVariableFinder("%s");\n',container);
            fprintf(this.FID,"rptMATLABVariableResults = find(rptMATLABVariableFinder);\n");

            varName=getVariableName(this);
            fprintf(this.FID,"%s = SummaryTable(rptMATLABVariableResults);\n",varName);

            if strcmp(this.Component.TitleType,"auto")
                fprintf(this.FID,'%s.Title = "%s";\n',varName,tTitle);
            else
                Parser.writeExprStr(this.FID,...
                this.Component.TableTitle,"rptVariableTableTitle");
                fprintf(this.FID,...
                "%s.Title = rptVariableTableTitle;\n",varName);
            end

            properties="[";

            properties=strcat(properties,'"','Name','"'," ");

            if this.Component.isSize
                properties=strcat(properties,'"','Size','"'," ");
            end

            if this.Component.isBytes
                properties=strcat(properties,'"','Bytes','"'," ");
            end

            if this.Component.isClass
                properties=strcat(properties,'"','Class','"'," ");
            end

            if this.Component.isValue
                properties=strcat(properties,'"','Value','"'," ");
            end

            properties=strcat(properties,"]");

            fprintf(this.FID,"%s.Properties = %s;\n",varName,properties);

            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n\n",parentName,varName);




            writeEndBanner(this);

        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptVariableTable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cml_whos.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cml_whos
            templateFolder=fullfile(rptgen_cml_whos.getClassFolder,...
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

