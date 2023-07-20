classdef(Abstract)VariableReporter<handle








    properties


        VarName{mlreportgen.report.validators.mustBeString}=[]


        VarValue=[]


        ReportOptions{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.internal.variable.ReportOptions',ReportOptions)}=[];




        ReporterLevel{mlreportgen.utils.validators.mustBeZeroOrPositiveNumber}=0;










        Hierarchical{mlreportgen.report.validators.mustBeLogical}=false;




        ReporterID{mlreportgen.report.validators.mustBeString}=[];





        LinkedTitle=[];

        TitleWithSuffix=[];

    end

    methods(Abstract)


        content=makeAutoReport(reporter);





        baseTable=makeTabularReport(reporter);

    end

    methods

        function this=VariableReporter(reportOptions,varName,varValue)




            import mlreportgen.report.internal.variable.ReporterQueue

            this.ReportOptions=reportOptions;
            this.VarName=varName;
            this.VarValue=varValue;

            id=ReporterQueue.instance().getReporterID();
            this.ReporterID=strcat(this.VarName,num2str(id));
        end

        function content=report(this)



            switch this.ReportOptions.DisplayPolicy
            case "Auto"
                content=makeAutoReport(this);
            case "Table"
                content=makeTabularReport(this);
            case "Paragraph"
                content=makeParaReport(this);
            case "Inline Text"
                content=makeTextReport(this);
            end
        end

        function domText=makeTextReport(this)








            domText=clone(this.ReportOptions.InlineTextReporterTemplate);
            textualContent=getTextualContent(this);

            if this.ReportOptions.IncludeTitle
                titleText=getTitleText(this);
                if isstring(titleText)
                    domText.Content=strcat(domText.Content,titleText," ",textualContent);
                else
                    titleStr=mlreportgen.utils.internal.getDOMContentString(titleText);
                    domText.Content=strcat(domText.Content,titleStr," ",textualContent);
                end
            else
                domText.Content=strcat(domText.Content,textualContent);
            end
        end

        function domPara=makeParaReport(this)








            domPara=clone(this.ReportOptions.ParagraphReporterTemplate);
            addAnchor(this,domPara);





            if(this.ReportOptions.IncludeTitle)
                titleContent=getTitleText(this);

                appendParaTitle(this,domPara,titleContent);

                postfix=mlreportgen.dom.Text(". ");
                postfix.Bold=true;
                domPara.append(postfix);
            end





            textualContent=getTextualContent(this);
            if iscell(textualContent)
                for i=1:length(textualContent)
                    domPara.append(textualContent{i});
                end
            else
                domVarValue=mlreportgen.dom.Text(textualContent);
                domPara.append(domVarValue);
            end
        end

        function registerLink(this)%#ok<MANU>




        end

        function link=getDOMLink(this,reporterID,titleText)


            id=reporterID;
            if~this.ReportOptions.Debug

                id=mlreportgen.utils.normalizeLinkID(id);
            end

            if isempty(titleText)
                titleText=getTitleText(this);
            end
            if(isscalar(titleText)&&isstring(titleText))||ischar(titleText)
                link=mlreportgen.dom.InternalLink(id,titleText);
            else
                link=mlreportgen.dom.InternalLink();
                link.Target=id;
                nTitleContent=numel(titleText);
                for k=1:nTitleContent
                    content=titleText{k};
                    if isa(content,"mlreportgen.dom.Link")


                        for child=content.Children
                            append(link,clone(child));
                        end
                    elseif isa(content,"mlreportgen.dom.Node")
                        append(link,clone(content));
                    else
                        if isempty(link.Children)

                            append(link,content);
                        else


                            lastChild=link.Children(end);
                            if isa(lastChild,"mlreportgen.dom.Text")&&...
                                (isstring(content)||ischar(content))
                                lastChild.Content=strcat(lastChild.Content,content);
                            else
                                append(link,content);
                            end
                        end
                    end
                end
            end
        end

    end

    methods(Access=protected)

        function textValue=getTextValue(this)

            if isinteger(this.VarValue)
                textValue=mlreportgen.utils.toString(this.VarValue);
            else
                textValue=mlreportgen.utils.toString(this.VarValue,[],[],this.ReportOptions.NumericFormat);
            end
        end

        function textualContent=getTextualContent(this)




            textualContent=getTextValue(this);
        end

        function title=getTitleText(this)





            if~isempty(this.LinkedTitle)




                title={this.LinkedTitle};
            elseif~isempty(this.TitleWithSuffix)
                title=this.TitleWithSuffix;
            elseif~isempty(this.ReportOptions.Title)



                title=this.ReportOptions.Title;
                if ischar(title)
                    title=string(title);
                end
                if~iscell(title)
                    title=num2cell(title);
                end
            else

                title=this.VarName;
            end

            if(this.ReportOptions.ShowDataType)
                dataTypeStr=strcat(class(this.VarValue),":");
                if isstring(title)||ischar(title)
                    title=strcat(dataTypeStr,title);
                else
                    title=...
                    [{mlreportgen.dom.Text(dataTypeStr)},title];
                end
            end
        end

        function appendParaTitle(this,domPara,titleContent)
            if ischar(titleContent)||(~iscell(titleContent)&&isscalar(titleContent))

                domTitle=mlreportgen.dom.Text(titleContent);
                domTitle.Bold=true;
                domPara.append(domTitle);
            else

                nElems=numel(titleContent);
                for i=1:nElems
                    iContent=titleContent{i};
                    if isstring(iContent)||ischar(iContent)
                        iContent=mlreportgen.dom.Text(iContent);
                    else


                        iContent=clone(iContent);
                    end
                    iContent.Style=[iContent.Style,{mlreportgen.dom.Bold(true)}];
                    domPara.append(iContent);
                end
            end
        end

        function anchor=makeAnchor(this)


            id=this.ReporterID;

            if~this.ReportOptions.Debug

                id=mlreportgen.utils.normalizeLinkID(id);
            end

            anchor=mlreportgen.dom.LinkTarget(id);
        end

        function link=makeLink(this,linkedReporter,titleText)








            link=getDOMLink(this,linkedReporter.ReporterID,titleText);





            linkedReporter.LinkedTitle=getDOMLink(this,this.ReporterID,titleText);
        end

        function addAnchor(this,obj)








            anchor=makeAnchor(this);

            if isa(obj,"mlreportgen.dom.Paragraph")
                obj.append(clone(anchor));
            elseif isa(obj,"mlreportgen.report.BaseTable")
                obj.LinkTarget=clone(anchor);
            end
        end

    end

end