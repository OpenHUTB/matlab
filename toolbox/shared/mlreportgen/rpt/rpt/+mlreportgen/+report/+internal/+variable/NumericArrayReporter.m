classdef NumericArrayReporter<mlreportgen.report.internal.variable.ArrayReporter





    methods

        function this=NumericArrayReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.ArrayReporter(reportOptions,...
            varName,varValue);
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


                if isinteger(this.VarValue)
                    formatSpec=[];
                else
                    formatSpec=this.ReportOptions.NumericFormat;
                end


                for iRow=1:numRows

                    rowTitleSuffix=sprintf("(%i,:). ",iRow);
                    appendParaTitle(this,domPara,[titleText,{rowTitleSuffix}]);


                    rowText=mlreportgen.utils.toString(this.VarValue(iRow,:),[],[],formatSpec);
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

        function textualContent=getTextualContent(this)





            textualContent=...
            getTextualContent@mlreportgen.report.internal.variable.ArrayReporter(this);

            textualContent=...
            mlreportgen.utils.normalizeString(textualContent);


            textualContent=regexprep(textualContent," +"," ");
        end

        function content=getTableContent(this)


            formatSpec=this.ReportOptions.NumericFormat;
            if~isempty(formatSpec)&&~isinteger(this.VarValue)
                try
                    formattedVals=arrayfun(@(x)num2str(x,formatSpec),this.VarValue,...
                    "UniformOutput",false);
                    content=mlreportgen.dom.Table(formattedVals);
                catch me
                    warning(message("mlreportgen:report:warning:invalidNumericFormat",[me.message]));
                    content=mlreportgen.dom.Table(this.VarValue);
                end
            elseif isobject(this.VarValue)


                strVals=arrayfun(@(x)num2str(x),this.VarValue,...
                "UniformOutput",false);
                content=mlreportgen.dom.Table(strVals);
            else
                content=mlreportgen.dom.Table(this.VarValue);
            end
        end

    end

end