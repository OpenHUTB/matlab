classdef Container<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)


            if this.Report.Report.Debug
                p=mlreportgen.dom.Paragraph('widgetReporter=Container');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                parent.append(p);
            end
            this.Report.generateAndAdd(parent,this.Widget.Widgets,scopeArtifact);
        end
    end
end