function rate=getRate(this,indices)





    if isscalar(indices)
        signal=this.Signals(indices);
        rate=signal.Rate;
    else
        rate={};
        for n=1:length(indices)
            signal=this.Signals(indices(n));
            rate{n}=signal.Rate;
        end
    end

