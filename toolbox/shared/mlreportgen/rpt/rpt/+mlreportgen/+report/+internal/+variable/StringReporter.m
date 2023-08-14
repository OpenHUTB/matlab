classdef StringReporter<mlreportgen.report.internal.variable.VariableReporter















    methods

        function this=StringReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.VariableReporter(...
            reportOptions,varName,varValue);
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

            tableData=cell(2,2);
            tableData{1,1}=valueHeading;
            tableData{1,2}=getTextValue(this);
            tableData{2,1}=dataTypeHeading;
            tableData{2,2}=class(this.VarValue);
            baseTable.Content=mlreportgen.dom.Table(tableData);
        end

    end

end