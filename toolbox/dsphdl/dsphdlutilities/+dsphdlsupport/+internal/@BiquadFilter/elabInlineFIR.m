function[outputsig,validout,delay]=elabInlineFIR(obj,net,blockInfo,numerator,inputsig,validin,name)




    Ntaps=numel(numerator);
    if blockInfo.FrameSize==1
        inputType=inputsig.Type;
    else
        inputType=inputsig.Type.BaseType;
    end
    inputRate=inputsig.SimulinkRate;
    delay=0;

    if Ntaps==1

        delayline=net.addSignal(inputType,['delayline',name]);
        delayline.SimulinkRate=inputRate;
        pirelab.getUnitDelayEnabledComp(net,inputsig,delayline,validin,'tapDelayLine');
    else
        if blockInfo.FrameSize==1
            delayline=[];
            for ii=1:Ntaps
                outSig=net.addSignal(inputType,['delayline',int2str(ii),name]);
                outSig.SimulinkRate=inputRate;
                delayline=[delayline,outSig];
                if ii==1
                    tapSig=inputsig;
                else
                    tapSig=delayline(end-1);
                end
                pirelab.getUnitDelayEnabledComp(net,tapSig,outSig,validin,sprintf('tapDelay%dLine',ii));
            end
        else
            NtapsAdj=(ceil(Ntaps/blockInfo.FrameSize)+1)*blockInfo.FrameSize;
            inVec=inputsig.split;
            delayline=[];
            for ii=1:NtapsAdj
                outSig=net.addSignal(inputType,['delayline',int2str(ii),name]);
                outSig.SimulinkRate=inputRate;
                delayline=[delayline,outSig];
                if ii<=blockInfo.FrameSize


                    pirelab.getUnitDelayEnabledComp(net,inVec.PirOutputSignals(blockInfo.FrameSize-ii+1),...
                    outSig,validin,sprintf('tapDelay%dLine',ii));
                else
                    insig=delayline(ii-blockInfo.FrameSize);
                    pirelab.getUnitDelayEnabledComp(net,insig,outSig,validin,sprintf('tapDelay%dLine',ii));
                end
            end
        end

    end

    [outputsig,validout,gainsumdelay]=elabInlineGainSum(obj,net,blockInfo,numerator,delayline,validin,name);
    delay=delay+gainsumdelay;

end
