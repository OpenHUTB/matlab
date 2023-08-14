function tf=isDeltaXTooSmall(xCurrent,delta_x,nVar,StepTolerance)













%#codegen

    coder.allowpcode('plain');


    validateattributes(delta_x,{'double'},{'vector'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(StepTolerance,{'double'},{'scalar'});

    coder.internal.prefer_const(nVar,StepTolerance);

    tf=true;

    for idx=1:nVar
        if(StepTolerance*max(1.0,abs(xCurrent(idx)))<=abs(delta_x(idx)))
            tf=false;
            return;
        end
    end

end

