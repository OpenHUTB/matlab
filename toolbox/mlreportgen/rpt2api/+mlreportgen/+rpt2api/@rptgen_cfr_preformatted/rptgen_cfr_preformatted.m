classdef rptgen_cfr_preformatted<mlreportgen.rpt2api.ComponentConverter

















































    methods

        function this=rptgen_cfr_preformatted(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser

            varName=getVariableName(this);
            Parser.writeExprStr(this.FID,...
            this.Component.Content,"rptPreformattedContent");

            if this.Component.isCode











                parent=getParent(this.Component);
                while~isempty(parent)
                    switch class(parent)
                    case{"rptgen.cfr_section","rptgen.cfr_ext_table_entry"}
                        parentName=parent;
                        break;
                    otherwise

                        if isempty(parent.getContentType)
                            parent=getParent(parent);
                        else
                            break;
                        end
                    end
                end

                if strcmp(class(parentName),"rptgen.cfr_section")
                    fprintf(this.FID,"%s = MATLABCode();\n",varName);
                    fprintf(this.FID,"%s.Content = rptPreformattedContent;\n",varName);

                else

                    mCode=mlreportgen.utils.internal.MATLABCode(this.Component.Content);
                    assignin("base",varName,mCode);
                    fprintf(this.FID,"%% rptPreformattedText is in MATLAB Workspace \n");
                end

            else

                fprintf(this.FID,"%s = Preformatted(rptPreformattedContent);\n",varName);

                if this.Component.isItalic
                    fprintf(this.FID,"%s.Italic = true;\n",varName);
                end

                if this.Component.isBold
                    fprintf(this.FID,"%s.Bold = true;\n",varName);
                end

                color=this.Component.Color;
                if~strcmp(color,"auto")
                    Parser.writeExprStr(this.FID,...
                    color,"rptColor");
                    fprintf(this.FID,'%s.Color = rptColor;\n',...
                    varName);
                end

                if strcmp(this.Component.StyleNameType,"custom")
                    fprintf(this.FID,'%s.StyleName = "%s";\n',...
                    varName,this.Component.StyleName);
                else
                    fprintf(this.FID,'%s.StyleName = "rgProgramListing";\n',...
                    varName);
                end
            end

            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n\n",parentName,varName);

        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptPreformatted";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_preformatted.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_preformatted
            templateFolder=fullfile(rptgen_cfr_preformatted.getClassFolder,...
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

