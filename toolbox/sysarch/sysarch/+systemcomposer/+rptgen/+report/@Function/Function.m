classdef Function<slreportgen.report.Reporter

    properties
Source
Summary
    end

    methods(Static,Access=private)
        function[table,rowForHeader]=createTableWithProperties()

            import mlreportgen.dom.*;
            table=FormalTable();
            table.Style=[table.Style,{Border('single'),Width('100%'),RowSep('single'),ColSep('single'),FontFamily('Calibri')}];
            table.TableEntriesStyle={HAlign('center')};
            rowForHeader=TableRow();
            tableHeader=append(table,rowForHeader);
            tableHeader.Style=[tableHeader.Style,{InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)}];
        end

        function functionSummaryTable=createTableForSummary()

            import mlreportgen.dom.*
            [functionSummaryTable,rowForHeader]=systemcomposer.rptgen.report.Function.createTableWithProperties();
            Name=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
            Component=TableEntry(message('SystemArchitecture:ReportGenerator:Component').getString);
            Parent=TableEntry(message('SystemArchitecture:ReportGenerator:Parent').getString);
            Period=TableEntry(message('SystemArchitecture:ReportGenerator:Period').getString);
            ExecutionOrder=TableEntry(message('SystemArchitecture:ReportGenerator:ExecutionOrder').getString);
            append(rowForHeader,Name);
            append(rowForHeader,Component);
            append(rowForHeader,Parent);
            append(rowForHeader,Period);
            append(rowForHeader,ExecutionOrder);


        end

        function summaryTable=createFunctionSummaryTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            summaryTable=[];
            functions=this.Source;
            if~isempty(functions)
                summaryTable=systemcomposer.rptgen.report.Function.createTableForSummary();
                len=length(functions);
                for i=1:len
                    row=TableRow();
                    Name=TableEntry(functions(i).Name);
                    append(row,Name);
                    Component=TableEntry(functions(i).Component);
                    append(row,Component);
                    Parent=TableEntry(functions(i).Parent);
                    append(row,Parent);
                    Period=TableEntry(functions(i).Period);
                    append(row,Period);
                    ExecutionOrder=TableEntry(functions(i).ExecutionOrder);
                    append(row,ExecutionOrder);
                    append(summaryTable,row);
                end
            end
        end
    end
    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.Function})
        function t=getSummary(f,~)

            import mlreportgen.report.*
            import mlreportgen.dom.*


            t=mlreportgen.report.BaseTable();
            t=copy(f.Summary);
            table=systemcomposer.rptgen.report.Function.createFunctionSummaryTable(f);
            if~isempty(table)
                t.Title="Functions Summary";
                t.Content=table;
            end
        end
    end

    methods
        function this=Function(varargin)
            if nargin==1
                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Summary=mlreportgen.report.BaseTable;
            this.Summary.TableStyleName="Functions Summary";
            this.TemplateName="Function";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.Function.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)
            path=systemcomposer.rptgen.report.Function.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.Function");
        end
    end
end