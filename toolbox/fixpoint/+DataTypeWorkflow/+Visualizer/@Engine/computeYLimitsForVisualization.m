function computeYLimitsForVisualization(this)






    if~isempty(this.GlobalYLimits)
        actualGlobalYLimits=this.GlobalYLimits;
        flippedBins=flipud((1:256)');
        maxBin=find(flippedBins==min(actualGlobalYLimits(1)));
        minBin=find(flippedBins==max(actualGlobalYLimits(2)));
        this.VisualYLimits=sort([maxBin,minBin]);
    end
end