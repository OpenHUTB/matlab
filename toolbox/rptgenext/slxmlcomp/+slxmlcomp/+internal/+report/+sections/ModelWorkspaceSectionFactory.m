


classdef ModelWorkspaceSectionFactory<slxmlcomp.internal.report.sections.SectionFactory

    methods

        function section=create(~,~,sectionRootDiff,rptFormat,~,~)
            import slxmlcomp.internal.report.sections.ModelWorkspaceSection
            section=ModelWorkspaceSection(sectionRootDiff,rptFormat);
        end

        function applies=appliesToDiff(~,rootDiff)
            import slxmlcomp.internal.report.sections.Util;
            applies=Util.isDiffBySnippetTagName(rootDiff,'modelWorkspace');
        end

        function priority=getPriority(~)
            priority=1;
        end

    end

end

