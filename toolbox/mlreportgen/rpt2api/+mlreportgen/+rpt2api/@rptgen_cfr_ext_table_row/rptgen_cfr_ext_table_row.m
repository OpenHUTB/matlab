classdef rptgen_cfr_ext_table_row<mlreportgen.rpt2api.ComponentConverter

































    methods

        function this=rptgen_cfr_ext_table_row(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser


            tableRowVarName=getVariableName(this);
            fprintf(this.FID,"%s = TableRow;\n",tableRowVarName);


            vAlign=this.Component.VertAlign;
            if~strcmpi(vAlign,"inherit")
                fprintf(this.FID,'%s.Style = [%s.Style {VAlign("%s")}];\n',...
                tableRowVarName,tableRowVarName,vAlign);
            end


            rowSep=this.Component.RowSep;
            if~strcmpi(rowSep,"inherit")
                switch rowSep
                case "true"
                    rowSepStyle="solid";
                case "false"
                    rowSepStyle="none";
                end

                fprintf(this.FID,'%s.Style = [%s.Style {RowSep("%s")}];\n',...
                tableRowVarName,tableRowVarName,rowSepStyle);
            end


            bgColor=this.Component.BackgroundColor;
            if~strcmpi(bgColor,"auto")
                Parser.writeExprStr(this.FID,bgColor,"rptTableRowBgColor");
                fprintf(this.FID,"%s.Style = [%s.Style {BackgroundColor(rptTableRowBgColor)}];\n",...
                tableRowVarName,tableRowVarName);
            end


            if strcmpi(this.Component.RowHeightType,"specify")
                height=this.Component.RowHeight;
                if~isempty(height)
                    Parser.writeExprStr(this.FID,height,...
                    sprintf("%s.Height",tableRowVarName));
                end
            end






        end

        function convertComponentChildren(this)

            convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(this);


            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n\n",...
            parentName,getVariableName(this));
        end

        function name=getVariableRootName(~)





            name="rptTableRow";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_ext_table_row.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_ext_table_row
            templateFolder=fullfile(rptgen_cfr_ext_table_row.getClassFolder,...
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
