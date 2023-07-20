function system=getSystem(this,indices)




    if isscalar(indices)
        signal=this.Signals(indices);
        system=signal.System;
    else
        system={};
        for n=1:length(indices)
            signal=this.Signals(indices(n));
            system{n}=signal.System;
        end
    end

