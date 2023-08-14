function complex=getComplex(this,indices)





    if isscalar(indices)
        signal=this.Signals(indices);
        complex=signal.Complex;
    else
        complex={};
        for n=1:length(indices)
            signal=this.Signals(indices(n));
            complex{n}=signal.Complex;
        end
    end

