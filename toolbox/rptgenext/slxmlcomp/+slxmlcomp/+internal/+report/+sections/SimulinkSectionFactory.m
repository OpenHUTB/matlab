


classdef SimulinkSectionFactory<slxmlcomp.internal.report.sections.SectionFactory

    methods

        function section=create(~,diffsGraphModel,sectionRootDiff,rptFormat,tempDir,comparisonSources)
            import slxmlcomp.internal.report.sections.SimulinkSection
            section=SimulinkSection(...
            diffsGraphModel,...
            sectionRootDiff,...
            rptFormat,...
            tempDir,...
comparisonSources...
            );
        end

        function applies=appliesToDiff(~,rootDiff)
            import slxmlcomp.internal.report.sections.Util;
            applies=Util.isBlockDiagramRootDiff(rootDiff);
        end

        function priority=getPriority(~)
            priority=0;
        end

    end

end

