classdef SpectrumAnalyzerValidator<matlabshared.scopes.Validator




    properties(Constant)

        ChannelNames=@(val)(iscell(val)&&(isempty(val)||(isvector(val)&&iscellstr(cellstr(val)))));
        CustomWindow=@(val)(ischar(val)&&~isempty(val));


        FFTLength=@(val)~(~isscalar(val)||isnan(val)||isinf(val)||~isreal(val)||(val<=0)||val~=double(int64(val)));
        AxesScalingNumUpdates=@(val)~(~isscalar(val)||isnan(val)||isinf(val)||~isreal(val)||(val<=0)||val~=double(int64(val)));
        SpectralAverages=@(val)~(~isscalar(val)||isnan(val)||isinf(val)||~isreal(val)||(val<=0)||val~=double(int64(val)));


        WindowLength=@(val)~(~isscalar(val)||isnan(val)||isinf(val)||~isreal(val)||(val<=2)||val~=double(int64(val)));
        NumTapsPerBand=@(val)~(~isscalar(val)||isnan(val)||isinf(val)||~isreal(val)||(val<=0)||val~=double(int64(val)));


        RBW=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||isnan(val)||isinf(val));
        SampleRate=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||isnan(val)||isinf(val));
        TimeResolution=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||isnan(val)||isinf(val));
        TimeSpan=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||isnan(val)||isinf(val));
        ReferenceLoad=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||isnan(val)||isinf(val));
        FullScale=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||isnan(val)||isinf(val));
        Span=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||isnan(val)||isinf(val));


        FrequencyOffset=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||isnan(val)||isinf(val));
        StartFrequency=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||isnan(val)||isinf(val));
        StopFrequency=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||isnan(val)||isinf(val));
        CenterFrequency=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||isnan(val)||isinf(val));


        OverlapPercent=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<0)||(val>=100)||isnan(val)||isinf(val));
        SidelobeAttenuation=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<45)||isnan(val)||isinf(val));
        SpectrogramChannel=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||(val>100)||isnan(val)||isinf(val));
        MeasurementChannel=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||(val>100)||isnan(val)||isinf(val));
        ForgettingFactor=@(val)~(~isscalar(val)||val~=double(val)||~isreal(val)||(val<=0)||(val>1)||isnan(val)||isinf(val));
    end
end