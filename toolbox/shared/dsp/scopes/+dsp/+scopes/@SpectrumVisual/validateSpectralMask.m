function validateSpectralMask(this)




    maskSpec=this.MaskSpecificationObject;


    if strcmp(this.pViewType,'Spectrogram')||...
        strcmp(this.pSpectrumUnits,'Watts')||isCCDFMode(this)||...
        strcmp(maskSpec.EnabledMasks,'None')
        return;
    end

    isScopeLocked=isSourceRunning(this);
    if isScopeLocked

        if strcmp(maskSpec.ReferenceLevel,'Spectrum peak')
            maskSelectedChannel=maskSpec.SelectedChannel;
            if isnumeric(maskSelectedChannel)&&maskSelectedChannel>this.DataBuffer.NumChannels
                error(message('dspshared:SpectrumAnalyzer:invalidMaskChannelNumber'));
            end
        end


        [Fstart,Fstop]=getCurrentFreqLimits(this);
        freqOffset=maskSpec.MaskFrequencyOffset;
        if any(strcmp(maskSpec.EnabledMasks,{'Upper','Upper and lower'}))&&...
            ~isscalar(maskSpec.UpperMask)
            freqUpper=maskSpec.UpperMask(:,1)+freqOffset;
            if(max(freqUpper)<Fstart)||(min(freqUpper)>Fstop)
                warning(message('dspshared:SpectrumAnalyzer:maskFallsOutsideFrequencyRange','upper'));
            end
        end


        if any(strcmp(maskSpec.EnabledMasks,{'Lower','Upper and lower'}))&&...
            ~isscalar(maskSpec.LowerMask)
            freqLower=maskSpec.LowerMask(:,1)+freqOffset;
            if(max(freqLower)<Fstart)||(min(freqLower)>Fstop)
                warning(message('dspshared:SpectrumAnalyzer:maskFallsOutsideFrequencyRange','lower'));
            end
        end
    end