function updateFrequencySpan(this)




    hPlotter=this.Plotter;
    if~isempty(hPlotter)


        [newFreqOffset,errID]=evaluateVariable(this.Application,getPropertyValue(this,'FrequencyOffset'));
        if~isempty(errID)
            newFreqOffset=0;
        end
        if all(newFreqOffset==newFreqOffset(1))

            FO=newFreqOffset(1);
        else
            numChannels=this.DataBuffer.NumChannels;
            if numel(newFreqOffset)>=numChannels


                FO=newFreqOffset(1:numChannels);
            else

                FO=ones(1,numChannels)*newFreqOffset(end);
                FO(1:numel(newFreqOffset))=newFreqOffset(:);
            end
            if strcmp(this.pViewType,'Spectrogram')||isCombinedViewMode(this)


                FO=FO(this.pChannelNumber);
            end
        end
        hPlotter.FrequencyOffset=FO;
        twoSidedFlag=this.pTwoSidedSpectrum;
        if~isFrequencyInputMode(this)


            freqSpan=getPropertyValue(this,'FrequencySpan');
            if strcmp(freqSpan,'Full')

                [Fs,errid]=evalPropertyValue(this,'SampleRate');
                if isempty(errid)
                    hPlotter.FrequencyLimits=[-Fs/2*twoSidedFlag,Fs/2]+[min(FO),max(FO)];
                end
            elseif strcmp(freqSpan,'Span and center frequency')
                [span,errid1]=evalPropertyValue(this,'Span');
                [CF,errid2]=evalPropertyValue(this,'CenterFrequency');
                if isempty(errid1)&&isempty(errid2)
                    hPlotter.FrequencyLimits=[CF-span/2,CF+span/2];
                end
            elseif strcmp(freqSpan,'Start and stop frequencies')
                [Fstart,errid1]=evalPropertyValue(this,'StartFrequency');
                [Fstop,errid2]=evalPropertyValue(this,'StopFrequency');
                if isempty(errid1)&&isempty(errid2)
                    hPlotter.FrequencyLimits=[Fstart,Fstop];
                end
            end
        else

            Fs=this.pSampleRate;
            if strcmp(getPropertyValue(this,'FrequencyVectorSource'),'Auto')||isempty(this.CurrentFVector)||all(this.CurrentFVector==0)
                hPlotter.FrequencyLimits=[-Fs/2*twoSidedFlag,Fs/2]+[min(FO),max(FO)];
            else
                if~isempty(this.CurrentFVector)
                    hPlotter.FrequencyLimits=[this.CurrentFVector(1),this.CurrentFVector(end)]+[min(FO),max(FO)];
                end
            end
        end



        updateFrequencySpan(hPlotter);
        if isSpectrogramMode(this)||isCombinedViewMode(this)
            updateTimeSpan(hPlotter)
        end

        if~isempty(this.MaskTesterObject)
            setSpectralFrequencyOffset(this.MaskTesterObject,FO);
            redoMaskTest(this);
        end
    end
