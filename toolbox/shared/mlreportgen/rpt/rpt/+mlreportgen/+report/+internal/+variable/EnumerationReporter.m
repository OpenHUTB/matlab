classdef EnumerationReporter<mlreportgen.report.internal.variable.VariableReporter






    methods

        function this=EnumerationReporter(reportOptions,varName,varValue)

            this@mlreportgen.report.internal.variable.VariableReporter(...
            reportOptions,varName,varValue);

        end

        function content=makeAutoReport(this)






            if isempty(properties(this.VarValue))
                content=this.makeParaReport();
            else
                content=this.makeTabularReport();
            end
        end

        function content=makeTabularReport(this)






            import mlreportgen.report.internal.variable.*;

            baseTable=copy(this.ReportOptions.TableReporterTemplate);
            addAnchor(this,baseTable);


            if(this.ReportOptions.IncludeTitle)
                appendTitle(baseTable,getTitleText(this));
            end

            if isempty(properties(this.VarValue))


                valueHeading=...
                mlreportgen.dom.Text(getString(message("mlreportgen:report:VariableReporter:value")));
                valueHeading.Bold=true;

                dataTypeHeading=...
                mlreportgen.dom.Text(getString(message("mlreportgen:report:VariableReporter:dataType")));
                dataTypeHeading.Bold=true;

                table={...
                valueHeading,getTextValue(this);
                dataTypeHeading,class(this.VarValue)...
                };

                baseTable.Content=mlreportgen.dom.Table(table);
            else




                MCOSreporterObj=MCOSObjectReporter(this.ReportOptions,this.VarName,this.VarValue);
                MCOSBaseTable=MCOSreporterObj.makeTabularReport();


                domPara=mlreportgen.dom.Paragraph();
                enumeratedValueHeading=...
                mlreportgen.dom.Text(getString(message("mlreportgen:report:VariableReporter:enumeratedValue")));
                enumeratedValueHeading.Bold=true;



                domPara.append(enumeratedValueHeading);

                postfix=mlreportgen.dom.Text(": ");
                postfix.Bold=true;
                domPara.append(postfix);

                append(domPara,string(this.VarValue));


                table=mlreportgen.dom.Table(2);



                row1=mlreportgen.dom.TableRow();
                tableEntry=mlreportgen.dom.TableEntry(domPara);
                tableEntry.ColSpan=2;
                row1.append(tableEntry);
                table.append(row1);




                propertyValueTable=MCOSBaseTable.Content;



                append(table,clone(propertyValueTable.Header.Children(1)));



                body=propertyValueTable.Body;
                nChildren=length(body.Children);
                for i=1:nChildren
                    row=body.Children(i);
                    append(table,row.clone());
                end


                baseTable.Content=table;
            end
            content=baseTable;
        end
    end
end