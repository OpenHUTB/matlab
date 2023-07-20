classdef rptgen_cfr_list<mlreportgen.rpt2api.ComponentConverter















































    methods

        function this=rptgen_cfr_list(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)


            listSource=this.Component.Source;

            hasChildren=~isempty(this.getComponentChildren);



            if~isempty(listSource)||hasChildren

                parentName=this.RptFileConverter.VariableNameStack.top;
                listTitle=this.Component.ListTitle;
                if~isempty(listTitle)
                    title="listTitle";
                    fprintf(this.FID,'%s = Paragraph("%s");\n',title,listTitle);

                    if strcmp(this.Component.TitleStyleNameType,"custom")
                        fprintf(this.FID,'%s.StyleName = "%s";\n',...
                        title,this.Component.TitleStyleName);
                    else




                        fprintf(this.FID,...
                        '%s.StyleName = "rgListTitle";\n',title);
                        fprintf(this.FID,...
                        '%s.Children.StyleName = "rgListTitleText";\n',...
                        title);
                    end


                    fprintf(this.FID,"append(%s,%s);\n",...
                    parentName,title);
                end

                if hasChildren
                    createList(this);
                else



                    fprintf(this.FID,...
                    'if exist("%s","var") && ~isempty(%s)\n',...
                    listSource,listSource);

                    createList(this);

                    fprintf(this.FID,"append(%s,%s);\n",parentName,...
                    getVariableName(this));
                    fprintf(this.FID,"else\n");
                    fprintf(this.FID,"%% The workspace variable %s that specifies a cell array\n",listSource);
                    fprintf(this.FID,"%% either doesn't exist or is empty.\n");
                    fprintf(this.FID,"end\n");
                end

            else
                fprintf(this.FID,"%% The List component cannot be converted "+...
                "because the source is empty.\n");
            end

        end

        function createList(this)





            hasChildren=~isempty(this.getComponentChildren);
            source=this.Component.Source;
            varName=getVariableName(this);

            if strcmp(this.Component.ListStyle,"itemizedlist")
                if hasChildren

                    fprintf(this.FID,"%s = UnorderedList();\n",...
                    varName);
                else


                    fprintf(this.FID,"%s = UnorderedList(%s);\n",...
                    varName,source);
                end
            else
                if hasChildren

                    fprintf(this.FID,"%s = OrderedList();\n",...
                    varName);
                else


                    fprintf(this.FID,"%s = OrderedList(%s);\n",...
                    varName,source);
                end

                switch this.Component.NumerationType
                case "loweralpha"
                    type="lower-alpha";
                case "upperalpha"
                    type="upper-alpha";
                case "lowerroman"
                    type="lower-roman";
                case "upperroman"
                    type="upper-roman";
                otherwise
                    type="decimal";
                end
                fprintf(this.FID,...
                '%s.Style = [%s.Style,{ListStyleType("%s")}];\n',...
                varName,varName,type);
            end

            listStyleName=this.Component.ListStyleName;
            if~isempty(listStyleName)
                fprintf(this.FID,'%s.StyleName = "%s";\n',varName,...
                listStyleName);
            end




        end

        function convertComponentChildren(this)

            children=getComponentChildren(this);
            if~isempty(children)

                objName=getVariableName(this);
                push(this.RptFileConverter.VariableNameStack,objName);

                nChild=numel(children);
                for iChild=1:nChild





                    cmpn=children{iChild};
                    if isequal(string(class(cmpn)),"rptgen.cfr_text")
                        c=getConverter(this.RptFileConverter.ConverterFactory,...
                        cmpn,this.RptFileConverter);
                        convert(c);
                    else

                        fprintf(this.FID,"%% Component of type %s was not converted because it\n",class(cmpn));
                        fprintf(this.FID,"%% is a child of a List component. Only a Text component can be converted\n");
                        fprintf(this.FID,"%% as a child of List component.\n\n");
                    end
                end

                pop(this.RptFileConverter.VariableNameStack);
                if~isempty(this.AssignTo)
                    fprintf(this.FID,"%s = %s;\n\n",this.AssignTo,...
                    getVariableName(this));
                else
                    parentName=this.RptFileConverter.VariableNameStack.top;
                    fprintf(this.FID,"append(%s,%s);\n\n",...
                    parentName,getVariableName(this));
                end
            end
        end

        function name=getVariableRootName(~)





            name="rptList";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_list.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_list
            templateFolder=fullfile(rptgen_cfr_list.getClassFolder,...
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

