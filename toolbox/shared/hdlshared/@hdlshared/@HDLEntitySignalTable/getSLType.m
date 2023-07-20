function sltype=getSLType(this,indices)





    if isscalar(indices)
        signal=this.Signals(indices);
        sltype=signal.SLType;
    else
        sltype={};
        for n=1:length(indices)
            signal=this.Signals(indices(n));
            sltype{n}=signal.SLType;
        end
    end

