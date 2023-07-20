function varargout=makeValidLine(~,hN,inSignal,outSignal,blkInfo)















    latency=blkInfo.Latency;

    if latency>0
        validComp=pirelab.getIntDelayComp(hN,inSignal,outSignal,latency,...
        'valid_reg',0);
    else
        validComp=pirelab.getWireComp(hN,inSignal,outSignal);
    end
    if nargout==1
        varargout{1}=validComp;
    end

end
