function generateRGBUsingDB(this)




    if~isempty(this.TableData)

        this.computeDataIndexRange();


        tableData=this.TableData(this.StartIndex:this.EndIndex,'HistogramVisualizationInfo');

        histogramVisualizationInfo=tableData.HistogramVisualizationInfo;
        histogramVisualizationInfo=num2cell(histogramVisualizationInfo);



        this.RGBGenerator.setHistogramVisualizationInfo(histogramVisualizationInfo);
        this.RGBGenerator.constructVisualizationData();


        this.RGBData(this.StartIndex:this.EndIndex)=this.RGBGenerator.RGB;
        this.YLimits(this.StartIndex:this.EndIndex)=this.RGBGenerator.YLimits;
    end
end
