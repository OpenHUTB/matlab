function delta_i=ForwardStepSize(xk,idx,FiniteDifferenceStepSize,TypicalX)










%#codegen

    coder.allowpcode('plain');


    validateattributes(idx,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(FiniteDifferenceStepSize,{'double'},{'vector'});
    validateattributes(TypicalX,{'double'},{'vector'});

    signVec=1.0-2*double(xk(idx)<0);
    delta_i=FiniteDifferenceStepSize(idx)*signVec*max(abs(xk(idx)),abs(TypicalX(idx)));

end
