function b=isVarRateSupported(this)





    b=false;
    for n=1:length(this.Stage)
        b=b||isVarRateSupported(this.Stage(n));
    end

