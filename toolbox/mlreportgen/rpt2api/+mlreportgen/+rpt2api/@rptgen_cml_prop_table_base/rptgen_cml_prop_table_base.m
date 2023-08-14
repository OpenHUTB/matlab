classdef(Abstract)rptgen_cml_prop_table_base<mlreportgen.rpt2api.ComponentConverter





























    properties(Abstract,Access=protected)


DOMTableName
DOMTableColName
DOMTableEntryName
DOMTableEntryBorder
    end

    methods(Abstract,Access=protected)


        writeSingleColPropTable(this);
        writeTwoColPropTable(this);
        writeBaseTableTitle(this);
    end

    methods(Access=protected)

        function createBaseTable(this)



            tableContent=this.Component.TableContent;




            if this.Component.SingleValueMode

                writeTwoColPropTable(this,tableContent);
            else

                writeSingleColPropTable(this,tableContent);
            end

            varName=getVariableName(this);
            fwrite(this.FID,"% Create a base table reporter."+newline);
            fprintf(this.FID,"%s = BaseTable(%s);\n\n",...
            varName,getDOMTableVarName(this));

            titleVarName=strcat(varName,"Title");


            writeBaseTableTitle(this,varName,titleVarName);


            if this.Component.isPageWide
                fprintf(this.FID,'%s.TableWidth = "%s";\n',...
                varName,"100%");
            end

            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n\n",parentName,varName);

        end

        function convertComponentChildren(~)


        end


        function separator=getSeparatorValue(~,sepVal)


            switch string(sepVal)

            case{"p v","N v"}
                separator=" ";

            case{"p:v","N:v"}
                separator=":";

            case{"p-v","N-v"}
                separator="-";
            otherwise
                separator="v";
            end
        end

        function applyTableEntryFormats(this,tableEntryObj,tblEntryName,tblEntryCounter)



            entryStyles="{";

            if~tableEntryObj.BorderLower||~tableEntryObj.BorderRight
                fprintf(this.FID,"%s = Border();\n",this.DOMTableEntryBorder);
                if~tableEntryObj.BorderLower
                    fprintf(this.FID,"%s.BottomStyle = ""none"";\n",...
                    this.DOMTableEntryBorder);
                end
                if~tableEntryObj.BorderRight
                    fprintf(this.FID,"%s.RightStyle = ""none"";\n",...
                    this.DOMTableEntryBorder);
                end
                entryStyles=strcat(entryStyles,this.DOMTableEntryBorder,",");
            end


            align=string(tableEntryObj.Align);
            if this.Component.SingleValueMode
                switch align
                case "center"
                    if tblEntryCounter==1
                        entryAlign="right";
                    else
                        entryAlign="left";
                    end
                case "justify"
                    if tblEntryCounter==1
                        entryAlign="left";
                    else
                        entryAlign="right";
                    end
                otherwise
                    entryAlign=align;
                end
                alignVal=strcat("HAlign","(",'"',entryAlign,'"',")");



                renderVal=tableEntryObj.Render;
                if tblEntryCounter==1&&(strcmp(renderVal,"N v")||strcmp(renderVal,"N:v")||strcmp(renderVal,"N-v"))
                    entryStyles=strcat(entryStyles,"Italic(true)",",");
                end
            else
                alignVal=strcat("HAlign","(",'"',align,'"',")");
            end

            entryStyles=strcat(entryStyles,alignVal,"}");



            tblEntryNameStr=strcat(tblEntryName,"_",num2str(tblEntryCounter));

            fwrite(this.FID,"% Define the styles for DOM table entry."+newline);
            fprintf(this.FID,"%sStyle = %s;\n",...
            tblEntryNameStr,entryStyles{:});
            fwrite(this.FID,"% Set the style of the table entry."+newline);
            fprintf(this.FID,...
            "%s.Style = [%s.Style,%sStyle];\n",...
            tblEntryNameStr,...
            tblEntryNameStr,...
            tblEntryNameStr);


            colSpan=tableEntryObj.ColSpan;
            if colSpan~=1
                fprintf(this.FID,"%s.ColSpan = %d;\n",...
                tblEntryNameStr,colSpan);
            end


            rowSpan=tableEntryObj.RowSpan;
            if rowSpan~=1
                fprintf(this.FID,"%s.RowSpan = %d;\n",...
                tblEntryNameStr,rowSpan);
            end
        end

        function tableVarName=getDOMTableVarName(this)


            tableVarName=strcat(this.DOMTableName,num2str(this.getVariableNameCounter));
        end

        function createPropNameTblEntry(this,rowName,iRow,tblEntryName,entryCounter)





            tableContent=this.Component.TableContent;

            fwrite(this.FID,...
            "% Create a table row object for the DOM table that contains two table"+newline);
            fwrite(this.FID,...
            "% entries. The first table entry is for the property name, and the second"+newline);
            fwrite(this.FID,...
            "% table entry is for the property value."+newline);
            fprintf(this.FID,...
            "%s = TableRow();\n\n",rowName);


            propName=getPropName(this,tableContent(iRow).Text);


            fprintf(this.FID,...
            "%% Create a table entry for the name of the ""%s"" property\n",...
            propName);




            renderVal=tableContent(iRow).Render;
            separator=getSeparatorValue(this,renderVal);

            if strcmp(separator,"v")





                fprintf(this.FID,"%s_%d = TableEntry();\n",...
                tblEntryName,entryCounter);
            else





                fprintf(this.FID,"%s_%d = TableEntry(""%s"");\n",...
                tblEntryName,entryCounter,propName);
            end
        end

        function appendTblEntry(this,rowName,iRow,tblEntryName,entryCounter)





            tableContent=this.Component.TableContent;


            applyTableEntryFormats(this,tableContent(iRow),...
            tblEntryName,entryCounter);


            fwrite(this.FID,...
            "% Append the table entry to the table row."+newline);

            fprintf(this.FID,...
            "append(%s,%s_%d);\n\n",...
            rowName,tblEntryName,entryCounter);
        end

        function createDOMTable(this,~)










            fwrite(this.FID,...
            "% Create a DOM Table that holds the content of the property table"+newline);
            fwrite(this.FID,...
            "% This DOM table is later used to create a BaseTable reporter by"+newline);
            fwrite(this.FID,...
            "% setting its Content property."+newline);

            domTableName=getDOMTableVarName(this);
            fprintf(this.FID,"%s = Table(%s);\n",...
            domTableName,this.DOMTableColName);
            fprintf(this.FID,...
            "%s.StyleName = ""rgUnruledTable"";\n",domTableName);

            if this.Component.SingleValueMode
                writeColSpecs(this);
            end


            fwrite(this.FID,"% Define the styles for the table."+newline);

            if this.Component.isBorder
                fprintf(this.FID,"%s.Border = ""solid"";\n",domTableName);
            end

            fprintf(this.FID,"%s.RowSep = ""solid"";\n",domTableName);
            fprintf(this.FID,"%s.ColSep = ""solid"";\n",domTableName);
        end


        function writeColSpecs(this)




            colWidth=this.Component.ColWidths;
            if numel(colWidth)==2

                col1TotalWidth=colWidth(1);
                col2TotalWidth=colWidth(2);
            else

                col1TotalWidth=colWidth(1)+colWidth(3);
                col2TotalWidth=colWidth(2)+colWidth(4);
            end

            domTableName=getDOMTableVarName(this);
            tblColSpecVarName=strcat(domTableName,"Grps");

            totalWidth=sum(colWidth);
            propColPercentWidth=...
            strcat(num2str(col1TotalWidth/totalWidth*100),"%");
            valueColPercentWidth=...
            strcat(num2str(col2TotalWidth/totalWidth*100),"%");
            fprintf(this.FID,"%s(1) = TableColSpecGroup;\n",tblColSpecVarName);
            fprintf(this.FID,"specs(1) = TableColSpec;\n");
            fprintf(this.FID,'specs(1).Style = {Width("%s")};\n',propColPercentWidth);
            fprintf(this.FID,"specs(2) = TableColSpec;\n");
            fprintf(this.FID,'specs(2).Style = {Width("%s")};\n',valueColPercentWidth);
            fprintf(this.FID,"%s(1).ColSpecs = specs;\n",tblColSpecVarName);
            fprintf(this.FID,"%s.ColSpecGroups = %s;\n\n",domTableName,tblColSpecVarName);
        end

        function propName=getPropName(~,name)


            import mlreportgen.rpt2api.exprstr.Parser

            parser=Parser(name);
            parse(parser);

            if~isempty(parser.Expressions)
                propName=string(parser.Expressions{1});
            else
                propName="";
            end
        end



    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cml_prop_table_base
            templateFolder=fullfile(rptgen_cfr_ext_table_section.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end
end
