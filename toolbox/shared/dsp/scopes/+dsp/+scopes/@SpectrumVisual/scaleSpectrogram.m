function S=scaleSpectrogram(this)





    S=this.CurrentSpectrogram;
    if any(strcmp({'Power','RMS'},this.pSpectrumType))&&strcmp(this.pMethod,'Welch')


        actualRBW=getActualRBW(this.SpectrumObject);

        S=S*actualRBW;
    elseif any(strcmp({'Power','RMS'},this.pSpectrumType))&&strcmp(this.pMethod,'Filter bank')


        sampleRate=getActualSampleRate(this.SpectrumObject);
        nFFT=getNFFT(this.SpectrumObject);
        S=S.*(sampleRate/nFFT);
    end

    if this.pReferenceLoad~=1
        S=S/this.pReferenceLoad;
    end


    minVal=1e-300;
    maxVal=1e300;
    if~strcmp(this.pSpectrumUnits,'Watts')
        if strcmp(this.pSpectrumUnits,'dBm')
            dBmFactor=30;



            S=real(10*log10(S+eps(0)))+dBmFactor;
            minVal=10*(log10(minVal+eps(0)))+dBmFactor;
            maxVal=10*(log10(maxVal+eps(0)))+dBmFactor;
        elseif strcmp(this.pSpectrumUnits,'Vrms')
            S=sqrt(S+eps(0));
            minVal=sqrt(minVal+eps(0));
            maxVal=sqrt(maxVal+eps(0));
        elseif strcmp(this.pSpectrumUnits,'dBV')
            S=20.*log10(sqrt(S+eps(0)));
            minVal=20.*log10(sqrt(minVal+eps(0)));
            maxVal=20.*log10(sqrt(maxVal+eps(0)));
        elseif strcmp(this.pSpectrumUnits,'dBW')
            S=10*log10(S+eps(0));
            maxVal=10*log10(maxVal+eps(0));
            minVal=10*log10(minVal+eps(0));
        elseif strcmp(this.pSpectrumUnits,'dBFS')
            S=20.*log10(sqrt(S+eps(0))./(this.pFullScale+eps(0)));
            S(S>0)=0;
            maxVal=20.*log10(sqrt(maxVal)./(this.pFullScale+eps(0)));
            maxVal(maxVal>0)=0;
            minVal=20.*log10(sqrt(minVal)./(this.pFullScale+eps(0)));
            minVal(minVal>0)=0;
        end
    end


    if this.SpectrogramLineCounter>0
        minPower=real(mean(min(S(1:this.SpectrogramLineCounter,:))));
        minPower=max(minPower,minVal);
        minPower=min(minPower,maxVal);
        maxPower=real(max(max(S(1:this.SpectrogramLineCounter,:))));
        maxPower=max(maxPower,minVal);
        maxPower=min(maxPower,maxVal);
        this.PowerColorExtents=[minPower,maxPower];
    end
end
