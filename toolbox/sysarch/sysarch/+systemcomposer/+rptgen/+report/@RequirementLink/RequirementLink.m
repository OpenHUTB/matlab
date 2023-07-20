classdef RequirementLink<slreportgen.report.Reporter

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
            tableHeader.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
        end

        function summaryTable=createTableForSummary()
            import mlreportgen.dom.*
            [summaryTable,rowForHeader]=systemcomposer.rptgen.report.RequirementLink.createTableWithProperties();
            Source=TableEntry("Source");
            Type=TableEntry("Type");
            Destination=TableEntry("Destination");
            append(rowForHeader,Source);
            append(rowForHeader,Type);
            append(rowForHeader,Destination);
        end


        function summaryTable=createAssignedSummaryTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            links=this.Source;
            if~isempty(links)
                summaryTable=systemcomposer.rptgen.report.RequirementLink.createTableForSummary();
                for link=links










                    row=TableRow();
                    Source=TableEntry(string(link.Source));
                    append(row,Source);
                    Type=TableEntry(string(link.Type));
                    append(row,Type);
                    Destination=TableEntry(string(link.Destination));
                    append(row,Destination);
                    append(summaryTable,row);
                end
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.RequirementLink})
        function t=getSummary(f,~)
            t=copy(f.Summary);
            table=systemcomposer.rptgen.report.RequirementLink.createAssignedSummaryTable(f);
            if~isempty(table)
                t.Title="Requirement Links Summary";
                t.Content=table;
            end
        end
    end

    methods
        function this=RequirementLink(varargin)
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Summary=mlreportgen.report.BaseTable;
            this.Summary.TableStyleName="Requirement Links Summary";
            this.TemplateName="RequirementLink";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.RequirementLink.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end
    end

    methods(Access=protected,Hidden)
        result=openImpl(rpt,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)
            path=systemcomposer.rptgen.report.RequirementLink.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.RequirementLink");
        end

    end
end