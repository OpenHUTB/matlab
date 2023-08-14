classdef Profile<slreportgen.report.Reporter
























































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

        function profileSummaryTable=createProfileSummaryTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            profileSummaryTable=[];
            profiles=this.Source;
            if~isempty(profiles)
                profileSummaryTable=systemcomposer.rptgen.report.Profile.createTableWithProperties();
                len=length(profiles);
                for i=1:len
                    row1=TableRow();
                    r1e1=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
                    r1e1.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
                    append(row1,r1e1);
                    r1e2=TableEntry();
                    append(r1e2,profiles(i).Name);
                    append(row1,r1e2);

                    row2=TableRow();
                    r2e1=TableEntry(message('SystemArchitecture:ReportGenerator:Description').getString);
                    r2e1.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
                    append(row2,r2e1);
                    r2e2=TableEntry();
                    append(r2e2,profiles(i).Description);
                    append(row2,r2e2);

                    row3=TableRow();
                    r3e1=TableEntry(message('SystemArchitecture:ReportGenerator:Stereotypes').getString);
                    r3e1.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
                    append(row3,r3e1);
                    r3e2=TableEntry();
                    for j=1:length(profiles(i).Stereotypes)
                        append(r3e2,profiles(i).Stereotypes(j));
                    end
                    append(row3,r3e2);

                    append(profileSummaryTable,row1);
                    append(profileSummaryTable,row2);
                    append(profileSummaryTable,row3);
                end

            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.Profile})
        function t=getSummary(f,~)

            import mlreportgen.report.*
            import mlreportgen.dom.*


            t=copy(f.Summary);
            table=systemcomposer.rptgen.report.Profile.createProfileSummaryTable(f);
            if~isempty(table)
                t.Title="Profile Summary";
                t.Content=table;
            end
            t.LinkTarget=systemcomposer.rptgen.utils.getObjectID(f.Source);
            appendTitle(t,LinkTarget(t.LinkTarget));
        end
    end

    methods
        function this=Profile(varargin)
            if nargin==1
                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Summary=mlreportgen.report.BaseTable;
            this.Summary.TableStyleName="Stereotypes Summary";
            this.TemplateName="Profile";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.Profile.getClassFolder();
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
            path=systemcomposer.rptgen.report.Profile.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.Profile");
        end
    end
end