classdef SpectralMaskTester<handle








    properties
        Enabled=false;

        pEnabledMasks='None';
        pUpperMask=Inf;
        pLowerMask=-Inf;
        pReferenceLevel='Custom';
        pCustomReferenceLevel=0;
        pSelectedChannel=1;
        pMaskFrequencyOffset=0;
    end

    properties(SetAccess=protected)

        IsCurrentlyPassing=true;
        NumPassedTests=0;
        NumTotalTests=0;
        SuccessRate=NaN;
        FailingMasks='None';
        FailingChannels=[];
    end

    properties(SetAccess=protected,Hidden)
        SpectrumVisual;
        MaskSpecificationObject;
    end

    properties(Access=protected)

        SpectrumFrequencyOffset=0;

        CurrentPSD;
        CurrentFVector;
        CurrentPowerOffset;
        CachedSimulationTime=-1;



        UpperMaskCache;
        LowerMaskCache;
        UpperMaskInterpolated;
        LowerMaskInterpolated;
        FVectorWhenInterpolated;

        StatusBarTextCache;
    end

    methods
        function this=SpectralMaskTester(hVisual)

            this.SpectrumVisual=hVisual;
        end

        function setSpectralFrequencyOffset(this,val)


            if any(this.SpectrumFrequencyOffset~=val)
                this.SpectrumFrequencyOffset=val(:).';
                this.FVectorWhenInterpolated=[];
            end
        end

        function setup(this)
            this.MaskSpecificationObject=this.SpectrumVisual.MaskSpecificationObject;
        end

        function reset(this)

            this.IsCurrentlyPassing=true;
            this.NumPassedTests=0;
            this.NumTotalTests=0;
            this.SuccessRate=NaN;
            this.FailingMasks='None';
            this.FailingChannels=[];

            this.UpperMaskInterpolated=[];
            this.LowerMaskInterpolated=[];
            this.FVectorWhenInterpolated=[];
            this.CurrentPSD=[];
            this.CurrentFVector=[];
            this.CachedSimulationTime=-1;
        end

        function s=getMaskStatus(this)

            if this.Enabled&&~strcmp(this.pEnabledMasks,'None')
                s.IsCurrentlyPassing=this.IsCurrentlyPassing;
                s.NumPassedTests=this.NumPassedTests;
                s.NumTotalTests=this.NumTotalTests;
                s.SuccessRate=this.SuccessRate;
                if s.IsCurrentlyPassing
                    s.FailingChannels=[];
                    s.FailingMasks='None';
                else
                    s.FailingMasks=this.FailingMasks;
                    s.FailingChannels=this.FailingChannels;
                end
                s.SimulationTime=getCurrentSimulationTime(this);
            else
                s=struct([]);
            end
        end

        function maskStruct=getCurrentMask(this)
            maskStruct.EnabledMasks=this.pEnabledMasks;
            maskStruct.UpperMask=[];
            maskStruct.LowerMask=[];
            if~isempty(this.UpperMaskCache)
                maskStruct.UpperMask=[this.UpperMaskCache(:,1),(this.UpperMaskCache(:,2)+this.CurrentPowerOffset)];
            end
            if~isempty(this.LowerMaskCache)
                maskStruct.LowerMask=[this.LowerMaskCache(:,1),(this.LowerMaskCache(:,2)+this.CurrentPowerOffset)];
            end
        end

        function performMaskTest(this,PSD,FVect,batchIndex)



            if isempty(PSD)||isempty(FVect)
                return;
            else

                this.CurrentPSD=PSD;
                this.CurrentFVector=FVect;
            end


            if~this.Enabled
                return;
            end

            if nargin<4
                batchIndex=1;
            end


            if isempty(this.FVectorWhenInterpolated)||...
                isempty(this.UpperMaskInterpolated)||...
                isempty(this.LowerMaskInterpolated)||...
                ~isequal(this.FVectorWhenInterpolated,FVect)


                cacheInterpolatedMask(this,FVect);
            end


            if~isFrequencyInputMode(this.SpectrumVisual)
                PSD=scaleSpectrum(this,PSD);
            end


            enabledMasks=this.pEnabledMasks;
            if strcmp(this.pReferenceLevel,'Spectrum peak')
                powerOffset=0;
                if strcmp(this.pSelectedChannel,'All')
                    powerOffset=max(max(PSD));
                elseif size(PSD,2)>=this.pSelectedChannel
                    powerOffset=max(PSD(:,this.pSelectedChannel));
                end
            else
                powerOffset=this.pCustomReferenceLevel;
            end
            this.CurrentPowerOffset=powerOffset;


            upperMaskPassing=true;
            lowerMaskPassing=true;
            this.FailingMasks='None';
            this.FailingChannels=[];
            if strcmp(enabledMasks,'Upper')||strcmp(enabledMasks,'Upper and lower')
                upperMaskLimits=this.UpperMaskInterpolated+powerOffset;
                [~,c]=find(PSD>upperMaskLimits);
                if~isempty(c)
                    upperMaskPassing=false;
                    this.FailingChannels=unique(c(:).','sorted');
                    this.FailingMasks='Upper';
                end
            end


            if strcmp(enabledMasks,'Lower')||strcmp(enabledMasks,'Upper and lower')
                lowerMaskLimits=this.LowerMaskInterpolated+powerOffset;
                [~,c]=find(PSD<lowerMaskLimits);
                if~isempty(c)
                    lowerMaskPassing=false;
                    this.FailingChannels=unique([this.FailingChannels,c(:).'],'sorted');
                    if upperMaskPassing
                        this.FailingMasks='Lower';
                    else
                        this.FailingMasks='Upper and lower';
                    end
                end
            end





            currSimTime=getCurrentSimulationTime(this);
            newDataFlag=(this.CachedSimulationTime<currSimTime)||(batchIndex>1);


            prevTestPassed=(this.NumPassedTests>0)&&this.IsCurrentlyPassing;
            this.IsCurrentlyPassing=upperMaskPassing&&lowerMaskPassing;
            if newDataFlag
                this.NumPassedTests=this.NumPassedTests+double(this.IsCurrentlyPassing);
                this.NumTotalTests=this.NumTotalTests+1;
                this.CachedSimulationTime=currSimTime;
            else

                this.NumPassedTests=(this.NumPassedTests-prevTestPassed)+double(this.IsCurrentlyPassing);
                this.NumTotalTests=max(1,this.NumTotalTests);
            end
            this.SuccessRate=(this.NumPassedTests*100/this.NumTotalTests);
        end

        function redoMaskTest(this)



            this.FVectorWhenInterpolated=[];
            performMaskTest(this,this.CurrentPSD,this.CurrentFVector);
        end

        function t=getCurrentSimulationTime(this)
            t=this.SpectrumVisual.SimulationTime;
        end
    end

    methods(Access=protected)
        function cacheInterpolatedMask(this,spectrumFreq)


            spectrumFreqWithOffset=spectrumFreq+this.SpectrumFrequencyOffset;
            [freqLim(1),freqLim(2)]=getCurrentFreqLimits(this.SpectrumVisual);
            freqOffset=this.pMaskFrequencyOffset;


            if isscalar(this.pUpperMask)
                freqUpper=freqLim(:);
                powerUpper=[this.pUpperMask;this.pUpperMask];
            else
                freqUpper=this.pUpperMask(:,1)+freqOffset;
                freqUpper=replaceInfiniteFrequencies(freqUpper,freqLim);
                powerUpper=this.pUpperMask(:,2);
            end
            this.UpperMaskCache=[freqUpper,powerUpper];
            this.UpperMaskInterpolated=getInterpolatedPower(freqUpper,powerUpper,spectrumFreqWithOffset);



            if isscalar(this.pLowerMask)
                freqLower=freqLim(:);
                powerLower=[this.pLowerMask;this.pLowerMask];
            else
                freqLower=this.pLowerMask(:,1)+freqOffset;
                freqLower=replaceInfiniteFrequencies(freqLower,freqLim);
                powerLower=this.pLowerMask(:,2);
            end
            this.LowerMaskCache=[freqLower,powerLower];
            this.LowerMaskInterpolated=getInterpolatedPower(freqLower,powerLower,spectrumFreqWithOffset);



            this.FVectorWhenInterpolated=spectrumFreq;
        end

        function scaledPSD=scaleSpectrum(this,unscaledPSD)




            scaledPSD=unscaledPSD;


            hVisual=this.SpectrumVisual;
            if strcmp(hVisual.pSpectrumType,'Power')
                actualRBW=getActualRBW(hVisual.SpectrumObject);
                scaledPSD=scaledPSD*actualRBW;
            end

            if hVisual.pReferenceLoad~=1
                scaledPSD=scaledPSD/hVisual.pReferenceLoad;
            end


            if~strcmp(hVisual.pSpectrumUnits,'Watts')
                dBmFactor=30*strcmp(hVisual.pSpectrumUnits,'dBm');



                scaledPSD=10*log10(scaledPSD+eps(0))+dBmFactor;
            end
            scaledPSD=squeeze(scaledPSD);
        end
    end
end

function interpPower=getInterpolatedPower(maskFreq,maskPower,spectrumFreq)
    maskPower(isinf(maskPower))=NaN;

    maskFreqUnique=maskFreq;
    offset=eps(maskFreq(1));
    for indx=2:numel(maskFreq)
        if maskFreq(indx)==maskFreq(indx-1)
            maskFreqUnique(indx)=maskFreq(indx)+offset;
            offset=offset+eps(maskFreq(indx));
        else
            offset=eps(maskFreq(indx));
        end
    end

    interpPower=interp1(maskFreqUnique,maskPower,spectrumFreq);
end

function freqVector=replaceInfiniteFrequencies(freqVector,axesLimits)
    if isinf(freqVector(1))

        freqVector(1)=sign(freqVector(1))*100*abs(min(axesLimits(1),freqVector(2)));
    end
    if isinf(freqVector(end))

        freqVector(end)=sign(freqVector(end))*100*abs(max(axesLimits(end),freqVector(end-1)));
    end
end
