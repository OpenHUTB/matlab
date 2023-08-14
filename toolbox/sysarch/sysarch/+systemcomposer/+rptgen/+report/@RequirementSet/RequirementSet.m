classdef RequirementSet<slreportgen.report.Reporter

    properties
Source
Properties
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

        function viewPropertyTable=createTableForProperties()
            import mlreportgen.dom.*
            [viewPropertyTable,rowForHeader]=systemcomposer.rptgen.report.RequirementSet.createTableWithProperties();
            ID=TableEntry(message('SystemArchitecture:ReportGenerator:ID').getString);
            Summary=TableEntry(message('SystemArchitecture:ReportGenerator:Summary').getString);
            Links=TableEntry(message('SystemArchitecture:ReportGenerator:RelatedTo').getString);
            append(rowForHeader,ID);
            append(rowForHeader,Summary);
            append(rowForHeader,Links);
        end

        function viewPropertyTable=createAssignedPropertyTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            requirements=this.Source;
            if~isempty(requirements)
                viewPropertyTable=systemcomposer.rptgen.report.RequirementSet.createTableForProperties();
                for req=requirements
                    row=TableRow();
                    ID=TableEntry(string(req.ID));
                    append(row,ID);
                    Summary=TableEntry(string(req.Summary));
                    append(row,Summary);
                    Link=TableEntry();
                    if length(req.Link)>1
                        ol=mlreportgen.dom.UnorderedList;
                        for links=req.Link
                            append(ol,links);
                        end
                        append(Link,ol);
                    else
                        append(Link,string(req.Link));
                    end
                    append(row,Link);
                    append(viewPropertyTable,row);
                end
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.RequirementSet})
        function t=getProperties(f,~)
            import mlreportgen.utils.*
            import mlreportgen.dom.*
            t=copy(f.Properties);
            table=systemcomposer.rptgen.report.RequirementSet.createAssignedPropertyTable(f);
            if~isempty(table)
                t.Title="Properties";
                t.Content=table;











            end
        end
    end

    methods
        function this=RequirementSet(varargin)
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Properties=mlreportgen.report.BaseTable;
            this.Properties.TableStyleName="Properties Table";
            this.TemplateName="RequirementSet";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.RequirementSet.getClassFolder();
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
            path=systemcomposer.rptgen.report.RequirementSet.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.RequirementSet");
        end

    end
end