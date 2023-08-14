classdef SimulinkSectionFactory<comparisons.internal.report.tree.sections.SectionsFactory




    methods(Access=public)

        function section=create(~,mcosView,sources,sectionRootEntry,rptConfig,tempDir)
            sectionConfig=comparisons.internal.report.tree.sections.SectionConfig;
            sectionConfig.SectionTitle='Simulink';
            sectionConfig.SubsectionFactories={slcomparisons.internal.report.sections.SimulinkSubsectionFactory};
            sectionConfig.IncludeSubsectionTitleInSection=true;
            sectionConfig.CreateImage=@slcomparisons.internal.report.sections.createImage;

            import comparisons.internal.report.tree.sections.TreeSection
            section=TreeSection(...
            mcosView,...
            sources,...
            sectionRootEntry,...
            rptConfig,...
            sectionConfig,...
            tempDir,...
            rptConfig.ReportFormat.RPTGenSectionTemplate...
            );
        end

        function applies=appliesToDiff(sectionFactory,mcosView,rootEntry)
            nodeApplicability=sectionFactory.getNodeApplicability(mcosView,rootEntry);
            applies=any(nodeApplicability);
        end

        function priority=getPriority(~)
            priority=0;
        end

    end

    methods(Static)

        function nodeApplicability=getNodeApplicability(mcosView,rootEntry)

            [leftType,rightType]=sldiff.internal.app.getNodeTypes(mcosView,rootEntry.match);
            nodeApplicability=[strcmp(leftType,'bd_root'),strcmp(rightType,'bd_root')];
        end

    end

end

