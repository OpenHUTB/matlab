
function refRate=getReferenceRateForConstantBlocks(this,hN,hC)%#ok<INUSL,INUSD>



    refRate=Inf;



    if~isempty(hN.PirInputSignals)
        for inSig=1:length(hN.PirInputSignals)
            rate=hN.PirInputSignals(inSig).SimulinkRate;
            if(~isinf(rate)&&rate)
                refRate=rate;
                return;
            end
        end
    end

    if~isempty(hN.PirOutputSignals)
        for outSig=1:length(hN.PirOutputSignals)
            rate=hN.PirOutputSignals(outSig).SimulinkRate;
            if(~isinf(rate)&&rate)
                refRate=rate;
                return;
            end
        end
    end

    return

end
