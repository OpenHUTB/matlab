classdef AllocationSet<slreportgen.report.Reporter























    properties

Source









Summary









Scenario






        IncludeSummary=true






        IncludeScenario=true
    end

    methods(Static,Access=private)
        function[table]=createTableWithProperties()
            import mlreportgen.dom.*;
            table=FormalTable();
            table.Style=[table.Style,{Border('single'),Width('100%'),RowSep('single'),ColSep('single'),FontFamily('Calibri')}];
            table.TableEntriesStyle={HAlign('center')};
        end

        function descriptionTable=createTableForDescription(this)
            import mlreportgen.dom.*
            [descriptionTable]=systemcomposer.rptgen.report.AllocationSet.createTableWithProperties();

            alloc=this.Source;

            row1=TableRow();
            r1e1=TableEntry(message('SystemArchitecture:ReportGenerator:Source').getString);
            r1e1.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
            append(row1,r1e1);
            r1e2=TableEntry();
            append(r1e2,alloc.SourceModel);
            append(row1,r1e2);

            row2=TableRow();
            r2e1=TableEntry(message('SystemArchitecture:ReportGenerator:Target').getString);
            r2e1.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
            append(row2,r2e1);
            r2e2=TableEntry();
            append(r2e2,alloc.TargetModel);
            append(row2,r2e2);

            row3=TableRow();
            r3e1=TableEntry(message('SystemArchitecture:ReportGenerator:Description').getString);
            r3e1.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
            append(row3,r3e1);
            r3e2=TableEntry();
            append(r3e2,alloc.Description);
            append(row3,r3e2);

            append(descriptionTable,row1);
            append(descriptionTable,row2);
            append(descriptionTable,row3);
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.AllocationSet})
        function t=getSummary(f,~)
            if(f.IncludeSummary)
                t=copy(f.Summary);
                table=systemcomposer.rptgen.report.AllocationSet.createTableForDescription(f);
                if~isempty(table)
                    t.Title="Description";
                    t.Content=table;
                end
            else
                t=mlreportgen.report.BaseTable();
            end
        end

        function arr=getScenario(f,~)
            import mlreportgen.dom.*

            if(f.IncludeScenario)
                arr=[];
                scenarios=f.Source.Scenarios;
                count=0;
                if~isempty(scenarios)
                    for scenario=scenarios
                        t=copy(f.Scenario);
                        [scenarioTable]=systemcomposer.rptgen.report.AllocationSet.createTableWithProperties();
                        row=TableRow();
                        SourceElement=TableEntry(message('SystemArchitecture:ReportGenerator:SourceElement').getString);
                        TargetElement=TableEntry(message('SystemArchitecture:ReportGenerator:TargetElement').getString);
                        sourceHeader=append(row,SourceElement);
                        targetHeader=append(row,TargetElement);
                        sourceHeader.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
                        targetHeader.Style={InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)};
                        append(scenarioTable,row);
                        for temp=scenario.allocations
                            row2=TableRow();
                            source=TableEntry();
                            linkID_Source=mlreportgen.utils.normalizeLinkID(temp.SourceElement);
                            append(source,InternalLink(linkID_Source,temp.SourceElement));
                            target=TableEntry();
                            linkID_Target=mlreportgen.utils.normalizeLinkID(temp.TargetElement);
                            append(target,InternalLink(linkID_Target,temp.TargetElement));
                            append(row2,source);
                            append(row2,target);
                            append(scenarioTable,row2);
                        end
                        grps(1)=TableColSpecGroup;
                        grps(1).Span=2;
                        specs(1)=TableColSpec;specs(1).Span=1;specs(1).Style={Width("50%")};
                        specs(2)=TableColSpec;specs(2).Span=1;specs(2).Style={Width("50%")};
                        grps(1).ColSpecs=specs;
                        scenarioTable.ColSpecGroups=grps;
                        count=count+1;
                        if~isempty(scenarioTable)
                            t.Title=scenario.Name;
                            t.Content=scenarioTable;
                        end
                        arr=[arr,t];
                    end
                end
            else
                arr=[];
            end
        end
    end

    methods
        function this=AllocationSet(varargin)
            if nargin==1
                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Summary=mlreportgen.report.BaseTable;
            this.Summary.TableStyleName="Description";
            this.Scenario=mlreportgen.report.BaseTable;
            this.Scenario.TableStyleName="Scenario";
            this.TemplateName="AllocationSet";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.AllocationSet.getClassFolder();
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
            path=systemcomposer.rptgen.report.AllocationSet.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.AllocationSet");
        end
    end
end