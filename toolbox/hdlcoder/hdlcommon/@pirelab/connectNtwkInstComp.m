function connectNtwkInstComp(hNtwkInstComp,hInSignals,hOutSignals)




    hRefNetwork=hNtwkInstComp.ReferenceNetwork;

    refNtwkInSignals=hRefNetwork.PirInputSignals;
    refNtwkOutSignals=hRefNetwork.PirOutputSignals;

    verifyInputRates(hRefNetwork,refNtwkInSignals,hInSignals);
    verifyAndPropagateOutputRates(hRefNetwork,refNtwkOutSignals,hOutSignals);
    pirelab.connectComp(hNtwkInstComp,hInSignals,hOutSignals);
end



function verifyInputRates(hRefNetwork,refNtwkInSignals,hInSignals)
    for ii=1:length(hInSignals)
        inSig=hInSignals(ii);
        refNtwkInSig=refNtwkInSignals(ii);
        inSigRate=inSig.SimulinkRate;
        refNtwkInSigRate=refNtwkInSig.SimulinkRate;
        if~hdlIsEquivalentRate(inSigRate,refNtwkInSigRate)&&inSigRate>0&&...
            refNtwkInSigRate>0&&~(refNtwkInSigRate==Inf||inSigRate==Inf)
            error(message('hdlcommon:hdlcommon:RateMismatch','input',ii,hRefNetwork.Name));
        end
    end
end



function verifyAndPropagateOutputRates(hRefNetwork,refNtwkSignals,instanceSignals)
    for ii=1:length(instanceSignals)
        outSig=instanceSignals(ii);
        refNtwkOutSig=refNtwkSignals(ii);
        outSigRate=outSig.SimulinkRate;
        refNtwkOutSigRate=refNtwkOutSig.SimulinkRate;
        if~hdlIsEquivalentRate(outSigRate,refNtwkOutSigRate)
            if(outSigRate>0)
                error(message('hdlcommon:hdlcommon:RateMismatch','output',ii,hRefNetwork.Name));
            else
                outSig.SimulinkRate=refNtwkOutSigRate;
            end
        end
    end
end
