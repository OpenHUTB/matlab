classdef SingleValue<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)
            import mlreportgen.dom.*;

            assert(isprop(this.Widget.Tooltip,'SingleValueValue'),'SingleValueValue Tooltip');
            str=string(this.Widget.Tooltip.SingleValueValue);
            section=mlreportgen.report.Section();
            fontSize=dashboard.internal.report.Styles.fontSize;
            metricResult=this.Report.getMetricResults(this.Widget.MetricIDs,scopeArtifact);
            if numel(metricResult)~=1
                for result=metricResult
                    if contains({result.Artifacts.UUID},result.ScopeUuid)
                        metricResult=result;
                        break;
                    end
                end
            end

            value='-';
            if~isempty(metricResult)&&~isempty(metricResult.Value)
                if isfield(metricResult.Value,'BinCounts')
                    value=this.Report.metricValue2String(metricResult.Value.BinCounts(this.Widget.DataIndex),this.Widget.Unit);
                elseif this.Widget.DataIndex>0
                    value=this.Report.metricValue2String(metricResult.Value(this.Widget.DataIndex),this.Widget.Unit,this.Widget.MetricIDs{1});
                else
                    value=this.Report.metricValue2String(metricResult.Value,this.Widget.Unit,this.Widget.MetricIDs{1});
                end
            end

            if~this.hasHole(str,'Value')
                assert(strlength(this.Widget.Title)~=0,'No Widget Title');
                str=sprintf('%s: %s',this.Widget.Title,value);
            else
                str=this.fillHoles(str,struct(...
                'Value',value...
                ));
            end

            par=Paragraph(sprintf('%s\n',str));
            par.Style={...
            OuterMargin("0pt","0pt","2pt","2pt"),...
            FontSize(fontSize)...
            };



            if this.Report.Report.Debug
                p=Paragraph('widgetReporter=SingleValue');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                section.append(p);
            end
            section.append(par);

            parent.append(section);
        end
    end
end