classdef rptgen_cfr_table<mlreportgen.rpt2api.ComponentConverter










































    methods

        function this=rptgen_cfr_table(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser


            mlVar=mlreportgen.report.MATLABVariable(this.Component.Source);
            content=getVariableValue(mlVar);
            [numRows,numCols]=size(content);


            headerRowString=this.Component.numHeaderRowsString;
            parser=Parser(headerRowString);
            parse(parser);
            numHeaderRows=str2double(headerRowString);


            numFooterRows=0;
            if strcmpi(this.Component.Footer,"LASTROWS")
                footerRowString=this.Component.numFooterRowsString;
                parser=Parser(footerRowString);
                parse(parser);
                numFooterRows=str2double(footerRowString);
            end


            numBodyRows=numRows-numHeaderRows-numFooterRows;
            if(numBodyRows<=0)

                template=mlreportgen.rpt2api.rptgen_cfr_table.getTemplate('noContentRow');
                fprintf(this.FID,"%s",template);
                return;
            end



            writeStartBanner(this);


            fprintf(this.FID,'mlVar = MATLABVariable("%s");\n',this.Component.Source);
            fprintf(this.FID,'content = getVariableValue(mlVar);\n');

            if this.Component.ShrinkEntries


                if iscell(content)
                    fprintf(this.FID,...
                    'content = cellfun(@(x) mlreportgen.utils.toString(x,2048),content,"UniformOutput",false);\n');
                else
                    fprintf(this.FID,...
                    'content = arrayfun(@(x) mlreportgen.utils.toString(x,2048),content,"UniformOutput",false);\n');
                end
            end



            if(numHeaderRows>0)||(numFooterRows>0)

                if(numHeaderRows>0)
                    fprintf(this.FID,"headerContent = content(1:%d,:);\n",numHeaderRows);
                end


                fprintf(this.FID,"bodyContent = content(%d:%d,:);\n",numHeaderRows+1,numHeaderRows+numBodyRows);


                if(numFooterRows>0)
                    fprintf(this.FID,"footerContent = content(%d:end,:);\n",numHeaderRows+numBodyRows+1);
                end


                if(numHeaderRows>0)&&(numFooterRows>0)
                    fprintf(this.FID,"rptArrayBasedDOMTableObj = FormalTable(headerContent,bodyContent,footerContent);\n");
                elseif(numHeaderRows>0)
                    fprintf(this.FID,"rptArrayBasedDOMTableObj = FormalTable(headerContent,bodyContent);\n");
                elseif(numFooterRows>0)



                    fprintf(this.FID,"rptArrayBasedDOMTableObj = FormalTable(bodyContent);\n");

                    footerContent=content(numHeaderRows+numBodyRows+1:end,:);
                    [numFooterRows,numFooterCols]=size(footerContent);
                    for iRow=1:numFooterRows
                        fprintf(this.FID,"footerRow = append(rptArrayBasedDOMTableObj.Footer,TableRow);\n");
                        for iCol=1:numFooterCols
                            fprintf(this.FID,"append(footerRow,TableEntry(footerContent{%d,%d}));\n",iRow,iCol);
                        end
                    end
                end
            else


                fprintf(this.FID,"rptArrayBasedDOMTableObj = Table(content);\n");
            end


            tableVarName=getVariableName(this);
            fprintf(this.FID,...
            "%s = BaseTable(rptArrayBasedDOMTableObj);\n",...
            tableVarName);


            title=this.Component.TableTitle;
            if~isempty(title)
                Parser.writeExprStr(this.FID,...
                title,sprintf("%s.Title",tableVarName));
            end


            if this.Component.isPgwide
                fprintf(this.FID,'%s = "%s";\n',...
                sprintf("%s.TableWidth",tableVarName),"100%");
            end


            if~isempty(this.Component.ColumnWidths)
                colWidths=this.Component.ColumnWidths;





                if(length(colWidths)>numCols)
                    colWidths=colWidths(1:numCols);
                elseif(length(colWidths)<numCols)
                    numberOfUndefinedColWidths=numCols-length(colWidths);

                    warnDefaultColWidthsMessage=sprintf(...
                    "'%s' column widths are not fully specified! Remaining %d column(s) default to size 1.",...
                    this.Component.getDisplayLabel,numberOfUndefinedColWidths);
                    fprintf(this.FID,'warning("%s");\n',warnDefaultColWidthsMessage);
                    colWidths=[colWidths,ones(1,numberOfUndefinedColWidths)];
                end


                fprintf(this.FID,"grps(1) = TableColSpecGroup;\n");
                for iCol=1:numCols


                    currColPercentWidth=...
                    strcat(num2str((colWidths(iCol)/sum(colWidths))*100),"%");

                    fprintf(this.FID,"specs(%s) = TableColSpec;\n",num2str(iCol));
                    fprintf(this.FID,"specs(%s).Style = {Width(""%s"")};\n",...
                    num2str(iCol),currColPercentWidth);
                end

                fprintf(this.FID,"grps(1).ColSpecs = specs;\n");
                fprintf(this.FID,"rptArrayBasedDOMTableObj.ColSpecGroups = grps;\n");
            end


            alignment=this.Component.AllAlign;
            if~strcmpi(alignment,"justify")
                fprintf(this.FID,'rptArrayBasedDOMTableObj.TableEntriesHAlign = "%s";\n',...
                alignment);
            end


            if~this.Component.isBorder
                fprintf(this.FID,...
                'rptArrayBasedDOMTableObj.TableEntriesStyle = [rptArrayBasedDOMTableObj.TableEntriesStyle {Border("none")}];\n');
            end


            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n\n",...
            parentName,tableVarName);



            writeEndBanner(this);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptArrayBasedTable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_table.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_table
            templateFolder=fullfile(rptgen_cfr_table.getClassFolder,...
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
