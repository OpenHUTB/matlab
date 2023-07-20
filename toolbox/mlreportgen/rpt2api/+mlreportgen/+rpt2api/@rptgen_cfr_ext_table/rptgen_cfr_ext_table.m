classdef rptgen_cfr_ext_table<mlreportgen.rpt2api.ComponentConverter

































    properties(Access=private)



        DOMTableVarName="rptDOMFormalTableObj";



        IsRelativeColWidths=false;




        TotalRelativeColWidths=0;
    end

    methods

        function this=rptgen_cfr_ext_table(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser



            writeStartBanner(this);


            Parser.writeExprStr(this.FID,...
            this.Component.NumCols,"rptTableNCols");
            fprintf(this.FID,"%s = FormalTable(str2double(rptTableNCols));\n",this.DOMTableVarName);


            tableVarName=getVariableName(this);
            fprintf(this.FID,"%s = BaseTable(%s);\n",...
            tableVarName,this.DOMTableVarName);


            title=this.Component.TableTitle;
            if~isempty(title)
                fprintf(this.FID,"rptTableTitleText = Text();\n");
                Parser.writeExprStr(this.FID,...
                title,"rptTableTitleText.Content");


                if strcmp(this.Component.TitleStyleNameType,"custom")
                    Parser.writeExprStr(this.FID,...
                    this.Component.TitleStyleName,"rptTableTitleText.StyleName");
                end

                fprintf(this.FID,"%s.Title = rptTableTitleText;\n",tableVarName);
            end


            tableStyleName=this.Component.TableStyleName;
            if~isempty(tableStyleName)
                if strcmp(this.Component.TableStyleNameType,"custom")
                    Parser.writeExprStr(this.FID,...
                    tableStyleName,sprintf("%s.StyleName",this.DOMTableVarName));
                else
                    fprintf(this.FID,'%s.StyleName = "%s";\n',this.DOMTableVarName,...
                    tableStyleName);
                end
            end


            if this.Component.IsPgwide
                fprintf(this.FID,'%s = "%s";\n',...
                sprintf("%s.Width",this.DOMTableVarName),"100%");
            elseif strcmp(this.Component.TableWidthType,"specify")
                Parser.writeExprStr(this.FID,...
                this.Component.TableWidth,...
                sprintf("%s.Width",this.DOMTableVarName));
            end


            if this.Component.HasRowSep
                fprintf(this.FID,'%s.RowSep = "solid";\n',this.DOMTableVarName);
            end


            if this.Component.HasColSep
                fprintf(this.FID,'%s.ColSep = "solid";\n',this.DOMTableVarName);
            end


            borderValue=this.Component.Frame;
            if~isempty(borderValue)
                tableBorderVarName="rptTableBorder";
                fprintf(this.FID,"%s = Border;\n",tableBorderVarName);

                switch borderValue
                case "all"
                    fprintf(this.FID,'%s.Style = "solid";\n',tableBorderVarName);
                case "bottom"
                    fprintf(this.FID,'%s.BottomStyle = "solid";\n',tableBorderVarName);
                case "none"
                    fprintf(this.FID,'%s.Style = "none";\n',tableBorderVarName);
                case "sides"
                    fprintf(this.FID,'%s.LeftStyle = "solid";\n',tableBorderVarName);
                    fprintf(this.FID,'%s.RightStyle = "solid";\n',tableBorderVarName);
                case "top"
                    fprintf(this.FID,'%s.TopStyle = "solid";\n',tableBorderVarName);
                case "topbot"
                    fprintf(this.FID,'%s.TopStyle = "solid";\n',tableBorderVarName);
                    fprintf(this.FID,'%s.BottomStyle = "solid";\n',tableBorderVarName);
                end

                fprintf(this.FID,...
                '%s.Style = [%s.Style {%s}];\n',this.DOMTableVarName,this.DOMTableVarName,tableBorderVarName);
            end


            alignment=this.Component.HorizAlign;
            if~strcmpi(alignment,"justify")
                fprintf(this.FID,'%s.TableEntriesHAlign = "%s";\n',...
                this.DOMTableVarName,alignment);
            end


            if strcmpi(this.Component.IndentNameType,"custom")
                indent=this.Component.Indent;
                if~isempty(indent)
                    fprintf(this.FID,'%s.OuterLeftMargin = "%s";\n',...
                    this.DOMTableVarName,indent);
                end
            end


        end

        function convertComponentChildren(this)

            writeColSpecs(this);


            convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(this);


            parentName=this.RptFileConverter.VariableNameStack.top;
            parentComp=this.Component.getParent();
            if isa(parentComp,"rptgen.cfr_ext_table_entry")





                fprintf(this.FID,"append(%s,%s.Content);\n\n",...
                parentName,getVariableName(this));
            else

                fprintf(this.FID,"append(%s,%s);\n\n",...
                parentName,getVariableName(this));
            end



            writeEndBanner(this);
        end

        function name=getVariableRootName(~)





            name="rptTable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_ext_table.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Access=private)

        function writeColSpecs(this)


            import mlreportgen.rpt2api.exprstr.Parser


            children=this.Component.getActiveHierarchicalChildren();
            idx=arrayfun(@(x)strcmpi(x.class,"rptgen.cfr_ext_table_colspec"),children);
            colSpecComponents=children(idx);

            if~isempty(colSpecComponents)

                fprintf(this.FID,"rptTableColSpecGroups(1) = TableColSpecGroup;\n");


                if endsWith(colSpecComponents(1).ColWidth,"*")
                    this.IsRelativeColWidths=true;


                    nColSpecs=length(colSpecComponents);
                    for iColSpec=1:nColSpecs
                        iColWidth=colSpecComponents(iColSpec).ColWidth;
                        iColWidth=strip(iColWidth,"right","*");
                        this.TotalRelativeColWidths=this.TotalRelativeColWidths+str2double(iColWidth);
                    end
                end




                nColsString=this.Component.NumCols;
                parser=Parser(nColsString);
                parse(parser);
                nCols=str2double(nColsString);
                for iCol=1:nCols

                    colSpecVarName=sprintf("rptTableColSpecs(%s)",num2str(iCol));
                    fprintf(this.FID,"%s = TableColSpec;\n",colSpecVarName);



                    iColSpecIdx=arrayfun(@(x)strcmp(x.ColNum,num2str(iCol)),colSpecComponents);
                    iColSpecComponent=colSpecComponents(iColSpecIdx);
                    if~isempty(iColSpecComponent)


                        writeColSpecComponentProps(this,colSpecVarName,iColSpecComponent);
                    end
                end


                fprintf(this.FID,"rptTableColSpecGroups(1).ColSpecs = rptTableColSpecs;\n");
                fprintf(this.FID,"%s.ColSpecGroups = rptTableColSpecGroups;\n",this.DOMTableVarName);
            end
        end

        function writeColSpecComponentProps(this,colSpecVarName,colSpecComponent)



            import mlreportgen.rpt2api.exprstr.Parser


            hAlign=colSpecComponent.HorizAlign;
            if~strcmpi(hAlign,"inherit")&&~strcmpi(hAlign,"justify")
                fprintf(this.FID,'%s.Style = [%s.Style {HAlign("%s")}];\n',...
                colSpecVarName,colSpecVarName,hAlign);
            end


            rowSep=colSpecComponent.RowSep;
            if~strcmpi(rowSep,"inherit")
                switch rowSep
                case "true"
                    rowSepStyle="solid";
                case "false"
                    rowSepStyle="none";
                end

                fprintf(this.FID,'%s.Style = [%s.Style {RowSep("%s")}];\n',...
                colSpecVarName,colSpecVarName,rowSepStyle);
            end


            colSep=colSpecComponent.ColSep;
            if~strcmpi(colSep,"inherit")
                switch colSep
                case "true"
                    colSepStyle="solid";
                case "false"
                    colSepStyle="none";
                end

                fprintf(this.FID,'%s.Style = [%s.Style {ColSep("%s")}];\n',...
                colSpecVarName,colSpecVarName,colSepStyle);
            end


            if this.IsRelativeColWidths

                relativeWidth=str2double(strip(colSpecComponent.ColWidth,"right","*"));
                percentWidth=((relativeWidth/this.TotalRelativeColWidths)*100);
                fprintf(this.FID,'rptTableColWidth = "%s";\n',strcat(num2str(percentWidth),"%"));
            else
                Parser.writeExprStr(this.FID,...
                colSpecComponent.ColWidth,"rptTableColWidth");
            end
            fprintf(this.FID,'%s.Style = [%s.Style {Width(rptTableColWidth)}];\n',...
            colSpecVarName,colSpecVarName);
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_ext_table
            templateFolder=fullfile(rptgen_cfr_ext_table.getClassFolder,...
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
