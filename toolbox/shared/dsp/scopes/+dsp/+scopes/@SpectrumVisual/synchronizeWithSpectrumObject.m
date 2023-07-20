function synchronizeWithSpectrumObject(this,syncFrequencyAndTimePropsOnly)




    if nargin==1
        syncFrequencyAndTimePropsOnly=false;
    end
    hSpectrum=this.SpectrumObject;

    hSpectrum.Method=this.pMethod;
    if strcmp(hSpectrum.Method,'Filter bank')
        hSpectrum.NumTapsPerBand=this.pNumTapsPerBand;
    end

    Fs=hSpectrum.SampleRate;
    twoSidedFlag=this.pTwoSidedSpectrum;
    hSpectrum.FrequencySpan=getPropertyValue(this,'FrequencySpan');
    FO=evalPropertyValue(this,'FrequencyOffset');
    if numel(FO)>this.DataBuffer.NumChannels


        FO=FO(1:this.DataBuffer.NumChannels);
    end
    if strcmp(hSpectrum.FrequencySpan,'Span and center frequency')
        Fspan=evalPropertyValue(this,'Span');
        CF=evalPropertyValue(this,'CenterFrequency');
        if all(FO==FO(1))

            hSpectrum.Span=Fspan;
            hSpectrum.CenterFrequency=CF-FO(1);
        else




            hSpectrum.Span=(Fs/2)+(Fs/2)*twoSidedFlag;
            hSpectrum.CenterFrequency=(Fs/4)*~twoSidedFlag;
        end
    elseif strcmp(hSpectrum.FrequencySpan,'Start and stop frequencies')
        Fstart=evalPropertyValue(this,'StartFrequency');
        Fstop=evalPropertyValue(this,'StopFrequency');
        if all(FO==FO(1))

            hSpectrum.StartFrequency=Fstart-FO(1);
            hSpectrum.StopFrequency=Fstop-FO(1);
        else




            hSpectrum.StartFrequency=-Fs/2*twoSidedFlag;
            hSpectrum.StopFrequency=Fs/2;
        end
    end


    winName=getPropertyValue(this,'Window');
    if any(strcmp(winName,{'Rectangular',...
        'Blackman-Harris',...
        'Chebyshev',...
        'Flat Top',...
        'Hamming',...
        'Hann',...
        'Kaiser'}))
        hSpectrum.Window=winName;
    else
        hSpectrum.Window='Custom';
        hSpectrum.CustomWindow=getPropertyValue(this,'CustomWindow');
    end

    if any(strcmp({'Chebyshev','Kaiser'},hSpectrum.Window))
        hSpectrum.SidelobeAttenuation=evalPropertyValue(this,'SidelobeAttenuation');
    end

    if strcmp(this.pFrequencyResolutionMethod,'RBW')

        hSpectrum.FrequencyResolutionMethod=this.pFrequencyResolutionMethod;
        hSpectrum.RBWSource=getPropertyValue(this,'RBWSource');
        if strcmp(hSpectrum.RBWSource,'Property')

            hSpectrum.RBW=evalPropertyValue(this,'RBW');
        elseif any(strcmp(getPropertyValue(this,'ViewType'),{'Spectrogram','Spectrum and spectrogram'}))...
            &&strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property')



            timeRes=evalPropertyValue(this,'TimeResolution');
            hSpectrum.RBWSource='Property';
            hSpectrum.RBW=1/timeRes;
        end
    elseif strcmp(this.pFrequencyResolutionMethod,'WindowLength')

        hSpectrum.FrequencyResolutionMethod=this.pFrequencyResolutionMethod;
        hSpectrum.WindowLength=evalPropertyValue(this,'WindowLength');

        hSpectrum.FFTLengthSource=getPropertyValue(this,'FFTLengthSource');
        if strcmp(hSpectrum.FFTLengthSource,'Property')
            hSpectrum.FFTLength=evalPropertyValue(this,'FFTLength');
        end
    else

        hSpectrum.FrequencyResolutionMethod=this.pFrequencyResolutionMethod;

        hSpectrum.FFTLengthSource=getPropertyValue(this,'FFTLengthSource');
        if strcmp(hSpectrum.FFTLengthSource,'Property')
            hSpectrum.FFTLength=evalPropertyValue(this,'FFTLength');
        end
    end
    hSpectrum.OverlapPercent=evalPropertyValue(this,'OverlapPercent');

    if syncFrequencyAndTimePropsOnly
        return
    end
    hSpectrum.AveragingMethod=getPropertyValue(this,'AveragingMethod');
    if strcmpi(hSpectrum.AveragingMethod,'Running')
        hSpectrum.SpectralAverages=evalPropertyValue(this,'SpectralAverages');
    else
        hSpectrum.ForgettingFactor=evalPropertyValue(this,'ForgettingFactor');
    end
    hSpectrum.MaxHoldTrace=getPropertyValue(this,'MaxHoldTrace');
    hSpectrum.MinHoldTrace=getPropertyValue(this,'MinHoldTrace');
    hSpectrum.TwoSidedSpectrum=getPropertyValue(this,'TwoSidedSpectrum');
    hSpectrum.ReduceUpdates=getPropertyValue(this,'ReduceUpdates');
    this.DataBuffer.setReduceUpdates(getPropertyValue(this,'ReduceUpdates'));


    if~isInputFrameBased(this)
        this.DataBuffer.TreatMby1SignalsAsOneChannel=getPropertyValue(this,'TreatMby1SignalsAsOneChannel');
        this.Plotter.FrameProcessing=getPropertyValue(this,'TreatMby1SignalsAsOneChannel');
    else
        this.DataBuffer.TreatMby1SignalsAsOneChannel=true;
        this.Plotter.FrameProcessing=true;
    end

    this.DataBuffer.setReduceUpdatesOverride(~this.IsSystemObjectSource);
end
