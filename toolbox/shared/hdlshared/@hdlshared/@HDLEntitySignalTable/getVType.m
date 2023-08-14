function vtype=getVType(this,indices)





    if isscalar(indices)
        signal=this.Signals(indices);
        vtype=signal.VType;
    else
        vtype={};
        for n=1:length(indices)
            signal=this.Signals(indices(n));
            vtype{n}=signal.VType;
        end
    end

