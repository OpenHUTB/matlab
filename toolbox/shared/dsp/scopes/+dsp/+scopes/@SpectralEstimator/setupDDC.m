function setupDDC(obj)





    obj.pInputProcessingFunction=@dsp.scopes.SpectralEstimator.noAction;
    obj.pIsDownSamplerEnabled=false;
    obj.pIsDownConverterEnabled=false;
    obj.pActualSampleRate=obj.SampleRate;
    if strcmp(obj.FrequencySpan,'Full')||~obj.DigitalDownConvert||strcmp(obj.FrequencyResolutionMethod,'WindowLength')


        return
    end



    L=256;
    maximumDF=floor(obj.SampleRate/(L*getRBW(obj)));



    G=16;
    percentBW=0.85;

    BWNoDC=2*max(abs(getFstart(obj)),abs(getFstop(obj)));



    DFNoDownConversion=min(maximumDF,floor(percentBW*obj.SampleRate/BWNoDC));

    BWDC=getSpan(obj);

    DFWithDownConversion=min(maximumDF,floor(percentBW*obj.SampleRate/BWDC));
    DFRatio=DFWithDownConversion/DFNoDownConversion;
    ddcEnabledFlag=false;

    availableDF=cell2mat(keys(obj.pDDCCoeffs));

    if DFWithDownConversion>=4&&(DFRatio>G||DFNoDownConversion<4)
        ddcEnabledFlag=true;
        obj.pIsDownSamplerEnabled=true;
        obj.pIsDownConverterEnabled=true;
        DF=availableDF(availableDF<=DFWithDownConversion);
        DF=DF(end);
        releaseDDC(obj);
        obj.sDDCOscillatorBypassed=false;
        obj.sDDCOscillator=dsp.SineWave('ComplexOutput',true,'OutputDataType','double','Frequency',getCenterFrequency(obj),'SampleRate',obj.SampleRate,'SamplesPerFrame',obj.pInputFrameLength);

    elseif DFNoDownConversion>=4
        ddcEnabledFlag=true;
        obj.pIsDownSamplerEnabled=true;
        DF=availableDF(availableDF<=DFNoDownConversion);
        DF=DF(end);
        releaseDDC(obj);
        obj.sDDCOscillatorBypassed=true;

    end
    if ddcEnabledFlag


        s=obj.pDDCCoeffs(DF);
        obj.sDDCDecimationFactor=prod(s.decimFactors);
        obj.sDDCStage1=dsp.FIRDecimator('DecimationFactor',s.decimFactors(1),'Numerator',getCICFIRCoefficients(obj,s.numCICSections,s.decimFactors(1)));
        if~obj.sDDCOscillatorBypassed
            obj.sDDCCICNormFactor=sqrt(2)*(1/(obj.sDDCStage1.DecimationFactor^(s.numCICSections)));
        else
            obj.sDDCCICNormFactor=1/(obj.sDDCStage1.DecimationFactor^(s.numCICSections));
        end
        obj.sDDCStage2=dsp.FIRDecimator('DecimationFactor',s.decimFactors(2),'Numerator',s.secondStageCoeffs);
        obj.sDDCStage3Bypassed=true;
        if length(s.decimFactors)==3
            obj.sDDCStage3Bypassed=false;
            obj.sDDCStage3=dsp.FIRDecimator('DecimationFactor',s.decimFactors(3),'Numerator',s.thirdStageCoeffs);
        end
        obj.pActualSampleRate=obj.SampleRate/DF;
        obj.pInputProcessingFunction=@dsp.scopes.SpectralEstimator.DDCAndBuffer;
    end
end
