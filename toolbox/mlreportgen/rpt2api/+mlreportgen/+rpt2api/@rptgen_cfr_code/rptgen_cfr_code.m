classdef rptgen_cfr_code<mlreportgen.rpt2api.ComponentConverter






















































    methods

        function this=rptgen_cfr_code(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);
            Parser.writeExprStr(this.FID,...
            this.Component.Content,"rptCodeContent");
            fprintf(this.FID,"%s = Text(rptCodeContent);\n",varName);
            fprintf(this.FID,'%s.WhiteSpace = "preserve";\n',varName);

            if this.Component.isItalic
                fprintf(this.FID,"%s.Italic = true;\n",varName);
            end

            if this.Component.isBold
                fprintf(this.FID,"%s.Bold = true;\n",varName);
            end

            if this.Component.isUnderline
                fprintf(this.FID,'%s.Underline = "single";\n',varName);
            end

            color=this.Component.Color;
            if~strcmp(color,"auto")
                Parser.writeExprStr(this.FID,color,"rptCodeColor");
                fprintf(this.FID,'%s.Color = rptCodeColor;\n',varName);
            end

            Parser.writeExprStr(this.FID,...
            this.Component.StyleName,"rptCodeStyleName");

            fprintf(this.FID,'%s.StyleName = rptCodeStyleName;\n',varName);

            if~isempty(this.AssignTo)
                fprintf(this.FID,"%s = %s;\n\n",this.AssignTo,varName);
            else
                parentName=this.RptFileConverter.VariableNameStack.top;
                fprintf(this.FID,"append(%s,%s);\n\n",parentName,varName);
            end

        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptCode";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_code.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename("fullpath"));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_code
            templateFolder=fullfile(rptgen_cfr_code.getClassFolder,...
            "templates");
            templatePath=fullfile(templateFolder,[templateName,".txt"]);
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