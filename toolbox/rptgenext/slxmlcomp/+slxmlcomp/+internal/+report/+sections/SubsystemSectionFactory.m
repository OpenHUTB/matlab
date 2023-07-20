


classdef SubsystemSectionFactory<slxmlcomp.internal.report.sections.SectionFactory

    methods(Access=public)


        function section=create(~,jDriverFacade,sectionRootDiff,rptFormat,tempDir,comparisonSources)
            import slxmlcomp.internal.report.sections.SubsystemSection
            section=SubsystemSection(jDriverFacade,sectionRootDiff,rptFormat,tempDir,comparisonSources);
        end



        function applies=appliesToDiff(~,diff)
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.blockdiagram.units.subsystem.SubSystemNodeCustomization;
            customization=SubSystemNodeCustomization();

            applies=false;
            snippets=diff.getSnippets().iterator();
            while(snippets.hasNext())
                snippet=snippets.next();
                if(customization.canHandle(snippet))
                    applies=true;
                    return
                end
            end
        end



        function priority=getPriority(~)
            priority=0;
        end

    end

end

