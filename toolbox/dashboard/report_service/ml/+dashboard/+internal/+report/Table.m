classdef Table<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)
            import mlreportgen.dom.*;
            section=mlreportgen.report.Section();
            fontSize=dashboard.internal.report.Styles.fontSize;
            metricResult=this.Report.getMetricResults(this.Widget.MetricIDs,scopeArtifact);


            par=Paragraph;
            par.Bold=1;
            par.FontSize=fontSize;
            par.Style=[par.Style,{KeepWithNext(true)}];
            par.append(Text(this.Widget.Title));
            section.add(par);

            header=this.Widget.Labels;

            if(isempty(metricResult)||isempty(metricResult.Value)||isempty(metricResult.Value.BinCounts))
                body={};
            else
                body=[this.Report.metricValue2String(metricResult.Value.BinEdges,"",this.Widget.MetricIDs{1});...
                this.Report.metricValue2String(metricResult.Value.BinCounts(1,:))]';
            end

            ft=dashboard.internal.report.createFormalTable(header,body);
            ft.Width="300px";



            if this.Report.Report.Debug
                p=Paragraph('widgetReporter=Table');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                section.append(p);
            end

            section.append(ft);
            parent.append(section);
        end
    end
end