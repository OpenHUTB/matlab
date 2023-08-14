




classdef ChartSection<slxmlcomp.internal.report.sections.BaseSystemSection

    methods(Access=public)

        function obj=ChartSection(jDriverFacade,sectionRootDiff,rptFormat,tempDir,comparisonSources)
            obj=obj@slxmlcomp.internal.report.sections.BaseSystemSection(...
            jDriverFacade,sectionRootDiff,rptFormat,'RPTGenSubsystemTemplate',tempDir,comparisonSources...
            );
        end

    end

    methods(Access=protected)

        function image=createImage(obj,snippet,comparisonSource)
            import slxmlcomp.internal.report.sections.ChartImage;
            import slxmlcomp.internal.report.sections.Util;

            options=slxmlcomp.options;
            image=ChartImage(...
            Util.getMemorySimulinkPath(snippet,comparisonSource),...
            obj.TempDir,...
            options.ReportImageFormat...
            );
        end

    end

end

