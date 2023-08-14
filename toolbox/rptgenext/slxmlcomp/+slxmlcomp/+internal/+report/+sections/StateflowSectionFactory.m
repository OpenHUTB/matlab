


classdef StateflowSectionFactory<slxmlcomp.internal.report.sections.SectionFactory

    methods

        function section=create(~,diffsGraphModel,sectionRootDiff,rptFormat,tempDir,comparisonSources)
            import slxmlcomp.internal.report.sections.StateflowSection
            section=StateflowSection(...
            diffsGraphModel,...
            sectionRootDiff,...
            rptFormat,...
            tempDir,...
comparisonSources...
            );
        end

        function applies=appliesToDiff(~,rootDiff)
            import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.StateflowNodeCustomization;
            import slxmlcomp.internal.report.sections.Util;
            applies=Util.isDiffBySnippetTagName(rootDiff,char(StateflowNodeCustomization.TAG_NAME));
        end

        function priority=getPriority(~)
            priority=0;
        end

    end

end

