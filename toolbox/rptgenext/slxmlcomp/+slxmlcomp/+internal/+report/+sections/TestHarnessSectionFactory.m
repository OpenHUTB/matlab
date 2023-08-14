


classdef TestHarnessSectionFactory<slxmlcomp.internal.report.sections.SectionFactory

    methods

        function section=create(~,~,sectionRootDiff,rptFormat,~,~)
            import slxmlcomp.internal.report.sections.TestHarnessSection
            section=TestHarnessSection(sectionRootDiff,rptFormat);
        end

        function applies=appliesToDiff(~,rootDiff)
            import slxmlcomp.internal.report.sections.Util;
            applies=Util.isDiffBySnippetTagName(rootDiff,'harnessInfo');
        end

        function priority=getPriority(~)
            priority=2;
        end

    end

end

