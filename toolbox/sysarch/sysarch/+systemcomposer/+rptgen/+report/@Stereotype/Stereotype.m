classdef Stereotype<slreportgen.report.Reporter

























































    properties

Source









Summary









Properties






        IncludeSummary{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true






        IncludeProperties{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true
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


























        function profileSummaryTable=createTableForSummary()

            import mlreportgen.dom.*
            [profileSummaryTable,rowForHeader]=systemcomposer.rptgen.report.Stereotype.createTableWithProperties();
            Icon=TableEntry(message('SystemArchitecture:ReportGenerator:Icon').getString);
            Stereotype=TableEntry(message('SystemArchitecture:ReportGenerator:Stereotype').getString);
            AppliesTo=TableEntry(message('SystemArchitecture:ReportGenerator:AppliesTo').getString);
            BaseStereotype=TableEntry(message('SystemArchitecture:ReportGenerator:BaseStereotype').getString);
            Description=TableEntry(message('SystemArchitecture:ReportGenerator:Description').getString);
            append(rowForHeader,Icon);
            append(rowForHeader,Stereotype);
            append(rowForHeader,AppliesTo);
            append(rowForHeader,BaseStereotype);
            append(rowForHeader,Description);

        end

        function propertiesTable=createTableForStereotypeProperties()

            import mlreportgen.dom.*
            [propertiesTable,rowForHeader]=systemcomposer.rptgen.report.Stereotype.createTableWithProperties();
            Property=TableEntry(message('SystemArchitecture:ReportGenerator:Property').getString);
            Type=TableEntry(message('SystemArchitecture:ReportGenerator:Type').getString);
            Unit=TableEntry(message('SystemArchitecture:ReportGenerator:Unit').getString);
            DefaultValue=TableEntry(message('SystemArchitecture:ReportGenerator:DefaultValue').getString);
            append(rowForHeader,Property);
            append(rowForHeader,Type);
            append(rowForHeader,Unit);
            append(rowForHeader,DefaultValue);

        end

        function summaryTable=createProfileSummaryTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            summaryTable=[];
            stereotype=this.Source;
            if~isempty(stereotype)
                summaryTable=systemcomposer.rptgen.report.Stereotype.createTableForSummary();
                len=length(stereotype);
                for i=1:len
                    row=TableRow();
                    if isempty(stereotype(i).Icon)
                        Icon=TableEntry();
                    else
                        Icon=TableEntry(stereotype(i).Icon);
                    end
                    append(row,Icon);
                    Stereotype=TableEntry(stereotype(i).Name);
                    append(row,Stereotype);
                    AppliesTo=TableEntry(stereotype(i).AppliesTo);
                    append(row,AppliesTo);
                    if isempty(stereotype(i).Parent)
                        BaseStereotype=TableEntry("-");
                    else
                        BaseStereotype=TableEntry(stereotype(i).Parent.Name);
                    end
                    append(row,BaseStereotype);
                    Description=TableEntry(stereotype(i).Description);
                    append(row,Description);
                    append(summaryTable,row);
                end
            end
        end

        function propertiesTable=createPropertiesTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            propertiesTable=[];
            properties=this.Source.Properties;
            if~isempty(properties)
                propertiesTable=systemcomposer.rptgen.report.Stereotype.createTableForStereotypeProperties();
                for prop=properties
                    row=TableRow();
                    Property=TableEntry(prop.Name);
                    append(row,Property);
                    Type=TableEntry(prop.Type);
                    append(row,Type);
                    Unit=TableEntry(prop.Unit);
                    append(row,Unit);
                    DefaultValue=TableEntry(prop.DefaultValue);
                    append(row,DefaultValue);
                    append(propertiesTable,row);
                end
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.Stereotype})
        function t=getSummary(f,~)

            import mlreportgen.report.*
            import mlreportgen.dom.*


            t=mlreportgen.report.BaseTable();
            if(f.IncludeSummary)
                t=copy(f.Summary);
                table=systemcomposer.rptgen.report.Stereotype.createProfileSummaryTable(f);
                if~isempty(table)
                    t.Title="Summary";
                    t.Content=table;
                end
                t.LinkTarget=systemcomposer.rptgen.utils.getObjectID(f.Source);
                appendTitle(t,LinkTarget(t.LinkTarget));


            end

        end

        function t=getProperties(f,~)

            import mlreportgen.report.*
            import mlreportgen.dom.*


            t=mlreportgen.report.BaseTable();
            if(f.IncludeProperties)
                t=copy(f.Properties);
                table=systemcomposer.rptgen.report.Stereotype.createPropertiesTable(f);
                if~isempty(table)
                    t.Title="Properties";
                    t.Content=table;
                end
            end
        end
    end

    methods
        function this=Stereotype(varargin)
            if nargin==1
                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Summary=mlreportgen.report.BaseTable;
            this.Summary.TableStyleName="Stereotypes Summary";
            this.Properties=mlreportgen.report.BaseTable;
            this.Properties.TableStyleName="Stereotypes Description";
            this.TemplateName="Stereotype";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.Stereotype.getClassFolder();
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
            path=systemcomposer.rptgen.report.Stereotype.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.Stereotype");
        end
    end
end