function delta_i=CentralStepSize(xk,idx,FiniteDifferenceStepSize,TypicalX)










%#codegen

    coder.allowpcode('plain');


    validateattributes(idx,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(FiniteDifferenceStepSize,{'double'},{'vector'});
    validateattributes(TypicalX,{'double'},{'vector'});

    delta_i=FiniteDifferenceStepSize(idx)*max(abs(xk(idx)),abs(TypicalX(idx)));
end
