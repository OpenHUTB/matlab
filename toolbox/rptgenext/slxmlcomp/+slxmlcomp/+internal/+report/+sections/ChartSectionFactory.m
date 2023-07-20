


classdef ChartSectionFactory<slxmlcomp.internal.report.sections.SectionFactory

    methods(Access=public)


        function section=create(~,jDriverFacade,sectionRootDiff,rptFormat,tempDir,comparisonSources)
            import slxmlcomp.internal.report.sections.ChartSection;
            section=ChartSection(jDriverFacade,sectionRootDiff,rptFormat,tempDir,comparisonSources);
        end



        function applies=appliesToDiff(~,diff)
            import slxmlcomp.internal.report.sections.ChartSectionFactory;
            applies=ChartSectionFactory.isChart(diff);
        end



        function priority=getPriority(~)
            priority=0;
        end
    end

    methods(Access=public,Static)
        function ischart=isChart(diff)
            import slxmlcomp.internal.report.sections.Util;
            ischart=Util.isDiffBySnippetTagName(diff,'chart');
        end



        function ischart=isSnippetChart(snippet)
            parent=snippet.getParent();
            if(isempty(parent))
                ischart=false;
                return;
            end
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
            ischart=strcmp(LightweightNodeUtils.getParameterValue(parent,'SFBlockType'),'Chart');
        end
    end

end