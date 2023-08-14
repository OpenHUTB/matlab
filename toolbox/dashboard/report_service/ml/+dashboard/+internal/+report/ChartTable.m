classdef ChartTable<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)
            part=parent;
            if strlength(this.Widget.Title)~=0
                part=mlreportgen.report.Section();
                part.Title=this.Widget.Title;
            end



            if this.Report.Report.Debug
                p=mlreportgen.dom.Paragraph('widgetReporter=ChartTable');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                part.append(p);
            end

            showHeader=strcmp(this.Widget.ShowTableHeader,'on');
            for row=1:numel(this.Widget.RowLabels)
                for col=1:numel(this.Widget.Labels)
                    childSection=mlreportgen.report.Section();
                    if showHeader&&strlength(this.Widget.Labels{col})~=0
                        childSection.Title=sprintf('%s - %s',this.Widget.RowLabels{row},this.Widget.Labels{col});
                    else
                        childSection.Title=this.Widget.RowLabels{row};
                    end
                    wr=this.Report.getWidgetReporter(this.Widget.Widgets((row-1)*numel(this.Widget.Labels)+col));
                    wr.addToReport(childSection,scopeArtifact);
                    part.append(childSection);
                end
            end

            if part~=parent
                parent.append(part);
            end
        end
    end
end