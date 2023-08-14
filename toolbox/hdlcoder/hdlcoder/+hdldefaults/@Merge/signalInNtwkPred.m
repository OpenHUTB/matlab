function returnSig=signalInNtwkPred(signal,targetNtwk)





    if signal.Owner.SimulinkHandle==targetNtwk.SimulinkHandle
        returnSig=signal;
    else
        returnSig=hdlhandles(0,0);
    end
end

