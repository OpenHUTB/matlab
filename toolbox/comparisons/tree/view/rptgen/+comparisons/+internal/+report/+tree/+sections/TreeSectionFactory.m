classdef TreeSectionFactory<comparisons.internal.report.tree.sections.SectionsFactory





    methods

        function section=create(~,mcosView,sources,sectionRootEntry,rptConfig,tempDir)
            import comparisons.internal.report.tree.sections.TreeSection
            section=TreeSection(...
            mcosView,...
            sources,...
            sectionRootEntry,...
            rptConfig,...
            comparisons.internal.report.tree.sections.SectionConfig(),...
            tempDir,...
            rptConfig.ReportFormat.RPTGenSectionTemplate...
            );
        end

        function applies=appliesToDiff(~,~,~)
            applies=true;
        end

        function priority=getPriority(~)
            priority=0;
        end

    end

end

