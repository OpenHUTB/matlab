classdef rptgen_sl_csl_cfgset<mlreportgen.rpt2api.ComponentConverter






























    methods
        function obj=rptgen_sl_csl_cfgset(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end
    end

    methods(Access=protected)

        function write(obj)
            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(obj);

            writeStartBanner(obj);


            fprintf(obj.FID,'%s = ModelConfiguration;\n',varName);


            fprintf(obj.FID,'%s.Model = rptModelName;\n',varName);


            fprintf(obj.FID,'%s.MaxCols = %d;\n',varName,...
            obj.Component.SizeLimit);


            fprintf(obj.FID,'%s.DepthLimit = %d;\n',varName,...
            obj.Component.DepthLimit);


            fprintf(obj.FID,'%s.ObjectLimit = %d;\n',varName,...
            obj.Component.ObjectLimit);


            switch obj.Component.DisplayTable
            case 'auto'
                fprintf(obj.FID,'%s.FormatPolicy = "Auto";\n',varName);
            case 'table'
                fprintf(obj.FID,'%s.FormatPolicy = "Table";\n',varName);
            case 'para'
                fprintf(obj.FID,'%s.FormatPolicy = "Paragraph";\n',varName);
            case 'text'
                fprintf(obj.FID,'%s.FormatPolicy = "Inline Text";\n',varName);
            end


            switch obj.Component.TitleMode
            case 'none'
                fprintf(obj.FID,'%s.Title = "";\n',varName);
            case 'auto'
                fprintf(obj.FID,'%s.Title = [];\n',varName);
            case 'manual'
                Parser.writeExprStr(obj.FID,obj.Component.CustomTitle,'rptModelConfigTitle');
                fprintf(obj.FID,'%s.Title = rptModelConfigTitle;\n',varName);
            end


            fprintf(obj.FID,'%s.ShowEmptyValues = %d;\n',...
            varName,not(obj.Component.IgnoreIfEmpty));


            fprintf(obj.FID,'%s.ShowDefaultValues = %d;\n',...
            varName,not(obj.Component.IgnoreIfDefault));


            fprintf(obj.FID,'%s.ShowDataType = %d;\n',...
            varName,obj.Component.ShowTypeInHeading);


            if~(obj.Component.ShowTableGrids)






                fprintf(obj.FID,'%s.TableReporter.TableStyleName = "ModelConfigurationSourceTable";\n',varName);
            end


            if(obj.Component.MakeTablePageWide)
                fprintf(obj.FID,'%s.TableReporter.TableWidth = "100%%";\n',varName);
            end


            Parser.writeExprStr(obj.FID,obj.Component.PropertyFilterCode,'rptModelConfigFilterFcn');
            fprintf(obj.FID,"%s.PropertyFilterFcn = rptModelConfigFilterFcn;\n",varName);


            parentName=obj.RptFileConverter.VariableNameStack.top;
            fprintf(obj.FID,'append(%s,%s);\n\n',parentName,varName);

            writeEndBanner(obj);
        end

        function convertComponentChildren(~)


        end

        function name=getVariableRootName(~)





            name="rptModelConfig";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_cfgset.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_cfgset
            templateFolder=fullfile(rptgen_sl_csl_cfgset.getClassFolder,...
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
