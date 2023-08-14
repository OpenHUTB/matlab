classdef ReportLayout<mlreportgen.report.Layout

















    methods
        function layout=ReportLayout(varargin)
            layout=layout@mlreportgen.report.Layout(varargin{:});
        end
    end

    methods(Access={?mlreportgen.report.ReportBase,...
        ?mlreporten.report.ReportLayout})
        function updateLayout(layout)
            rpt=layout.Owner;
            form=rpt.Document;
            if~isempty(form)&&~isempty(form.CurrentPageLayout)
                updatePageLayout(layout,form);
                fillHeadersFooters(layout,form,rpt);
            end
        end
    end


end

