function vector=getVector(this,indices)





    if isscalar(indices)
        signal=this.Signals(indices);
        vector=signal.Vector;
    else
        vector={};
        for n=1:length(indices)
            signal=this.Signals(indices(n));
            vector{n}=signal.Vector;
        end
    end

