function varargout=validateSpectrumSettings(this)













    flag=true;
    errorMsg=[];
    Fstart=[];
    Fstop=[];
    isRBWMethod=strcmp(this.pFrequencyResolutionMethod,'RBW');
    isWindowLengthMethod=strcmp(this.pFrequencyResolutionMethod,'WindowLength');
    isNumFrequencyBandsMethod=strcmp(this.pFrequencyResolutionMethod,'NumFrequencyBands');
    isSpectrogram=strcmp(this.pViewType,'Spectrogram');
    isCombinedView=strcmp(this.pViewType,'Spectrum and spectrogram');
    isFilterBank=strcmp(this.pMethod,'FilterBank');


    validSettings_local=this.IsValidSettingsDialogReadouts;
    this.IsValidSettingsDialogReadouts=false;


    if nargout>1
        freqSpan=getPropertyValue(this,'FrequencySpan');
        if strcmp(freqSpan,'Span and center frequency')
            [span_local,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'Span'));
            if~isempty(errStr)
                varargout{1}=false;
                varargout{2}=errStr;
                return
            end
            [cf_local,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'CenterFrequency'));
            if~isempty(errStr)
                varargout{1}=false;
                varargout{2}=errStr;
                return
            end
            if~this.pTwoSidedSpectrum&&cf_local==0



                Fstart=0;
                Fstop=span_local;
            else
                Fstart=cf_local-(span_local/2);
                Fstop=cf_local+(span_local/2);
            end
        end
        if strcmp(freqSpan,'Start and stop frequencies')
            [Fstart,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'StartFrequency'));
            if~isempty(errStr)
                varargout{1}=false;
                varargout{2}=errStr;
                return
            end
            [Fstop,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'StopFrequency'));
            if~isempty(errStr)
                varargout{1}=false;
                varargout{2}=errStr;
                return
            end
        end
    end
    hSpectrum=this.SpectrumObject;


    validateattributes(hSpectrum.SampleRate,{'double'},{'positive','real','scalar'},'','SampleRate');
    if strcmp(hSpectrum.FrequencySpan,'Span and center frequency')
        if nargout
            [flag,errMsg]=isValidDataType(this,'Span',span_local,true);
            if~flag
                varargout{1}=false;
                varargout{2}=errMsg;
                return
            end
            [flag,errMsg]=isValidDataType(this,'CF',cf_local);
            if~flag
                varargout{1}=false;
                varargout{2}=errMsg;
                return
            end
        else
            validateattributes(hSpectrum.Span,{'double'},{'positive','real','scalar'},'','Span');
            validateattributes(hSpectrum.CenterFrequency,{'double'},{'real','scalar'},'','CenterFrequency');
        end
    elseif strcmp(hSpectrum.FrequencySpan,'Start and stop frequencies')
        if nargout
            [flag,errMsg]=isValidDataType(this,'Fstart',Fstart);
            if~flag
                varargout{1}=false;
                varargout{2}=errMsg;
                return
            end
            [flag,errMsg]=isValidDataType(this,'Fstop',Fstop);
            if~flag
                varargout{1}=false;
                varargout{2}=errMsg;
                return
            end
        else
            validateattributes(hSpectrum.StartFrequency,{'double'},{'real','scalar'},'','StartFrequency');
            validateattributes(hSpectrum.StopFrequency,{'double'},{'real','scalar'},'','StopFrequency');
        end
    end

    if isFilterBank
        numTapsPerBand=evalPropertyValue(this,'NumTapsPerBand');
        validateattributes(numTapsPerBand,...
        {'numeric'},...
        {'finite','real','scalar','>=',0,'integer','even'},...
        '','NumTapsPerBand');
    end

    if isRBWMethod
        if strcmp(getPropertyValue(this,'RBWSource'),'Property')
            if nargout
                [RBW_local,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'RBW'));
                if~isempty(errStr)
                    varargout{1}=false;
                    varargout{2}=errStr;
                    return
                end
                [flag,errMsg]=isValidDataType(this,'RBW',RBW_local,true);
                if~flag
                    varargout{1}=false;
                    varargout{2}=errMsg;
                    return
                end
            else
                validateattributes(hSpectrum.RBW,{'double'},{'positive','real','scalar'},'','RBW');
            end
        end
    end

    if isWindowLengthMethod||isNumFrequencyBandsMethod
        if nargout
            [windowLength_local,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'WindowLength'));
            if~isempty(errStr)
                varargout{1}=false;
                varargout{2}=errStr;
                return
            end
            [flag,errMsg]=isValidDataType(this,'WindowLength',windowLength_local,true,true);
            if~flag
                varargout{1}=false;
                varargout{2}=errMsg;
                return
            end
        else
            windowLength_local=evalPropertyValue(this,'WindowLength');
            validateattributes(windowLength_local,{'double'},{'positive','integer','scalar'},'','WindowLength');
        end
        if strcmp(hSpectrum.FFTLengthSource,'Property')
            if nargout
                [fftLength,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'FFTLength'));
                if~isempty(errStr)
                    varargout{1}=false;
                    varargout{2}=errStr;
                    return
                end
                [flag,errMsg]=isValidDataType(this,'FFTLength',fftLength,true,true);
                if~flag
                    varargout{1}=false;
                    varargout{2}=errMsg;
                    return
                end
            else
                fftLength=evalPropertyValue(this,'FFTLength');
                validateattributes(fftLength,{'double'},{'positive','integer','scalar'},'','FFTLength');
            end
        end
    end

    if isSpectrogram||isCombinedView

        if strcmp(getPropertyValue(this,'TimeSpanSource'),'Property')
            if nargout
                [timeSpan,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'TimeSpan'));
                if~isempty(errStr)
                    varargout{1}=false;
                    varargout{2}=errStr;
                    return
                end
                [flag,errMsg]=isValidDataType(this,'TimeSpan',timeSpan,true);
                if~flag
                    varargout{1}=false;
                    varargout{2}=errMsg;
                    return
                end
            else
                timeSpan=evalPropertyValue(this,'TimeSpan');
                validateattributes(timeSpan,{'double'},{'positive','real','scalar'},'','TimeSpan');
            end
        end

        if strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property')
            if nargout
                [timeResolution,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'TimeResolution'));
                if~isempty(errStr)
                    varargout{1}=false;
                    varargout{2}=errStr;
                    return
                end
                [flag,errMsg]=isValidDataType(this,'TimeResolution',timeResolution,true);
                if~flag
                    varargout{1}=false;
                    varargout{2}=errMsg;
                    return
                end
            else
                timeResolution=evalPropertyValue(this,'TimeResolution');
                validateattributes(timeResolution,{'double'},{'positive','real','scalar'},'','TimeResolution');
            end
        end

        if nargout
            [channelNum,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'ChannelNumber'));
            if~isempty(errStr)
                varargout{1}=false;
                varargout{2}=errStr;
                return
            end
            inputNumChannels=this.Plotter.MaxDimensions(2);


            flag=(channelNum<=inputNumChannels&&channelNum>0);
            if~flag
                varargout{1}=false;
                varargout{2}=getString(message('dspshared:SpectrumAnalyzer:InvalidSpectrogramChannel',inputNumChannels));
                return
            end
        else
            channelNum=evalPropertyValue(this,'ChannelNumber');
            validateattributes(channelNum,{'double'},{'positive','real','scalar','>',0,'<=',100,'integer','finite','nonnan'},'','SpectrogramChannel');
        end
    end

    validateattributes(hSpectrum.SpectralAverages,{'double'},{'positive','real','scalar','integer'},'','SpectralAverages');
    if any(strcmp({'Chebyshev','Kaiser'},hSpectrum.Window))
        validateattributes(hSpectrum.SidelobeAttenuation,{'double'},{'positive','real','scalar'},'','SidelobeAttenuation');
    end
    RL=evalPropertyValue(this,'ReferenceLoad');
    validateattributes(RL,{'double'},{'positive','real','scalar'},'','ReferenceLoad');


    if nargout
        [FO,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'FrequencyOffset'));
        if~isempty(errStr)
            varargout{1}=false;
            varargout{2}=errStr;
            return
        end
        flag=isreal(FO)&&isvector(FO)&&isa(FO,'double')&&all(~isinf(FO))&&all(~isnan(FO));
        if~flag
            varargout{1}=false;
            varargout{2}=getString(message('dspshared:SpectrumAnalyzer:InvalidDatatypeVector','FrequencyOffset'));
            return
        end
    else
        FO=evalPropertyValue(this,'FrequencyOffset');
        validateattributes(FO,{'double'},{'real','vector'},'','FrequencyOffset');
    end
    if isFrequencyInputMode(this)

        if strcmp(getPropertyValue(this,'FrequencyVectorSource'),'Property')
            if nargout
                [FV,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'FrequencyVector'));
                if~isempty(errStr)
                    varargout{1}=false;
                    varargout{2}=errStr;
                    return
                end
                flag=isreal(FV)&&isvector(FV)&&isa(FV,'double')&&issorted(FV)&&numel(FV)>=2&&all(~isinf(FV))&&all(~isnan(FV));


                FV=FV(:)';
                flag=flag&&(size(FV,2)==this.Plotter.MaxDimensions(1))&&abs(min(diff(FV)))~=0;
                if~flag
                    varargout{1}=false;
                    varargout{2}=getString(message('dspshared:SpectrumAnalyzer:InvalidFrequencyVector'));
                    return
                end
            else
                FV=evalPropertyValue(this,'FrequencyVector');
                validateattributes(FV,{'double'},{'real','vector'},'','FrequencyVector');
            end
        end
    end
    continueFlag=true;
    while continueFlag


        if isFrequencyInputMode(this)
            if strcmp(getPropertyValue(this,'FrequencyVectorSource'),'Property')
                FV=evaluateVariable(this.Application,getPropertyValue(this,'FrequencyVector'));
                flag=isreal(FV)&&isvector(FV)&&isa(FV,'double')&&issorted(FV)&&numel(FV)>=2&&all(~isinf(FV))&&all(~isnan(FV));


                FV=FV(:);
                flag=flag&&(numel(FV)==this.Plotter.MaxDimensions(1))&&abs(min(diff(FV)))~=0;
                msgObj=message('dspshared:SpectrumAnalyzer:InvalidFrequencyVector');
                if~flag
                    if nargout
                        flag=false;
                        errorMsg=getString(msgObj);
                        break
                    else
                        error(msgObj);
                    end
                end
            end
        end



        Fs=hSpectrum.SampleRate;
        TwoSidedFlag=hSpectrum.TwoSidedSpectrum;
        freqSpan=hSpectrum.FrequencySpan;
        if strcmp(freqSpan,'Full')
            span_local=Fs/2+Fs/2*TwoSidedFlag;
        else
            if strcmpi(freqSpan,'Span and center frequency')
                span=evalPropertyValue(this,'Span');
                CF=evalPropertyValue(this,'CenterFrequency');
                Fstart=CF-span/2;
                Fstop=CF+span/2;
            else
                Fstart=evalPropertyValue(this,'StartFrequency');
                Fstop=evalPropertyValue(this,'StopFrequency');
            end
            span_local=Fstop-Fstart;
            if Fstart>=Fstop
                msgObj=message('dspshared:SpectrumAnalyzer:FstartGreaterThanFstop');
                if nargout
                    flag=false;
                    errorMsg=getString(msgObj);
                    break
                else
                    error(msgObj);
                end
            end
            NyquistRange=[(-Fs/2)*TwoSidedFlag,Fs/2]+[min(FO),max(FO)];
            if(Fstart<NyquistRange(1)-eps(NyquistRange(1)))||(Fstop>NyquistRange(2)+eps(NyquistRange(2)))
                [NyquistRange,~,unitsNyquistRange]=engunits(NyquistRange);
                [spanRange,~,unitsSpanRange]=engunits([Fstart,Fstop]);
                if strcmp(hSpectrum.FrequencySpan,'Span and center frequency')
                    msgObj=message('dspshared:SpectrumAnalyzer:InvalidSpanAndCenterFrequency',...
                    num2str(spanRange(1)),num2str(spanRange(2)),unitsSpanRange,...
                    num2str(NyquistRange(1)),num2str(NyquistRange(2)),unitsNyquistRange);
                else
                    msgObj=message('dspshared:SpectrumAnalyzer:InvalidStartAndStopFrequencies',...
                    num2str(spanRange(1)),num2str(spanRange(2)),unitsSpanRange,...
                    num2str(NyquistRange(1)),num2str(NyquistRange(2)),unitsNyquistRange);
                end
                if nargout
                    flag=false;
                    errorMsg=getString(msgObj);
                    break
                else
                    error(msgObj);
                end
            end
        end

        if isRBWMethod

            [RBW,~,spectrogramMessage]=getCurrentRBW(this,span_local);
            if(span_local/RBW)<2
                if spectrogramMessage
                    limitTimRes=1/(span_local/2);
                    [tr,~,units]=engunits(limitTimRes);
                    tr=[num2str(tr),' ',units,'s'];
                    msgObj=message('dspshared:SpectrumAnalyzer:InvalidSpanRBWDueToTimeRes',tr);
                else
                    msgObj=message('dspshared:SpectrumAnalyzer:InvalidSpanRBW');
                end
                if nargout
                    flag=false;
                    errorMsg=getString(msgObj);
                    break
                else
                    error(msgObj);
                end
            end
        end

        if isWindowLengthMethod&&strcmp(getPropertyValue(this,'FFTLengthSource'),'Property')...
            &&evalPropertyValue(this,'FFTLength')<evalPropertyValue(this,'WindowLength')
            msgObj=message('dspshared:SpectrumAnalyzer:InvalidFFTLength');
            if nargout
                flag=false;
                errorMsg=getString(msgObj);
                break
            else
                error(msgObj);
            end
        end


        if isNumFrequencyBandsMethod&&strcmp(getPropertyValue(this,'FFTLengthSource'),'Property')...
            &&evalPropertyValue(this,'FFTLength')<2
            msgObj=message('dspshared:SpectrumAnalyzer:InvalidNumFrequencyBands');
            if nargout
                flag=false;
                errorMsg=getString(msgObj);
                break
            else
                error(msgObj);
            end
        elseif isNumFrequencyBandsMethod&&strcmp(getPropertyValue(this,'FFTLengthSource'),'Auto')

            if this.Plotter.MaxDimensions(1)<2
                msgObj=message('dspshared:SpectrumAnalyzer:ScalarInput');
                if nargout
                    flag=false;
                    errorMsg=getString(msgObj);
                    break
                else
                    error(msgObj);
                end
            end
        end



        if isSpectrogram||isCombinedView

            if(isRBWMethod&&strcmp(getPropertyValue(this,'RBWSource'),'Property')...
                &&strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property'))...
                ||(~isRBWMethod&&strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property'))




                if isRBWMethod
                    minTimeRes=1/getCurrentRBW(this,span_local);
                else
                    win=getPropertyValue(this,'Window');
                    SLA=evalPropertyValue(this,'SidelobeAttenuation');
                    NENBW=getWindowENBW(hSpectrum,windowLength_local,win,SLA);
                    minTimeRes=1/(hSpectrum.SampleRate*NENBW/windowLength_local);
                end
                if timeResolution<minTimeRes
                    [minTimeRes,~,minTimeResUnits]=engunits(minTimeRes);
                    deltaTstr=[num2str(minTimeRes),' ',minTimeResUnits,'s'];
                    msgObj=message('dspshared:SpectrumAnalyzer:InvalidTimeResolution',deltaTstr);
                    if nargout
                        flag=false;
                        errorMsg=getString(msgObj);
                        break
                    else
                        error(msgObj);
                    end
                end
            elseif isRBWMethod&&strcmp(getPropertyValue(this,'RBWSource'),'Auto')...
                &&strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property')



                if timeResolution<(1/hSpectrum.SampleRate)
                    [minTimeRes,~,minTimeResUnits]=engunits(1/hSpectrum.SampleRate);
                    deltaTstr=[num2str(minTimeRes),' ',minTimeResUnits,'s'];
                    msgObj=message('dspshared:SpectrumAnalyzer:InvalidTimeResolutionLessThanTs',deltaTstr);
                    if nargout
                        flag=false;
                        errorMsg=getString(msgObj);
                        break
                    else
                        error(msgObj);
                    end
                end
            end


            if strcmp(getPropertyValue(this,'TimeSpanSource'),'Property')

                if isRBWMethod
                    RBW=getCurrentRBW(this,span_local);
                    [~,wLen]=getWinDurationForAGivenRBW(this,RBW);
                    overlapSamples=getOverlapSamples(this,wLen,evalPropertyValue(this,'OverlapPercent'));
                    numSamplesPerUpdate=wLen-overlapSamples;
                    minTimeRes=1/RBW;
                else
                    overlapSamples=getOverlapSamples(this,windowLength_local,evalPropertyValue(this,'OverlapPercent'));
                    numSamplesPerUpdate=windowLength_local-overlapSamples;
                    win=getPropertyValue(this,'Window');
                    SLA=evalPropertyValue(this,'SidelobeAttenuation');
                    NENBW=getWindowENBW(hSpectrum,windowLength_local,win,SLA);
                    minTimeRes=1/(hSpectrum.SampleRate*NENBW/windowLength_local);
                end
                if strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property')
                    NumUpdatesPerSpectrgramLine=max(1,floor(timeResolution/minTimeRes));
                    weight=abs((timeResolution-NumUpdatesPerSpectrgramLine*minTimeRes))/minTimeRes;
                    extraTimeIncrement=weight*numSamplesPerUpdate/hSpectrum.SampleRate;
                else
                    NumUpdatesPerSpectrgramLine=1;
                    extraTimeIncrement=0;
                end
                timeIncrement=extraTimeIncrement+(NumUpdatesPerSpectrgramLine*numSamplesPerUpdate/hSpectrum.SampleRate);
                if timeSpan<2*timeIncrement
                    [timeIncrement,~,units]=engunits(2*timeIncrement);
                    timeIncStr=[num2str(timeIncrement),' ',units,'s'];
                    msgObj=message('dspshared:SpectrumAnalyzer:InvalidTimeSpan',timeIncStr);
                    if nargout
                        flag=false;
                        errorMsg=getString(msgObj);
                        break
                    else
                        error(msgObj);
                    end
                end
            end
        end
        continueFlag=false;
    end

    this.IsValidSettingsDialogReadouts=validSettings_local;
    if nargout
        varargout{1}=flag;
        if nargout>1
            if flag
                varargout{2}={};
            else
                varargout{2}=errorMsg;
            end
        end
    end
end
