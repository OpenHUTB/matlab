function generateCanvasData(this)





    this.CanvasData=[];
    for idx=1:size(this.TableData.HistogramVisualizationInfo,1)
        visualizationInfo=this.TableData.HistogramVisualizationInfo(idx);
        if visualizationInfo.HasOverflows||visualizationInfo.HasUnderflows
            this.CanvasData=[this.CanvasData;idx,visualizationInfo.HasOverflows,visualizationInfo.HasUnderflows];
        end
    end
end