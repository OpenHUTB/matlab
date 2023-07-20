




classdef SubsystemSection<slxmlcomp.internal.report.sections.BaseSystemSection

    methods(Access=public)

        function obj=SubsystemSection(jDriverFacade,sectionRootDiff,rptFormat,tempDir,comparisonSources)
            obj=obj@slxmlcomp.internal.report.sections.BaseSystemSection(...
            jDriverFacade,sectionRootDiff,rptFormat,'RPTGenSubsystemTemplate',tempDir,comparisonSources...
            );
        end

    end

    methods(Access=protected)

        function image=createImage(obj,snippet,comparisonSource)
            import slxmlcomp.internal.report.sections.SystemImage;
            import slxmlcomp.internal.report.sections.Util;
            import slxmlcomp.internal.report.sections.ChartSectionFactory;
            if(ChartSectionFactory.isSnippetChart(snippet))
                image=[];
                return;
            end

            options=slxmlcomp.options;
            image=SystemImage(...
            Util.getMemorySimulinkPath(snippet,comparisonSource),...
            obj.TempDir,...
            options.ReportImageFormat...
            );
        end

    end

end

