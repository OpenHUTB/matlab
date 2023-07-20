classdef BoxedHistogram<dashboard.internal.report.WidgetReportBase
    methods
        function addToReport(this,parent,scopeArtifact)
            section=mlreportgen.report.Section();
            meta=this.Report.getMetricMetaInfo(this.Widget.MetricIDs);
            if strlength(this.Widget.Title)~=0
                section.Title=this.Widget.Title;
            end

            metricResult=this.Report.getMetricResults(this.Widget.MetricIDs,scopeArtifact);

            if~isempty(metricResult)&&~isempty(metricResult.Value)
                labels=this.generateBinLabels(metricResult.Value);
                bins=this.Report.metricValue2String(metricResult.Value.BinCounts(1,:));
            else
                labels=["0","1","2","3",">3"];
                bins=["-","-","-","-","-"];
            end

            header=[string(meta.ValueName.Fields{1}),labels];
            body=[string(meta.ValueName.Fields{2}),bins];
            ft=dashboard.internal.report.createFormalTable(header,body);
            ft.Width="650px";



            if this.Report.Report.Debug
                p=mlreportgen.dom.Paragraph('widgetReporter=BoxedHistogram');
                p.append(sprintf('widgetID=%s',this.Widget.getUUID()));
                section.append(p);
            end

            section.append(ft);
            parent.append(section);
        end

        function arr=generateBinLabels(~,value)
            assert(isfield(value,'BinEdges')&isfield(value,'BinCounts'));

            len=length(value.BinCounts);

            assert(len+1==length(value.BinEdges))

            arr=strings(1,len);

            for idx=1:len
                if(value.BinEdges(idx+1)==intmax('uint64'))
                    arr(idx)=strcat(">",string(value.BinEdges(idx)-1));
                elseif(value.BinEdges(idx+1)-value.BinEdges(idx)==1)
                    arr(idx)=value.BinEdges(idx);
                else
                    tmp=string([value.BinEdges(idx),value.BinEdges(idx+1)-1]);
                    arr(idx)=join(tmp,"-");
                end
            end
        end
    end
end