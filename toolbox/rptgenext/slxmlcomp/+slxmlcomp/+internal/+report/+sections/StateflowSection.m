classdef StateflowSection<mlreportgen.dom.LockedDocumentPart



    properties(Access=private)
        JDriverFacade;
        SectionRootDiff;
        ReportFormat;
        TempDir;
        ComparisonSources;
    end


    methods(Access=public)

        function obj=StateflowSection(jDriverFacade,sectionRootDiff,rptFormat,tempDir,comparisonSources)
            obj=obj@mlreportgen.dom.LockedDocumentPart(...
            rptFormat.RPTGenType,...
            getfield(rptFormat,'RPTGenSubsystemTemplate'),...
"Section"...
            );%#ok<GFLD>

            obj.JDriverFacade=jDriverFacade;
            obj.SectionRootDiff=sectionRootDiff;
            obj.ReportFormat=rptFormat;
            obj.TempDir=tempDir;
            obj.ComparisonSources=comparisonSources;
        end

        function fillSubsystemTitle(obj)
            import mlreportgen.dom.TableEntry;
            import mlreportgen.dom.TableRow;
            import mlreportgen.dom.Table;

            titlesTable=Table(1);
            titlesTable.Width='100%';
            titleRow=TableRow();
            titleRow.append(TableEntry(obj.getStateflowName()));
            titlesTable.append(titleRow);
            titlesTable.StyleName='SubsystemTitle';
            obj.append(titlesTable);
            obj.append('');
        end

        function fillSubsystemContents(obj)
            obj.fillContents(obj.SectionRootDiff)
        end

    end


    methods(Access=private)

        function name=getStateflowName(~)
            import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.StateflowNodeCustomization;
            name=char(StateflowNodeCustomization.NAME);
        end

        function fillContents(obj,rootDiff)
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.difference.TwoSourceDifferenceUtils;
            import com.mathworks.toolbox.rptgenslxmlcomp.report.ReportUtils;

            import slxmlcomp.internal.report.Difference;
            import slxmlcomp.internal.report.sections.ChartSection;
            import slxmlcomp.internal.report.sections.ChartSectionFactory;


            childCollection=obj.JDriverFacade.getResult().getDifferenceGraphModel().getChildren(rootDiff);
            if isempty(childCollection)
                return
            end
            children=childCollection.iterator();

            charts={};
            while children.hasNext()
                diff=children.next();


                if ChartSectionFactory.isChart(diff)
                    charts{end+1}=diff;%#ok<AGROW>
                else

                    if ReportUtils.isChanged(diff,obj.JDriverFacade.getResult())...
                        ||TwoSourceDifferenceUtils.isInserted(diff)

                        docPart=Difference(...
                        diff,...
                        obj.JDriverFacade,...
                        obj.ReportFormat...
                        );
                        if strcmp(docPart.Type,'PDF')
                            docPart.open(obj.ReportFormat.RPTGenTemplateKey);
                        else
                            docPart.TemplateName='';
                            docPart.open(obj.ReportFormat.RPTGenTemplateKey);
                        end
                        docPart.fill();
                        obj.append(docPart);
                    end
                    obj.fillContents(diff);
                end

            end

            for chartIndex=1:numel(charts)
                docPart=ChartSection(...
                obj.JDriverFacade,...
                charts{chartIndex},...
                obj.ReportFormat,...
                obj.TempDir,...
                obj.ComparisonSources...
                );
                if strcmp(docPart.Type,'PDF')
                    docPart.open(obj.ReportFormat.RPTGenTemplateKey);
                else
                    docPart.TemplateName='';
                    docPart.open(obj.ReportFormat.RPTGenTemplateKey);
                end
                docPart.fill();
                obj.append(docPart);
            end

        end

    end

end
