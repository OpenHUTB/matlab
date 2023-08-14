classdef ReporterLayout<mlreportgen.report.Layout
















    methods
        function layout=ReporterLayout(varargin)
            layout=layout@mlreportgen.report.Layout(varargin{:});
        end
    end

    methods(Access={?mlreportgen.report.Reporter,?mlreporten.report.ReporterLayout})
        function updateLayout(layout,rpt)
            form=layout.Owner.Impl;
            if~isempty(form)&&~isempty(form.CurrentPageLayout)
                updatePageLayout(layout,form,rpt.Layout);
                fillHeadersFooters(layout,form,rpt);
            end
        end
    end


end

