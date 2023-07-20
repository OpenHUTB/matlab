classdef VSpacer<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,~)
            if this.Report.Report.Debug
                p=mlreportgen.dom.Paragraph('widgetReporter=VSpacer');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                parent.append(p);
            end
        end
    end
end