classdef ObjectVectorReporter<mlreportgen.report.internal.variable.VariableReporter













    methods

        function this=ObjectVectorReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.VariableReporter(reportOptions,...
            varName,varValue);


            this.Hierarchical=true;
        end

        function content=makeAutoReport(this)


            content=this.makeParaReport();
        end

        function baseTable=makeTabularReport(this)



            baseTable=copy(this.ReportOptions.TableReporterTemplate);
            addAnchor(this,baseTable);


            if(this.ReportOptions.IncludeTitle)
                appendTitle(baseTable,getTitleText(this));
            end


            valueHeading=...
            mlreportgen.dom.Text(getString(message("mlreportgen:report:VariableReporter:value")));
            valueHeading.Bold=true;

            dataTypeHeading=...
            mlreportgen.dom.Text(getString(message("mlreportgen:report:VariableReporter:dataType")));
            dataTypeHeading.Bold=true;



            paraContent=getParaTextualContent(this);
            domPara=mlreportgen.dom.Paragraph;
            for i=1:length(paraContent)
                append(domPara,paraContent{i});
            end

            tableData=cell(2,2);
            tableData{1,1}=valueHeading;
            tableData{1,2}=domPara;
            tableData{2,1}=dataTypeHeading;
            tableData{2,2}=class(this.VarValue);

            baseTable.Content=mlreportgen.dom.Table(tableData);
        end

    end

    methods(Access=protected)

        function textualContent=getTextualContent(this)


            if strcmp(this.ReportOptions.DisplayPolicy,"Inline Text")||...
                this.ReporterLevel>this.ReportOptions.DepthLimit
                textualContent=getInlineTextualContent(this);
            else
                textualContent=getParaTextualContent(this);
            end
        end

        function element=getVectorElement(this,index)



            element=this.VarValue(index);
        end

        function leftBracket=getLeftBracket(this)%#ok<MANU>



            leftBracket="[";
        end

        function rightBracket=getRightBracket(this)%#ok<MANU>



            rightBracket="]";
        end

    end

    methods(Access=private)

        function textualContent=getInlineTextualContent(this)


            textualContent="";


            textualContent=strcat(textualContent,getLeftBracket(this));

            formatSpec=this.ReportOptions.NumericFormat;


            numElems=length(this.VarValue);
            for iElem=1:numElems
                elemValue=getVectorElement(this,iElem);

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
                    elemStringValue=mlreportgen.utils.normalizeString(...
                    mlreportgen.utils.toString(elemValue,[],[],formatSpec));
                end

                textualContent=strcat(textualContent,elemStringValue);

                if iElem<numElems

                    textualContent=strcat(textualContent,", ");
                end
            end


            textualContent=strcat(textualContent,getRightBracket(this));
        end

        function textualContent=getParaTextualContent(this)


            import mlreportgen.report.internal.variable.*


            numElems=length(this.VarValue);
            numSeparaters=numElems-1;
            numSpaces=numElems-1;
            numBrackets=2;
            textualContent=cell(1,...
            numElems+numSeparaters+numBrackets+numSpaces);
            counter=1;


            textualContent{counter}=mlreportgen.dom.Text(getLeftBracket(this));
            counter=counter+1;


            titleText=getTitleText(this);
            for iElem=1:numElems
                elemValue=this.getVectorElement(iElem);
                elemTitleSuffix=sprintf("(%d)",iElem);
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
                        if iElem~=1





                            textualContent{counter}=" ";
                            counter=counter+1;
                        end
                        textualContent{counter}=forwardLink;
                        counter=counter+1;



                        elemReporter.ReportOptions.IncludeTitle=true;
                        ReporterQueue.instance().add(elemReporter);
                    else
                        elemReporter.ReportOptions.IncludeTitle=false;
                        domText=elemReporter.makeTextReport();
                        if iElem~=1





                            textualContent{counter}=" ";
                            counter=counter+1;
                        end
                        textualContent{counter}=domText;
                        counter=counter+1;
                    end
                else
                    if iElem~=1





                        textualContent{counter}=" ";
                        counter=counter+1;
                    end
                    textualContent{counter}=forwardLink;
                    counter=counter+1;
                end

                if iElem<numElems




                    textualContent{counter}=mlreportgen.dom.Text(",");
                    counter=counter+1;
                end
            end


            textualContent{counter}=...
            mlreportgen.dom.Text(getRightBracket(this));
        end

    end

end