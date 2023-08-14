function spec=getMeasurementSpecification(this,varargin)




    measurementName=varargin{1};
    switch(measurementName)

    case 'peaks'
        if isvalid(this.PeakFinderObject)
            spec=this.PeakFinderObject;
        else
            this.PeakFinderObject=dsp.scopes.PeakFinderSpecification(this.Application);

            peakFinderProps=getPropertyValue(this,'PeakFinderProperties');
            peakFinderProps.Enable=false;
            if~isempty(peakFinderProps)
                set(this.PeakFinderObject,peakFinderProps);
            end
            spec=this.PeakFinderObject;
        end

    case 'fcursors'
        if isvalid(this.CursorMeasurementsObject)
            spec=this.CursorMeasurementsObject;
        else
            this.CursorMeasurementsObject=dsp.scopes.CursorMeasurementsSpecification(this.Application);

            cursorMeasurementProps=getPropertyValue(this,'CursorMeasurementsProperties');
            cursorMeasurementProps.Enable=false;
            if~isempty(cursorMeasurementProps)
                set(this.CursorMeasurementsObject,cursorMeasurementProps);
            end
            spec=this.CursorMeasurementsObject;
        end

    case 'channel'
        if isvalid(this.ChannelMeasurementsObject)
            spec=this.ChannelMeasurementsObject;
        else
            this.ChannelMeasurementsObject=dsp.scopes.ChannelMeasurementsSpecification(this.Application);

            channelMeasurementProps=getPropertyValue(this,'ChannelMeasurementsProperties');
            channelMeasurementProps.Enable=false;
            if~isempty(channelMeasurementProps)
                set(this.ChannelMeasurementsObject,channelMeasurementProps);
            end
            spec=this.ChannelMeasurementsObject;
        end

    case 'distortion'
        if isvalid(this.DistortionMeasurementsObject)
            spec=this.DistortionMeasurementsObject;
        else
            this.DistortionMeasurementsObject=dsp.scopes.DistortionMeasurementsSpecification(this.Application);

            distortionMeasurementProps=getPropertyValue(this,'DistortionMeasurementsProperties');
            distortionMeasurementProps.Enable=false;
            if~isempty(distortionMeasurementProps)
                set(this.DistortionMeasurementsObject,distortionMeasurementProps);
            end
            spec=this.DistortionMeasurementsObject;
        end

    case 'ccdf'
        if isvalid(this.CCDFMeasurementsObject)
            spec=this.CCDFMeasurementsObject;
        else
            this.CCDFMeasurementsObject=dsp.scopes.CCDFMeasurementsSpecification(this.Application);

            ccdfMeasurementProps=getPropertyValue(this,'CCDFMeasurementsProperties');
            ccdfMeasurementProps.Enable=false;
            if~isempty(ccdfMeasurementProps)
                set(this.CCDFMeasurementsObject,ccdfMeasurementProps);
            end
            spec=this.CCDFMeasurementsObject;
        end
    end
end
