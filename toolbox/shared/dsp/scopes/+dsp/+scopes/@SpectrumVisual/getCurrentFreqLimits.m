function[Fstart,Fstop]=getCurrentFreqLimits(this,traceIndex)





    Fstart=NaN;
    Fstop=NaN;
    if isSourceRunning(this)||isempty(this.NoDataAvailableTxt)
        hPlotter=this.Plotter;
        Fstart=hPlotter.FrequencyLimits(1);
        Fstop=hPlotter.FrequencyLimits(2);
        if nargin==2
            Fs=this.SpectrumObject.SampleRate;
            FO=hPlotter.FrequencyOffset;
            if traceIndex<=numel(FO)
                traceFO=FO(traceIndex);
            else
                traceFO=FO(end);
            end
            traceFstart=-Fs/2*this.pTwoSidedSpectrum+traceFO;
            traceFstop=Fs/2+traceFO;
            if traceFstart<Fstop&&traceFstop>Fstart

                Fstart=max(Fstart,traceFstart);
                Fstop=min(Fstop,traceFstop);
            end
        end
    end
end
