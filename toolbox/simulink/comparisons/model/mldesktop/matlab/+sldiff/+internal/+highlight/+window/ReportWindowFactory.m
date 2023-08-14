classdef ReportWindowFactory<comparisons.internal.highlight.ContentWindowFactory




    properties(Access=private)
ReportWindow
    end

    methods(Access=public)
        function obj=ReportWindowFactory(reportWindow)
            obj.ReportWindow=reportWindow;
        end

        function canHandle=canDisplay(~,contentId)
            import comparisons.internal.highlight.ContentId
            canHandle=contentId==ContentId.Report;
        end

        function window=create(obj,~)
            window=sldiff.internal.highlight.window.ReportWindow(obj.ReportWindow);
        end

    end

end
