classdef StackedBar<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)
            import mlreportgen.dom.*;
            section=mlreportgen.report.Section();
            section.Title=this.Widget.Title;

            values=[];
            for metricID=this.Widget.MetricIDs
                metricResult=this.Report.getMetricResults(metricID,scopeArtifact);
                if isempty(metricResult)||isempty(metricResult.Value)
                    str=string(message("dashboard:report:NoDataAvailable").getString);
                    value=repmat(str,1,numel(this.Widget.ItemLabels));
                else
                    value=this.Report.metricValue2String(metricResult.Value,this.Widget.Unit,metricID{1});
                end
                values=[values;value];%#ok<AGROW> 
            end

            header=["",this.Widget.ItemLabels];
            body=[this.Widget.Labels;num2cell(values')]';
            ft=dashboard.internal.report.createFormalTable(header,body);
            ft.Width="550px";


            if this.Report.Report.Debug
                p=Paragraph('widgetReporter=StackedBar');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                section.append(p);
            end
            section.append(ft);

            parent.append(section);
        end
    end
end