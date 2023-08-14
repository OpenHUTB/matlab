function filterRecordsWithHistogramData(this)




    this.DataIndicesWithoutHistogramData=false(height(this.TableData),1);
    for idx=1:size(this.TableData.HistogramVisualizationInfo,1)
        visualizationInfo=this.TableData.HistogramVisualizationInfo(idx);
        if isempty(visualizationInfo.HistogramData)
            this.DataIndicesWithoutHistogramData(idx)=true;
        end
    end
    this.TableData(this.DataIndicesWithoutHistogramData,:)=[];
    this.InScopeData(this.DataIndicesWithoutHistogramData,:)=[];
end