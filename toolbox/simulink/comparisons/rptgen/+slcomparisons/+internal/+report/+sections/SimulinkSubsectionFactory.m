classdef SimulinkSubsectionFactory<comparisons.internal.report.tree.sections.SectionsFactory




    methods(Access=public)

        function section=create(~,mcosView,sources,sectionRootEntry,rptConfig,tempDir)
            sectionConfig=comparisons.internal.report.tree.sections.SectionConfig;
            sectionConfig.IsSubsection=true;
            sectionConfig.SubsectionFactories={slcomparisons.internal.report.sections.SimulinkSubsectionFactory};
            sectionConfig.CreateImage=@slcomparisons.internal.report.sections.createImage;

            import comparisons.internal.report.tree.sections.TreeSection
            section=TreeSection(...
            mcosView,...
            sources,...
            sectionRootEntry,...
            rptConfig,...
            sectionConfig,...
            tempDir,...
            rptConfig.ReportFormat.RPTGenSubsectionTemplate...
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

            [leftHandle,rightHandle]=sldiff.internal.app.getHandles(mcosView,rootEntry.match);
            [leftNodeType,rightNodeType]=sldiff.internal.app.getNodeTypes(mcosView,rootEntry.match);
            nodeApplicability=[isASubsystem(leftHandle,leftNodeType),isASubsystem(rightHandle,rightNodeType)];

            function out=isASubsystem(handle,nodeType)
                out=false;
                if handle~=-1&&...
                    strcmp(nodeType,'slBlock')&&...
                    ismember(get_param(handle,'LinkStatus'),["none","inactive"])

                    out=strcmp(get_param(handle,'BlockType'),'SubSystem');
                end
            end
        end

    end
end

