classdef Connector<slreportgen.report.Reporter

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

        function connectorSummaryTable=createTableForSummary()

            import mlreportgen.dom.*
            [connectorSummaryTable,rowForHeader]=systemcomposer.rptgen.report.Connector.createTableWithProperties();
            Name=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
            SourcePort=TableEntry(message('SystemArchitecture:ReportGenerator:SourcePort').getString);
            DestinationPort=TableEntry(message('SystemArchitecture:ReportGenerator:DestinationPort').getString);
            Parent=TableEntry(message('SystemArchitecture:ReportGenerator:Parent').getString);
            append(rowForHeader,Name);
            append(rowForHeader,SourcePort);
            append(rowForHeader,DestinationPort);
            append(rowForHeader,Parent);
        end

        function summaryTable=createConnectorSummaryTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            summaryTable=[];
            connectors=this.Source;
            if~isempty(connectors)
                summaryTable=systemcomposer.rptgen.report.Connector.createTableForSummary();
                len=length(connectors);
                for i=1:len
                    row=TableRow();
                    Name=TableEntry(connectors(i).Name);
                    append(row,Name);
                    Parent=TableEntry(connectors(i).Parent);
                    append(row,Parent);
                    SourcePort=TableEntry(connectors(i).SourcePort);
                    append(row,SourcePort);
                    DestinationPort=TableEntry(connectors(i).DestinationPort);
                    append(row,DestinationPort);
                    append(summaryTable,row);
                end
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.Connector})
        function t=getSummary(f,~)

            import mlreportgen.report.*
            import mlreportgen.dom.*


            t=mlreportgen.report.BaseTable();
            table=systemcomposer.rptgen.report.Connector.createConnectorSummaryTable(f);
            if~isempty(table)
                t=copy(f.Summary);
                t.Title="Connectors Summary";
                t.Content=table;
            end
        end
    end

    methods
        function this=Connector(varargin)
            if nargin==1
                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Summary=mlreportgen.report.BaseTable;
            this.Summary.TableStyleName="Connectos Summary";
            this.TemplateName="Connector";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.Connector.getClassFolder();
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
            path=systemcomposer.rptgen.report.Connector.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.Connector");
        end

    end
end