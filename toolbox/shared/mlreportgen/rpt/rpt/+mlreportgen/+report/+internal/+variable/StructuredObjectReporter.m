classdef(Abstract)StructuredObjectReporter<...
    mlreportgen.report.internal.variable.VariableReporter



















    methods

        function this=StructuredObjectReporter(reportOptions,varName,varValue)
            this@mlreportgen.report.internal.variable.VariableReporter(reportOptions,...
            varName,varValue);



            this.Hierarchical=true;
        end

        function content=makeAutoReport(this)


            content=this.makeTabularReport();
        end

        function content=makeTabularReport(this)




            import mlreportgen.report.internal.variable.*


            props=getObjectProperties(this);
            numProps=length(props);

            if numProps~=0
                baseTable=copy(this.ReportOptions.TableReporterTemplate);
                addAnchor(this,baseTable);


                titleContent=getTitleText(this);
                if(this.ReportOptions.IncludeTitle)
                    appendTitle(baseTable,titleContent);
                end


                tableData=cell(numProps,2);
                for i=1:numProps
                    propName=props{i};
                    propValue=this.VarValue.(propName);

                    tableData{i,1}=propName;
                    if isempty(propValue)
                        tableData{i,2}="";
                    else
                        propTitle=[titleContent,{strcat(".",propName)}];



                        linkResolver=ReporterLinkResolver.instance();
                        forwardLink=linkResolver.getLink(propValue);

                        if isempty(forwardLink)


                            propReportOptions=ReportOptions(this.ReportOptions);
                            propReporter=...
                            ReporterFactory.makeReporter(propReportOptions,...
                            strcat(this.VarName,".",propName),propValue);
                            propReporter.TitleWithSuffix=propTitle;
                            propReporter.ReporterLevel=this.ReporterLevel+1;




                            if propReporter.Hierarchical&&...
                                propReporter.ReporterLevel<=propReporter.ReportOptions.DepthLimit






                                forwardLink=makeLink(this,propReporter,propTitle);
                                tableData{i,2}=forwardLink;



                                propReporter.ReportOptions.IncludeTitle=true;
                                ReporterQueue.instance().add(propReporter);
                            else
                                propReporter.ReportOptions.IncludeTitle=false;
                                tableData{i,2}=propReporter.makeTextReport();
                            end
                        else
                            tableData{i,2}=forwardLink;
                        end
                    end
                end


                tableHeader=getTableHeader(this);


                baseTable.Content=mlreportgen.dom.FormalTable(tableHeader,tableData);
                content=baseTable;
            else


                para=clone(this.ReportOptions.ParagraphReporterTemplate);
                addAnchor(this,para);
                if(this.ReportOptions.IncludeTitle)
                    titleSuffix=strcat("(",class(this.VarValue),")");
                    titleText=[getTitleText(this),{titleSuffix}];
                    appendParaTitle(this,para,titleText);
                    append(para,mlreportgen.dom.LineBreak);
                end
                noteText=...
                mlreportgen.dom.Text(getString(message("mlreportgen:report:VariableReporter:proplessObjNote")));
                append(para,noteText);

                content=para;
            end
        end

        function registerLink(this)





            import mlreportgen.report.internal.variable.ReporterLinkResolver

            resolver=ReporterLinkResolver.instance();
            putLink(resolver,this.VarValue,this);
        end

    end

    methods(Abstract,Access=protected)


        propNames=getObjectProperties(this);
    end

    methods(Access=protected)

        function textualContent=getTextualContent(this)





            textualContent=...
            getTextualContent@mlreportgen.report.internal.variable.VariableReporter(this);

            textualContent=...
            mlreportgen.utils.normalizeString(textualContent);
        end

        function tableHeader=getTableHeader(this)%#ok<MANU>


            tableHeader={...
            getString(message("mlreportgen:report:VariableReporter:property")),...
            getString(message("mlreportgen:report:VariableReporter:value"))...
            };
        end

        function propNames=getFilteredPropNames(this,props)



            numProps=length(props);
            filtered=false(1,numProps);


            for i=1:numProps
                tf=isFilteredProperty(this,this.VarValue,props{i});
                filtered(i)=tf;
            end


            if~isempty(props)
                props(filtered)=[];
            end


            numFilteredProps=length(props);
            propNames=cell(numFilteredProps,1);
            for i=1:numFilteredProps
                propNames{i,1}=props{i}.Name;
            end
        end

        function isFiltered=isFilteredProperty(this,variableObject,property)









            isFiltered=false;
            filterCode=this.ReportOptions.PropertyFilterFcn;
            if(~isempty(filterCode))

                try

                    variableName=string(this.VarName);
                    propertyName=string(property.Name);

                    if isa(filterCode,'function_handle')
                        isFiltered=filterCode(variableName,variableObject,propertyName);
                    else


                        eval(filterCode);
                    end

                catch me
                    warning(message("mlreportgen:report:warning:filterFcnError","PropertyFilterFcn",me.message));
                end

            end
        end

    end

end

