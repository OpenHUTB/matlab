function this=removeSignalsForTopMdl(this)






    idxToRemove=[];
    len=length(this.signals_);
    for idx=len:-1:1
        if this.signalIsInTopMdl(idx)
            idxToRemove=[idxToRemove,idx];%#ok<AGROW>
        end
    end


    this=this.removeSignals_(idxToRemove);

end
