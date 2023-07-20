classdef TestHarnessSection<mlreportgen.dom.LockedDocumentPart



    properties(Access=private)
        Title;
    end

    methods(Access=public)
        function obj=TestHarnessSection(sectionRootDiff,rptFormat)
            obj=obj@mlreportgen.dom.LockedDocumentPart(rptFormat.RPTGenType,rptFormat.RPTGenSectionTemplate,"Section");
            import slxmlcomp.internal.report.sections.Util;
            obj.Title=Util.getBasicDiffName(sectionRootDiff);
        end

        function fillSectionTitle(obj)
            obj.append(obj.Title);
        end

        function fillSectionContents(obj)
            import slxmlcomp.internal.report.getResourceString;
            obj.append(getResourceString('report.changedtestharnesses'));
        end

    end

end
