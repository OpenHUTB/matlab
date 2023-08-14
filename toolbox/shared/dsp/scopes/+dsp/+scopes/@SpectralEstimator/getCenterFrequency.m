function cf=getCenterFrequency(obj)




    if strcmp(obj.FrequencySpan,'Full')
        cf=obj.SampleRate/4;
        if obj.TwoSidedSpectrum
            cf=0;
        end
    elseif strcmp(obj.FrequencySpan,'Span and center frequency')
        if~obj.TwoSidedSpectrum&&obj.CenterFrequency==0


            cf=obj.Span/2;
        else
            cf=obj.CenterFrequency;
        end
    else
        cf=(obj.StopFrequency+obj.StartFrequency)/2;
    end
end
