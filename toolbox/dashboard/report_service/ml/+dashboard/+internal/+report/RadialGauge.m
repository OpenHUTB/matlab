classdef RadialGauge<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)
            import mlreportgen.dom.*;

            assert(isprop(this.Widget.Tooltip,'RadialGaugeValue'));
            str=string(this.Widget.Tooltip.RadialGaugeValue);
            section=mlreportgen.report.Section();
            fontSize=dashboard.internal.report.Styles.fontSize;
            metricResult=this.Report.getMetricResults(this.Widget.MetricIDs,scopeArtifact);

            total='-';
            count='-';
            missing='-';
            value='-';
            if~isempty(metricResult)&&~isempty(metricResult.Value)
                total=this.Report.metricValue2String(metricResult.Value.Denominator);
                count=this.Report.metricValue2String(metricResult.Value.Numerator);
                missing=this.Report.metricValue2String(metricResult.Value.Denominator-metricResult.Value.Numerator);
                if metricResult.Value.Denominator~=0
                    value=this.Report.metricValue2String(100*(double(metricResult.Value.Numerator)/double(metricResult.Value.Denominator)),this.Widget.Unit);
                end
            end

            str=this.fillHoles(str,struct(...
            'Count',count,...
            'Total',total,...
            'Missing',missing,...
            'Value',value...
            ));

            par=Paragraph(sprintf('%s\n',str));
            par.Style={...
            OuterMargin('0in','0in','0.1in','0in'),...
            FontSize(fontSize),...
            Bold(1),...
            };



            if this.Report.Report.Debug
                p=Paragraph('widgetReporter=RadialGauge');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                section.append(p);
            end
            section.append(par);

            parent.append(section);
        end
    end
end