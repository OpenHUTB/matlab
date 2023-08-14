function[sig,index]=findInstrumentedSignal(this)



    sig=[];
    index=-1;
    if~isempty(this.SigInfo)
        port=get(this.SigInfo.portH,'Object');
        OutputPortIndex=port.PortNumber;
        BlockPath=strrep(port.Parent,newline,' ');
        sigs=get_param(this.SigInfo.mdl,'InstrumentedSignals');
        for nSig=1:sigs.Count
            s=sigs.get(nSig);
            if strcmp(s.BlockPath.getBlock(1),BlockPath)&&...
                s.OutputPortIndex==OutputPortIndex
                sig=s;
                index=nSig;
                return;
            end
        end
    end
end
