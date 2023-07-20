function delta_i=computeDeltaX(FiniteDifferenceType,xk,idx,FiniteDifferenceStepSize,TypicalX)































%#codegen

    coder.allowpcode('plain');


    validateattributes(FiniteDifferenceType,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(idx,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(FiniteDifferenceStepSize,{'double'},{'vector'});
    validateattributes(TypicalX,{'double'},{'vector'});


    coder.internal.prefer_const(FiniteDifferenceType);

    FORWARD=coder.const(optim.coder.utils.FiniteDifferences.Constants.FiniteDifferenceType('FORWARD'));

    switch(FiniteDifferenceType)
    case FORWARD
        delta_i=optim.coder.utils.FiniteDifferences.internal.ForwardStepSize(xk,idx,FiniteDifferenceStepSize,TypicalX);

    otherwise
        delta_i=optim.coder.utils.FiniteDifferences.internal.CentralStepSize(xk,idx,FiniteDifferenceStepSize,TypicalX);
    end

end

