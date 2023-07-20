function forwards=getForwards(this,indices)





    if isscalar(indices)
        signal=this.Signals(indices);
        forwards=signal.Forward;
    else
        forwards=[];
        for n=1:length(indices)
            signal=this.Signals(indices(n));
            forwards(n)=signal.Forward;
        end
    end

