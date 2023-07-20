function[PSD,maxHoldPSD,minHoldPSD,FVect]=scaleSpectrum(this)




    PSD=this.CurrentPSD;
    maxHoldPSD=this.CurrentMaxHoldPSD;
    minHoldPSD=this.CurrentMinHoldPSD;
    FVect=this.CurrentFVector;

    if any(strcmp({'Power','RMS'},this.pSpectrumType))&&strcmp(this.pMethod,'Welch')


        actualRBW=getActualRBW(this.SpectrumObject);
        PSD=PSD*actualRBW;
        maxHoldPSD=maxHoldPSD*actualRBW;
        minHoldPSD=minHoldPSD*actualRBW;
    elseif any(strcmp({'Power','RMS'},this.pSpectrumType))&&strcmp(this.pMethod,'Filter bank')


        sampleRate=getActualSampleRate(this.SpectrumObject);
        nFFT=getNFFT(this.SpectrumObject);
        PSD=PSD.*(sampleRate/nFFT);
        maxHoldPSD=maxHoldPSD.*(sampleRate/nFFT);
        minHoldPSD=minHoldPSD.*(sampleRate/nFFT);
    end

    if this.pReferenceLoad~=1
        PSD=PSD/this.pReferenceLoad;
        maxHoldPSD=maxHoldPSD/this.pReferenceLoad;
        minHoldPSD=minHoldPSD/this.pReferenceLoad;
    end


    if~strcmp(this.pSpectrumUnits,'Watts')
        if strcmp(this.pSpectrumUnits,'dBm')
            dBmFactor=30;



            PSD=10*log10(PSD+eps(0))+dBmFactor;
            maxHoldPSD=10*log10(maxHoldPSD+eps(0))+dBmFactor;
            minHoldPSD=10*log10(minHoldPSD+eps(0))+dBmFactor;
        elseif strcmp(this.pSpectrumUnits,'Vrms')
            PSD=sqrt(PSD+eps(0));
            maxHoldPSD=sqrt(maxHoldPSD+eps(0));
            minHoldPSD=sqrt(minHoldPSD+eps(0));
        elseif strcmp(this.pSpectrumUnits,'dBV')
            PSD=20.*log10(sqrt(PSD+eps(0)));
            maxHoldPSD=20.*log10(sqrt(maxHoldPSD+eps(0)));
            minHoldPSD=20.*log10(sqrt(minHoldPSD+eps(0)));
        elseif strcmp(this.pSpectrumUnits,'dBW')
            PSD=10*log10(PSD+eps(0));
            maxHoldPSD=10*log10(maxHoldPSD+eps(0));
            minHoldPSD=10*log10(minHoldPSD+eps(0));
        elseif strcmp(this.pSpectrumUnits,'dBFS')

            PSD=20.*log10(sqrt(PSD+eps(0))./(this.pFullScale+eps(0)));
            PSD(PSD>0)=0;
            maxHoldPSD=20.*log10(sqrt(maxHoldPSD)./(this.pFullScale+eps(0)));
            maxHoldPSD(maxHoldPSD>0)=0;
            minHoldPSD=20.*log10(sqrt(minHoldPSD)./(this.pFullScale+eps(0)));
            minHoldPSD(minHoldPSD>0)=0;
        end
    end
    PSD=squeeze(PSD);
    maxHoldPSD=squeeze(maxHoldPSD);
    minHoldPSD=squeeze(minHoldPSD);
end
