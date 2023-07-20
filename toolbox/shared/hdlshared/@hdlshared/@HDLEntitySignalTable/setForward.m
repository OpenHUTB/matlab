function setForward(this,indices,fwd)





    if isscalar(indices)

        signal=this.Signals(indices);
        signal.Forward(fwd);

    else

        for n=1:length(indices)
            signal=this.Signals(indices(n));
            signal.Forward(fwd(n));
        end

    end
