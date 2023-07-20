
function gainComp=getGainComp(hN,hInSignals,hOutSignals,gainFactor,gainMode,...
    constMultiplierOptimMode,roundMode,satMode,compName,gainParamGeneric,...
    isPowerOfTwo,TunableParamStr,TunableParamType,nfpOptions,matMulKind)




    newInputSignals=targetmapping.makeInputSameDimensionAsOutput(hN,hInSignals,hOutSignals,compName);

    if all(gainFactor==1,'all')&&isempty(TunableParamType)&&gainMode==1
        gainComp=pirelab.getWireComp(hN,newInputSignals,hOutSignals,[compName,'_unary']);
    elseif all(gainFactor==-1,'all')&&isempty(TunableParamType)&&gainMode==1
        gainComp=pirelab.getUnaryMinusComp(hN,newInputSignals,hOutSignals,'wrap',[compName,'_unaryminus']);
    else
        gainComp=pircore.getGainComp(hN,newInputSignals,hOutSignals,gainFactor,gainMode,...
        constMultiplierOptimMode,roundMode,satMode,compName,int8(0),...
        TunableParamStr,TunableParamType,nfpOptions,matMulKind);
    end

    if strcmpi(class(gainComp),'hdlcoder.gain_comp')

        gainComp.setPowerOf2Gain(isPowerOfTwo);

        if~gainParamGeneric&&targetcodegen.targetCodeGenerationUtils.isNFPMode
            gfval=double(gainFactor);
            if(hdlispowerof2(gfval))
                gainComp.setPowerOf2Gain(true);
            end
        end
    end


    if hOutSignals.NumberOfReceivers==1
        buffer_comps=hOutSignals.getConcreteReceivingComps;
        for ii=1:numel(buffer_comps)
            buffer_comp=buffer_comps(ii);
            if strcmpi(class(buffer_comp),'hdlcoder.buffer_comp')
                numOutPipeline=buffer_comp.getOutputPipeline;
                numInPipeline=buffer_comp.getInputPipeline;
                numConstrainedOutPipeline=buffer_comp.getConstrainedOutputPipeline;
                gainComp.setOutputPipeline(numOutPipeline);
                gainComp.setInputPipeline(numInPipeline);
                gainComp.setConstrainedOutputPipeline(numConstrainedOutPipeline);
                buffer_comp.setOutputPipeline(0);
                buffer_comp.setInputPipeline(0);
                buffer_comp.setConstrainedOutputPipeline(0);
            end
        end
    end

end


