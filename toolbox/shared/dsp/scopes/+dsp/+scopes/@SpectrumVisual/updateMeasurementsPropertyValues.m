function updateMeasurementsPropertyValues(this)




    peakFinderProps=getPropertyValue(this,'PeakFinderProperties');
    if~isempty(peakFinderProps)
        peakFinderProps.Enable=false;
        set(this.PeakFinderObject,peakFinderProps);
    end


    cursorProps=getPropertyValue(this,'CursorMeasurementsProperties');
    if~isempty(cursorProps)
        cursorProps.Enable=false;
        set(this.CursorMeasurementsObject,cursorProps);
    end


    channelProps=getPropertyValue(this,'ChannelMeasurementsProperties');
    if~isempty(channelProps)
        channelProps.Enable=false;
        set(this.ChannelMeasurementsObject,channelProps);
    end


    distortionProps=getPropertyValue(this,'DistortionMeasurementsProperties');
    if~isempty(distortionProps)
        distortionProps.Enable=false;
        set(this.DistortionMeasurementsObject,distortionProps);
    end


    ccdfProps=getPropertyValue(this,'CCDFMeasurementsProperties');
    if~isempty(ccdfProps)
        ccdfProps.Enable=false;
        set(this.CCDFMeasurementsObject,ccdfProps);
    end
end
