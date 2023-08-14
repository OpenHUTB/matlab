function span=getSpan(obj)




    if strcmp(obj.FrequencySpan,'Full')
        span=obj.SampleRate;
        if~obj.TwoSidedSpectrum
            span=span/2;
        end
    elseif strcmp(obj.FrequencySpan,'Span and center frequency')
        span=obj.Span;
    else
        span=obj.StopFrequency-obj.StartFrequency;
    end
end
