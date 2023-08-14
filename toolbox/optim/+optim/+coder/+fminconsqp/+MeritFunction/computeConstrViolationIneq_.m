function normResid=computeConstrViolationIneq_(mIneq,ineq_workspace,ineq0)












%#codegen

    coder.allowpcode('plain');


    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ineq_workspace,{'double'},{'2d'});
    validateattributes(ineq0,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(mIneq,ineq0);



    normResid=0.0;
    for idx=ineq0:ineq0+mIneq-1
        if(ineq_workspace(idx)>0)
            normResid=normResid+ineq_workspace(idx);
        end
    end

end