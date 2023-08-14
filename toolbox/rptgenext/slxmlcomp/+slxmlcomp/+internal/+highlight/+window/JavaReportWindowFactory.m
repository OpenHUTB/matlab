classdef JavaReportWindowFactory<slxmlcomp.internal.highlight.ContentWindowFactory




    properties(Access=private)
JReportSupplier
    end

    methods(Access=public)
        function obj=JavaReportWindowFactory(reportSupplier)
            obj.JReportSupplier=reportSupplier;
        end

        function canHandle=canDisplay(~,contentId)
            import slxmlcomp.internal.highlight.ContentId
            canHandle=contentId==ContentId.Report;
        end

        function window=create(obj,~)
            window=slxmlcomp.internal.highlight.window.JavaReportWindow(...
            obj.JReportSupplier.get()...
            );
        end

    end

end
