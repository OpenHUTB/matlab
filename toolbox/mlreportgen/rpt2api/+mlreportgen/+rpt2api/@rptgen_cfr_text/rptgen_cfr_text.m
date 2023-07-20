classdef rptgen_cfr_text<mlreportgen.rpt2api.ComponentConverter





























    methods

        function obj=rptgen_cfr_text(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)
            import mlreportgen.rpt2api.rptgen_cfr_text
            import mlreportgen.rpt2api.exprstr.Parser


            objName=getVariableName(obj);
            Parser.writeExprStr(obj.FID,...
            obj.Component.Content,'rptTextContent');
            fprintf(obj.FID,'%s = Text(rptTextContent);\n',objName);


            if obj.Component.isItalic
                fprintf(obj.FID,"%s.Italic = true;\n",objName);
            end

            if obj.Component.isBold
                fprintf(obj.FID,"%s.Bold = true;\n",objName);
            end

            if obj.Component.isUnderline
                fprintf(obj.FID,"%s.Underline = 'single';\n",objName);
            end

            if obj.Component.isStrikethrough
                fprintf(obj.FID,"%s.Strike = 'single';\n",objName);
            end

            if obj.Component.isSuperscript
                fprintf(obj.FID,"%s.Style = [%s.Style {VerticalAlign('super')}];\n",...
                objName,objName);
            end

            if obj.Component.isSubscript
                fprintf(obj.FID,"%s.Style = [%s.Style {VerticalAlign('sub')}];\n",...
                objName,objName);
            end

            if obj.Component.isCode||obj.Component.isLiteral...
                ||obj.Component.isWhiteSpace
                fprintf(obj.FID,'%s.WhiteSpace = "preserve";\n',objName);
            end

            if obj.Component.isCode||obj.Component.isLiteral
                fprintf(obj.FID,'%s.FontFamilyName = "Courier New";\n',objName);
            end

            if string(obj.Component.Color)~="auto"
                fprintf(obj.FID,'%s.Color = "%s";\n',...
                objName,obj.Component.Color);
            end

            if strcmp(obj.Component.StyleNameType,'custom')
                Parser.writeExprStr(obj.FID,...
                obj.Component.StyleName,'rptStyleName');
                fprintf(obj.FID,'%s.StyleName = rptStyleName;\n\n',...
                objName);
            end

        end

        function convertComponentChildren(obj)
            parentName=obj.RptFileConverter.VariableNameStack.top;
            convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(obj);
            if~isempty(obj.AssignTo)
                fprintf(obj.FID,'%s = %s;\n\n',obj.AssignTo,getVariableName(obj));
            else
                fprintf(obj.FID,'append(%s,%s);\n\n',parentName,getVariableName(obj));
            end
        end

        function name=getVariableRootName(~)





            name="rptText";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_text.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_text
            templateFolder=fullfile(rptgen_cfr_text.getClassFolder,...
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

