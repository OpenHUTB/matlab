classdef ObjectArrayReporter<mlreportgen.report.internal.variable.ArrayReporter





    methods

        function this=ObjectArrayReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.ArrayReporter(reportOptions,...
            varName,varValue);


            this.Hierarchical=true;
        end

        function content=makeParaReport(this)

            import mlreportgen.report.internal.variable.*

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
                    rowTitleSuffix=sprintf("(%i,:)",iRow);
                    rowTitle=[titleText,{rowTitleSuffix}];

                    reportOptions=ReportOptions(this.ReportOptions);
                    rowReporter=ReporterFactory.makeReporter(reportOptions,...
                    strcat(this.VarName,rowTitleSuffix),this.VarValue(iRow,:));
                    rowReporter.TitleWithSuffix=rowTitle;
                    rowPara=rowReporter.makeParaReport();


                    for i=1:numel(rowPara.Children)
                        domPara.append(clone(rowPara.Children(i)));
                    end


                    if iRow~=numRows
                        domPara.append(mlreportgen.dom.LineBreak);
                    end
                end
                content=domPara;
            end
        end

    end

    methods(Access=protected)

        function textValue=getTextValue(this)



            formatSpec=this.ReportOptions.NumericFormat;
            arraySize=size(this.VarValue);
            if length(arraySize)>2


                textValue=...
                getTextValue@mlreportgen.report.internal.variable.ArrayReporter(this);
            else

                numRows=arraySize(1);
                numCols=arraySize(2);

                textValue=getLeftBracket(this);
                for iRow=1:numRows
                    for iCol=1:numCols
                        elemValue=getArrayElement(this,iRow,iCol);

                        if islogical(elemValue)
                            if elemValue
                                elemStringValue=...
                                getString(message("mlreportgen:report:VariableReporter:logicalTrue"));
                            else
                                elemStringValue=...
                                getString(message("mlreportgen:report:VariableReporter:logicalFalse"));
                            end
                        elseif isinteger(elemValue)

                            elemStringValue=...
                            mlreportgen.utils.normalizeString(...
                            mlreportgen.utils.toString(elemValue));
                        else
                            elemStringValue=...
                            mlreportgen.utils.normalizeString(...
                            mlreportgen.utils.toString(elemValue,[],[],formatSpec));
                        end

                        textValue=strcat(textValue,elemStringValue);

                        if iCol<numCols
                            textValue=strcat(textValue,", ");
                        end
                    end
                    if iRow<numRows
                        textValue=strcat(textValue,"; ");
                    end
                end
                textValue=strcat(textValue,getRightBracket(this));
            end
        end

        function content=getTableContent(this)


            import mlreportgen.report.internal.variable.*
            arraySize=size(this.VarValue);
            numRows=arraySize(1);
            numCols=arraySize(2);
            tableData=cell(numRows,numCols);

            titleText=getTitleText(this);
            for iRow=1:numRows
                for iCol=1:numCols
                    elemValue=getArrayElement(this,iRow,iCol);
                    elemTitleSuffix=sprintf("(%d,%d)",iRow,iCol);
                    elemTitle=[titleText,{elemTitleSuffix}];



                    linkResolver=ReporterLinkResolver.instance();
                    forwardLink=linkResolver.getLink(elemValue);
                    if isempty(forwardLink)

                        reportOptions=ReportOptions(this.ReportOptions);
                        elemReporter=ReporterFactory.makeReporter(reportOptions,...
                        strcat(this.VarName,elemTitleSuffix),elemValue);
                        elemReporter.TitleWithSuffix=elemTitle;
                        elemReporter.ReporterLevel=this.ReporterLevel+1;




                        if elemReporter.Hierarchical&&...
                            elemReporter.ReporterLevel<=elemReporter.ReportOptions.DepthLimit






                            forwardLink=makeLink(this,elemReporter,elemTitle);
                            tableData{iRow,iCol}=forwardLink;



                            elemReporter.ReportOptions.IncludeTitle=true;
                            ReporterQueue.instance().add(elemReporter);
                        else
                            elemReporter.ReportOptions.IncludeTitle=false;
                            tableData{iRow,iCol}=elemReporter.makeTextReport();
                        end
                    else
                        tableData{iRow,iCol}=forwardLink;
                    end
                end
            end

            content=mlreportgen.dom.Table(tableData);
        end

        function element=getArrayElement(this,rowIdx,colIdx)



            element=this.VarValue(rowIdx,colIdx);
        end

        function leftBracket=getLeftBracket(this)%#ok<MANU>



            leftBracket="[";
        end

        function rightBracket=getRightBracket(this)%#ok<MANU>



            rightBracket="]";
        end

    end

end