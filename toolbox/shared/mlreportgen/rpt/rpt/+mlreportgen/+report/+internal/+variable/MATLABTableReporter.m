classdef MATLABTableReporter<mlreportgen.report.internal.variable.VariableReporter




    methods

        function this=MATLABTableReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.VariableReporter(reportOptions,...
            varName,varValue);


            this.Hierarchical=true;
        end

        function content=makeAutoReport(this)


            content=makeTabularReport(this);
        end

        function content=makeTabularReport(this)




            if~isempty(this.VarValue)
                baseTable=copy(this.ReportOptions.TableReporterTemplate);
                addAnchor(this,baseTable);


                if(this.ReportOptions.IncludeTitle)
                    appendTitle(baseTable,getTitleText(this));
                end


                baseTable.Content=mlreportgen.dom.MATLABTable(this.VarValue);
                content=baseTable;
            else


                para=clone(this.ReportOptions.ParagraphReporterTemplate);
                addAnchor(this,para);

                titleSuffix=strcat("(",class(this.VarValue),")");
                appendParaTitle(this,para,[getTitleText(this),{titleSuffix}]);
                append(para,mlreportgen.dom.LineBreak);

                noteText=...
                mlreportgen.dom.Text(getString(message("mlreportgen:report:VariableReporter:emptyMATLABTableNote")));
                append(para,noteText);

                content=para;
            end
        end

    end

end