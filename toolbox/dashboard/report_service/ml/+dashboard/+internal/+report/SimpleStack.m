classdef SimpleStack<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)
            import mlreportgen.dom.*;

            assert(isprop(this.Widget.Tooltip,'SimpleStackStack'));
            str=string(this.Widget.Tooltip.SimpleStackStack);
            assert(~this.hasHole(str,'Value'),'No Value hole in SimpleStackStack tooltip');
            fontSize=dashboard.internal.report.Styles.fontSize;
            section=mlreportgen.report.Section();
            metricResult=this.Report.getMetricResults(this.Widget.MetricIDs,scopeArtifact);


            assert(strcmp(this.Widget.DataFormat,this.Widget.DataFormatEnum.Fraction))

            total='-';
            count='-';
            missing='-';
            value='-';
            percentValue='-';
            if~isempty(metricResult)&&~isempty(metricResult.Value)
                total=this.Report.metricValue2String(metricResult.Value.Denominator);
                count=this.Report.metricValue2String(metricResult.Value.Numerator);
                missing=this.Report.metricValue2String(metricResult.Value.Denominator-metricResult.Value.Numerator);
                value=count+"/"+total;
                if metricResult.Value.Denominator~=0
                    percentValue=this.Report.metricValue2String(100*(double(metricResult.Value.Numerator)/double(metricResult.Value.Denominator)),'%');
                end
            end

            str=this.fillHoles(str,struct(...
            'Count',count,...
            'Total',total,...
            'Missing',missing,...
            'Value',value,...
            'PercentValue',percentValue...
            ));

            par=Paragraph(sprintf('%s\n',str));
            par.Style={...
            OuterMargin('0in','0in','0.1in','0in'),...
            FontSize(fontSize),...
            };



            if this.Report.Report.Debug
                p=Paragraph('widgetReporter=SimpleStack');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                section.append(p);
            end
            section.append(par);

            parent.append(section);
        end
    end
end