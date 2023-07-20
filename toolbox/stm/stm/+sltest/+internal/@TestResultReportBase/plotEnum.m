function plotEnum(ts,pHandle)







    p=inputParser;
    addRequired(p,'ts',...
    @(x)validateattributes(x,{'timeseries'},{}));
    addRequired(p,'pHandle',...
    @(x)validateattributes(x,{'matlab.graphics.chart.primitive.Line'},{}));
    if~isempty(pHandle)
        stm.internal.util.plotEnum(ts,pHandle)
    end
end
