classdef Group<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)
            out=mlreportgen.report.Section;
            out.Title=this.Widget.Title;


            if this.Report.Report.Debug
                p=mlreportgen.dom.Paragraph('widgetReporter=Group');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                out.append(p);
            end
            this.Report.generateAndAdd(out,this.Widget.Widgets,scopeArtifact);
            parent.append(out);
        end
    end
end