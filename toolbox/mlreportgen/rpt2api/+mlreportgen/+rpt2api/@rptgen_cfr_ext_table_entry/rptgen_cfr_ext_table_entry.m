classdef rptgen_cfr_ext_table_entry<mlreportgen.rpt2api.ComponentConverter

































    methods

        function this=rptgen_cfr_ext_table_entry(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser


            tableEntryVarName=getVariableName(this);
            fprintf(this.FID,"%s = TableEntry;\n",tableEntryVarName);


            hAlign=this.Component.HorizAlign;
            if~strcmpi(hAlign,"inherit")&&~strcmpi(hAlign,"justify")
                fprintf(this.FID,'%s.Style = [%s.Style {HAlign("%s")}];\n',...
                tableEntryVarName,tableEntryVarName,hAlign);
            end


            vAlign=this.Component.VertAlign;
            if~strcmpi(vAlign,"inherit")
                fprintf(this.FID,'%s.VAlign = "%s";\n',...
                tableEntryVarName,vAlign);
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
                tableEntryVarName,tableEntryVarName,rowSepStyle);
            end


            colSep=this.Component.ColSep;
            if~strcmpi(colSep,"inherit")
                switch colSep
                case "true"
                    colSepStyle="solid";
                case "false"
                    colSepStyle="none";
                end

                fprintf(this.FID,'%s.Style = [%s.Style {ColSep("%s")}];\n',...
                tableEntryVarName,tableEntryVarName,colSepStyle);
            end


            bgColor=this.Component.Color;
            if~strcmpi(bgColor,"auto")
                Parser.writeExprStr(this.FID,bgColor,"rptTableEntryBgColor");
                fprintf(this.FID,"%s.Style = [%s.Style {BackgroundColor(rptTableEntryBgColor)}];\n",...
                tableEntryVarName,tableEntryVarName);
            end


            rowSpan=this.Component.SpanNumRows;
            if~isempty(rowSpan)
                Parser.writeExprStr(this.FID,rowSpan,"rptTableRowSpan");
                fprintf(this.FID,"%s.RowSpan = str2double(rptTableRowSpan);\n",...
                tableEntryVarName);
            end


            entryStartColName=this.Component.SpanStartCol;
            entryEndColName=this.Component.SpanEndCol;
            if~isempty(entryStartColName)&&~isempty(entryEndColName)








                parentTable=getParentTable(this);
                if~isempty(parentTable)

                    tableChildren=parentTable.getActiveHierarchicalChildren();
                    idx=arrayfun(@(x)strcmpi(x.class,"rptgen.cfr_ext_table_colspec"),tableChildren);
                    colSpecComponents=tableChildren(idx);




                    if~isempty(colSpecComponents)
                        startColNum=[];
                        endColNum=[];

                        nColSpecs=length(colSpecComponents);
                        for iColSpec=1:nColSpecs
                            currColSpec=colSpecComponents(iColSpec);
                            if strcmp(currColSpec.ColName,entryStartColName)

                                colNumString=currColSpec.ColNum;
                                parser=Parser(colNumString);
                                parse(parser);
                                startColNum=str2double(colNumString);
                            end

                            if strcmp(currColSpec.ColName,entryEndColName)

                                colNumString=currColSpec.ColNum;
                                parser=Parser(colNumString);
                                parse(parser);
                                endColNum=str2double(colNumString);
                            end

                            if~isempty(startColNum)&&~isempty(endColNum)



                                colSpanValue=endColNum-startColNum+1;
                                fprintf(this.FID,"%s.ColSpan = %d;\n",...
                                tableEntryVarName,colSpanValue);
                                break;
                            end
                        end
                    end
                end
            end


            textOrientation=this.Component.TextOrientation;
            rotatedTextWidth=this.Component.RotatedTextWidth;


            if strcmpi(textOrientation,"auto")
                parentRow=this.Component.getParent();
                textOrientation=parentRow.TextOrientation;
                rotatedTextWidth=parentRow.RotatedTextWidth;
            end

            if~strcmpi(textOrientation,"auto")
                if strcmpi(textOrientation,"90")||strcmpi(textOrientation,"-270")
                    value="up";
                elseif strcmpi(textOrientation,"-90")||strcmpi(textOrientation,"270")
                    value="down";
                else
                    value="horizontal";
                end
                fprintf(this.FID,'rptTableEntryTextOrientation = TextOrientation("%s");\n',value);

                if~isempty(rotatedTextWidth)
                    Parser.writeExprStr(this.FID,rotatedTextWidth,"rptTableEntryTextOrientation.Width");
                end

                fprintf(this.FID,'%s.Style = [%s.Style {rptTableEntryTextOrientation}];\n',...
                tableEntryVarName,tableEntryVarName);
            end
        end

        function convertComponentChildren(this)

            convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(this);


            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n\n",...
            parentName,getVariableName(this));
        end

        function name=getVariableRootName(~)





            name="rptTableEntry";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_ext_table_entry.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Access=private)

        function parent=getParentTable(this)


            parent=this.Component.up;
            while~isa(parent,"rptgen.cfr_ext_table")&&~isempty(parent)
                parent=parent.up;
            end
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_ext_table_entry
            templateFolder=fullfile(rptgen_cfr_ext_table_entry.getClassFolder,...
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
