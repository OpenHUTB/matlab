classdef ModelWorkspaceSection<mlreportgen.dom.LockedDocumentPart



    properties(Access=private)
        Title;
    end

    methods(Access=public)
        function obj=ModelWorkspaceSection(sectionRootDiff,rptFormat)
            obj=obj@mlreportgen.dom.LockedDocumentPart(rptFormat.RPTGenType,rptFormat.RPTGenSectionTemplate,"Section");
            import slxmlcomp.internal.report.sections.Util;
            obj.Title=Util.getBasicDiffName(sectionRootDiff);
        end

        function fillSectionTitle(obj)
            obj.append(obj.Title);
        end

        function fillSectionContents(obj)
            import slxmlcomp.internal.report.getResourceString;
            obj.append(getResourceString('report.changedmodelworkspace'));
        end

    end

end
