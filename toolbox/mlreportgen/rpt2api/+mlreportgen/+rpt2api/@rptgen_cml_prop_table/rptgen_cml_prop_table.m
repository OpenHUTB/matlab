classdef rptgen_cml_prop_table<mlreportgen.rpt2api.rptgen_cml_prop_table_base






























    properties(Access=protected)


        DOMTableName="rptMLPropDOMTable";
        DOMTableColName="rptMLPropTable_NCols";
        DOMTableEntryBorder="rptMLTableEntryBorder";
        DOMTableEntryName="rptMLPropTableEntry";
    end

    properties(Access=private,Constant)


        DOMTableRowName="rptMLPropTableRow";
        DOMTblEntryPara="rptMLTableEntryPara";
        DOMTblEntryParaText="rptMLTableEntryText";
    end

    methods
        function this=rptgen_cml_prop_table(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end
    end

    methods(Access=protected)

        function write(this)



            writeStartBanner(this);
            createBaseTable(this);



            writeEndBanner(this);
        end

        function writeTwoColPropTable(this,tableContent)




            colWidth=this.Component.ColWidths;
            fprintf(this.FID,"%s = %d;\n",...
            this.DOMTableColName,numel(colWidth));



            registerHelperFunction(this.RptFileConverter,"getMLPropTblEntryDOMObj");


            createDOMTable(this);




            content=numel(tableContent);
            for iRow=1:content

                tblRowCounterStr=num2str(iRow);

                tblRowName=strcat(this.DOMTableRowName,tblRowCounterStr);

                tblEntryName=strcat(this.DOMTableEntryName,tblRowCounterStr);




                tableEntryCounter=1;


                createPropNameTblEntry(this,tblRowName,iRow,...
                tblEntryName,tableEntryCounter);



                appendTblEntry(this,tblRowName,iRow,...
                tblEntryName,tableEntryCounter);


                tableEntryCounter=tableEntryCounter+1;


                propName=getPropName(this,tableContent(iRow).Text);


                fprintf(this.FID,...
                "%% Create a table entry that holds the value of the property ""%s"".\n",...
                propName);

                if strcmp(propName,"who")








                    delimiter='\n';
                    fprintf(this.FID,...
                    "%s = getMLPropTblEntryDOMObj(strjoin(rptState.InitWSVars,'%s'));\n",...
                    this.DOMTblEntryParaText,delimiter);
                    fprintf(this.FID,"%s.WhiteSpace = ""preserve"";\n",...
                    this.DOMTblEntryParaText);
                    fprintf(this.FID,...
                    "%s_%d = TableEntry(%s);\n",...
                    tblEntryName,tableEntryCounter,this.DOMTblEntryParaText);

                elseif strcmp(propName,"ans")




                    fprintf(this.FID,...
                    "%s_%d = TableEntry(getMLPropTblEntryDOMObj(rptState.InitWSAnsVar));\n",...
                    tblEntryName,tableEntryCounter);
                else


                    fprintf(this.FID,...
                    "%s_%d = TableEntry(getMLPropTblEntryDOMObj(%s));\n",...
                    tblEntryName,tableEntryCounter,propName);
                end



                fwrite(this.FID,...
                "% Append the table entry to the table row."+newline);
                appendTblEntry(this,tblRowName,iRow,...
                tblEntryName,tableEntryCounter);


                fwrite(this.FID,...
                "% Append the table row to the table."+newline);
                fprintf(this.FID,"append(%s,%s);\n \n",...
                getDOMTableVarName(this),tblRowName);

            end
        end

        function writeSingleColPropTable(this,tableContent)




            colWidth=this.Component.ColWidths;
            fprintf(this.FID,"%s = %d;\n",...
            this.DOMTableColName,numel(colWidth));



            registerHelperFunction(this.RptFileConverter,"getMLPropTblEntryDOMObj");


            createDOMTable(this);





            content=numel(tableContent);
            for iRow=1:content



                fwrite(this.FID,...
                "% Create a table row object for the table that contains"+newline);
                fwrite(this.FID,...
                "% the property name/property value pair"+newline);

                tblRowCounterStr=num2str(iRow);
                tblRowName=strcat(this.DOMTableRowName,tblRowCounterStr);
                fprintf(this.FID,"%s = TableRow();\n\n",tblRowName);


                fwrite(this.FID,...
                "% Create a table entry object for the table row."+newline);

                tableEntryName=strcat(this.DOMTableEntryName,tblRowCounterStr);




                tableEntryCounter=1;

                fprintf(this.FID,"%s_%d = TableEntry();\n",...
                tableEntryName,tableEntryCounter);


                applyTableEntryFormats(this,tableContent(iRow),...
                tableEntryName,tableEntryCounter);


                fwrite(this.FID,"% Create a paragraph object."+newline);
                fprintf(this.FID,"%s = Paragraph();\n",...
                this.DOMTblEntryPara);
                fprintf(this.FID,"%s.WhiteSpace = ""preserve"";\n",...
                this.DOMTblEntryPara);


                propName=getPropName(this,tableContent(iRow).Text);

                delimiter='\n';




                renderVal=tableContent(iRow).Render;
                separator=getSeparatorValue(this,renderVal);

                if strcmp(separator,"v")


                    fprintf(this.FID,...
                    "%% Append the value of the property ""%s"" to the paragraph.\n",...
                    propName);
                    if strcmp(propName,"who")








                        fprintf(this.FID,...
                        "%s = getMLPropTblEntryDOMObj(strjoin(rptState.InitWSVars,'%s'));\n",...
                        this.DOMTblEntryParaText,delimiter);
                        fprintf(this.FID,"append(%s,%s);\n\n",...
                        this.DOMTblEntryPara,this.DOMTblEntryParaText);
                    elseif strcmp(propName,"ans")




                        fprintf(this.FID,...
                        "append(%s,getMLPropTblEntryDOMObj(rptState.InitWSAnsVar));\n\n",this.DOMTblEntryPara);
                    else
                        fprintf(this.FID,...
                        "append(%s,getMLPropTblEntryDOMObj(%s));\n\n",...
                        this.DOMTblEntryPara,propName);
                    end
                else










                    fprintf(this.FID,...
                    "%% Create a DOM text object that contains the property name ""%s""\n",propName);
                    fwrite(this.FID,"% and append it to the paragraph."+newline);
                    fprintf(this.FID,"%s = Text(""%s"");\n",...
                    this.DOMTblEntryParaText,propName);

                    if strcmp(renderVal,"N v")||strcmp(renderVal,"N:v")||strcmp(renderVal,"N-v")
                        fprintf(this.FID,"%s.Italic = true;\n",this.DOMTblEntryParaText);
                    end



                    fprintf(this.FID,"append(%s,%s);\n",...
                    this.DOMTblEntryPara,this.DOMTblEntryParaText);


                    fwrite(this.FID,...
                    "% Append the separator to the paragraph."+newline);
                    fprintf(this.FID,"append(%s,""%s"");\n",...
                    this.DOMTblEntryPara,separator);


                    fprintf(this.FID,...
                    "%% Append the value of the property ""%s"" to the paragraph.\n",...
                    propName);
                    if strcmp(propName,"who")








                        fprintf(this.FID,...
                        "%s = getMLPropTblEntryDOMObj(strjoin(rptState.InitWSVars,'%s'));\n",...
                        this.DOMTblEntryParaText,delimiter);
                        fprintf(this.FID,"append(%s,%s);\n",...
                        this.DOMTblEntryPara,this.DOMTblEntryParaText);
                    elseif strcmp(propName,"ans")




                        fprintf(this.FID,...
                        "append(%s,getMLPropTblEntryDOMObj(rptState.InitWSAnsVar));\n",this.DOMTblEntryPara);
                    else
                        fprintf(this.FID,...
                        "append(%s,getMLPropTblEntryDOMObj(%s));\n",this.DOMTblEntryPara,propName);
                    end
                end


                fwrite(this.FID,"% Append the paragraph to the table entry."+newline);
                fprintf(this.FID,"append(%s_%d,%s);\n\n",...
                tableEntryName,tableEntryCounter,this.DOMTblEntryPara);


                fwrite(this.FID,"% Append the table entry to the table row."+newline);
                fprintf(this.FID,"append(%s,%s_%d);\n",...
                tblRowName,tableEntryName,tableEntryCounter);


                fwrite(this.FID,"% Append the table row to the table."+newline);
                fprintf(this.FID,"append(%s,%s);\n\n",...
                getDOMTableVarName(this),tblRowName);
            end
        end

        function writeBaseTableTitle(this,varName,titleVarName)


            import mlreportgen.rpt2api.exprstr.Parser

            Parser.writeExprStr(this.FID,...
            this.Component.TableTitle.Text,titleVarName);

            fprintf(this.FID,...
            "%s.Title = %s;\n",varName,titleVarName);

        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cml_prop_table.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

        function name=getVariableRootName(~)





            name="rptMATLABPropTable";
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cml_prop_table
            templateFolder=fullfile(rptgen_cml_prop_table.getClassFolder,...
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

