classdef LogicalArrayReporter<mlreportgen.report.internal.variable.ArrayReporter





    properties(Access=private,Hidden)


        LogicalTrue{mlreportgen.report.validators.mustBeString}=[]


        LogicalFalse{mlreportgen.report.validators.mustBeString}=[]
    end

    methods

        function this=LogicalArrayReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.ArrayReporter(reportOptions,...
            varName,varValue);

            this.LogicalTrue=...
            getString(message("mlreportgen:report:VariableReporter:logicalTrue"));

            this.LogicalFalse=...
            getString(message("mlreportgen:report:VariableReporter:logicalFalse"));
        end

        function content=makeParaReport(this)


            arraySize=size(this.VarValue);

            if length(arraySize)>2


                if(this.ReportOptions.IncludeTitle)
                    arrayTitle=getTitleText(this);
                end



                make2DArrayReporters(this,this.VarValue,arrayTitle,[]);
                content=[];
            else

                domPara=clone(this.ReportOptions.ParagraphReporterTemplate);
                addAnchor(this,domPara);

                numRows=arraySize(1);
                numCols=arraySize(2);


                titleText=getTitleText(this);
                if(this.ReportOptions.IncludeTitle)
                    titleSuffix=sprintf("(%i,%i)",numRows,numCols);
                    appendParaTitle(this,domPara,[titleText,{titleSuffix}]);
                    domPara.append(mlreportgen.dom.LineBreak());
                end


                for iRow=1:numRows

                    rowTitleSuffix=sprintf("(%i,:). ",iRow);
                    appendParaTitle(this,domPara,[titleText,{rowTitleSuffix}]);


                    rowText="[";
                    for iCol=1:numCols
                        if this.VarValue(iRow,iCol)
                            rowText=strcat(rowText,this.LogicalTrue);
                        else
                            rowText=strcat(rowText,this.LogicalFalse);
                        end

                        if iCol<numCols
                            rowText=strcat(rowText," ");
                        else
                            rowText=strcat(rowText,"]");
                        end
                    end
                    domPara.append(mlreportgen.dom.Text(rowText));


                    if iRow~=numRows
                        domPara.append(mlreportgen.dom.LineBreak());
                    end
                end
                content=domPara;
            end
        end

    end

    methods(Access=protected)

        function textValue=getTextValue(this)


            arraySize=size(this.VarValue);
            if length(arraySize)>2


                textValue=...
                getTextValue@mlreportgen.report.internal.variable.ArrayReporter(this);
            else

                numRows=arraySize(1);
                numCols=arraySize(2);

                textValue="[";
                for iRow=1:numRows
                    for iCol=1:numCols
                        if this.VarValue(iRow,iCol)
                            textValue=strcat(textValue,this.LogicalTrue);
                        else
                            textValue=strcat(textValue,this.LogicalFalse);
                        end

                        if iCol<numCols
                            textValue=strcat(textValue," ");
                        end
                    end
                    if iRow<numRows
                        textValue=strcat(textValue,"; ");
                    end
                end
                textValue=strcat(textValue,"]");
            end
        end

        function content=getTableContent(this)



            arraySize=size(this.VarValue);
            numRows=arraySize(1);
            numCols=arraySize(2);
            tableData=cell(numRows,numCols);

            for iRow=1:numRows
                for iCol=1:numCols
                    if this.VarValue(iRow,iCol)
                        textValue=this.LogicalTrue;
                    else
                        textValue=this.LogicalFalse;
                    end
                    tableData{iRow,iCol}=textValue;
                end
            end

            content=mlreportgen.dom.Table(tableData);
        end

    end

end