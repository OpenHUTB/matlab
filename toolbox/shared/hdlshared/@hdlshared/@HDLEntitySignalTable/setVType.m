function setVType(this,indices,vtypes)





    if isscalar(indices)

        signal=this.Signals(indices);
        signal.VType=vtypes;

    else

        for n=1:length(indices)
            signal=this.Signals(indices(n));
            signal(indices(n)).VType(vtypes{n});
        end

    end
