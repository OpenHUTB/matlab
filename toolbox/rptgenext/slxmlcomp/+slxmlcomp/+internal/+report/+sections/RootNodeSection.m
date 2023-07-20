classdef RootNodeSection<mlreportgen.dom.LockedDocumentPart



    properties(Access=private)
        JDriverFacade;
        SectionRootDiff;
        Title;
        ReportFormat;
    end

    methods(Access=public)
        function obj=RootNodeSection(jDriverFacade,sectionRootDiff,rptFormat)
            obj=obj@mlreportgen.dom.LockedDocumentPart(rptFormat.RPTGenType,rptFormat.RPTGenSectionTemplate,"Section");
            obj.JDriverFacade=jDriverFacade;
            obj.SectionRootDiff=sectionRootDiff;
            obj.ReportFormat=rptFormat;
            import slxmlcomp.internal.report.sections.Util;
            obj.Title=Util.getBasicDiffName(sectionRootDiff);

        end

        function fillSectionTitle(obj)
            obj.append(obj.Title);
        end

        function fillSectionContents(obj)
            import com.mathworks.toolbox.rptgenslxmlcomp.report.BasicDifferenceModelTraversal;
            import slxmlcomp.internal.report.Difference;

            basicDiffTraversal=BasicDifferenceModelTraversal(obj.SectionRootDiff,obj.getDiffGraph()).iterator();
            while(basicDiffTraversal.hasNext())
                diff=basicDiffTraversal.next();

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
        end
    end

    methods(Access=private)
        function graph=getDiffGraph(obj)
            graph=obj.JDriverFacade.getResult().getDifferenceGraphModel();
        end
    end

end
