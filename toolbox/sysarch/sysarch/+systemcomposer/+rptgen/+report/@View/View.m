classdef View<slreportgen.report.Reporter
































































    properties

Source








Snapshot









Elements









Properties









SubGroups






        IncludeElements=true






        IncludeProperties=true






        IncludeSubGroups=true
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

        function viewPropertyTable=createTableForProperties()

            import mlreportgen.dom.*
            [viewPropertyTable,rowForHeader]=systemcomposer.rptgen.report.View.createTableWithProperties();
            Property=TableEntry(message('SystemArchitecture:ReportGenerator:Property').getString);
            Value=TableEntry(message('SystemArchitecture:ReportGenerator:Value').getString);
            append(rowForHeader,Property);
            append(rowForHeader,Value);

        end

        function elementsTable=createTableForElements()

            import mlreportgen.dom.*
            [elementsTable,rowForHeader]=systemcomposer.rptgen.report.View.createTableWithProperties();
            Elements=TableEntry(message('SystemArchitecture:ReportGenerator:Elements').getString);
            append(rowForHeader,Elements);
        end

        function subGroupsTable=createTableForSubGroups()

            import mlreportgen.dom.*
            [subGroupsTable,rowForHeader]=systemcomposer.rptgen.report.View.createTableWithProperties();
            Name=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
            Elements=TableEntry(message('SystemArchitecture:ReportGenerator:Elements').getString);
            SubGroups=TableEntry(message('SystemArchitecture:ReportGenerator:SubGroups').getString);
            append(rowForHeader,Name);
            append(rowForHeader,Elements);
            append(rowForHeader,SubGroups);
        end

        function subGroupsTable=createAssignedSubGroupTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            subGroupsTable=systemcomposer.rptgen.report.View.createTableForSubGroups();
            sg=this.Source.SubGroups;
            len=length(sg);
            for i=1:len
                row=TableRow();
                Name=TableEntry(string(sg(i).Name));
                append(row,Name);
                Elements=TableEntry();
                for j=1:length(sg(i).Elements)
                    append(Elements,string(sg(i).Elements(j).Name));
                end
                append(row,Elements);
                Subgroups=TableEntry();
                if~isempty(sg(i).SubGroups)
                    for k=1:length(sg(i).SubGroups)
                        append(SubGroups,sg(i).SubGroups(k).Name);
                    end
                else
                    append(Subgroups,"-");
                end
                append(row,Subgroups);
                append(subGroupsTable,row);

            end

        end


        function grps=changeColumnWidthForViewPropertyTable()

            import mlreportgen.dom.*
            grps(1)=TableColSpecGroup;
            grps(1).Span=2;
            specs(1)=TableColSpec;specs(1).Span=1;specs(1).Style={Width("30%")};
            specs(2)=TableColSpec;specs(2).Span=1;specs(2).Style={Width("70%")};
            grps(1).ColSpecs=specs;
        end

        function viewPropertyTable=createAssignedPropertyTable(this)

            import mlreportgen.dom.*
            import mlreportgen.utils.*
            viewPropertyTable=systemcomposer.rptgen.report.View.createTableForProperties();
            row1=TableRow();
            row2=TableRow();
            row3=TableRow();
            row4=TableRow();
            append(row1,TableEntry("Color"));
            append(row1,TableEntry(this.Source.Color));
            append(row3,TableEntry("Select"));
            append(row3,TableEntry(this.Source.Select));
            append(row2,TableEntry("GroupBy"));
            append(row2,TableEntry(string(this.Source.GroupBy)));
            append(row4,TableEntry("Description"));
            append(row4,TableEntry(this.Source.Description));
            append(viewPropertyTable,row1);
            append(viewPropertyTable,row2);
            append(viewPropertyTable,row3);
            append(viewPropertyTable,row4);
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.View})
        function t=getElements(f,~)

            import mlreportgen.report.*
            import mlreportgen.dom.*


            t=mlreportgen.report.BaseTable();
            if(f.IncludeElements)
                t=copy(f.Elements);
                elements=f.Source.Elements;
                x=TableEntry();
                if~isempty(elements)
                    for i=1:length(elements)
                        append(x,string(elements(i).Name));
                    end
                    table=systemcomposer.rptgen.report.View.createTableForElements();
                    row=TableRow();
                    append(row,x);
                    append(table,row);
                    t.Content=table;
                    t.Title="Elements";
                end
            end
        end

        function t=getProperties(f,~)



            t=mlreportgen.report.BaseTable();
            if(f.IncludeProperties)
                t=copy(f.Properties);
                table=systemcomposer.rptgen.report.View.createAssignedPropertyTable(f);
                if~isempty(table)
                    t.Title="Property";
                    t.Content=table;
                end
            end
        end

        function t=getSubGroups(f,~)



            t=mlreportgen.report.BaseTable();
            if(f.IncludeSubGroups)
                t=copy(f.SubGroups);
                table=systemcomposer.rptgen.report.View.createAssignedSubGroupTable(f);
                if~isempty(f.Source.SubGroups)
                    t.Title="SubGroups";
                    t.Content=table;
                end
            end
        end

        function diagram=getSnapshot(f,~)

            diagram=copy(f.Snapshot);%#ok<*NASGU>
            diagram=f.Source.Snapshot;
        end
    end

    methods
        function this=View(varargin)
            if nargin==1
                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Snapshot=slreportgen.report.Diagram();
            this.Elements=mlreportgen.report.BaseTable;
            this.Elements.TableStyleName="Elements List";
            this.Properties=mlreportgen.report.BaseTable;
            this.Properties.TableStyleName="Property Table";
            this.SubGroups=mlreportgen.report.BaseTable;
            this.SubGroups.TableStyleName="SubGroups Table";
            this.TemplateName="View";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.View.getClassFolder();
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

        function createTemplate(templatePath,type)
            path=systemcomposer.rptgen.report.View.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReporter(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.View");
        end
    end
end