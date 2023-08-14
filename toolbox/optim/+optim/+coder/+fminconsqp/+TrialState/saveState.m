function obj=saveState(obj)












%#codegen

    coder.allowpcode('plain');


    validateattributes(obj,{'struct'},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);


    obj.sqpFval_old=obj.sqpFval;




    nVar=coder.internal.indexInt(numel(obj.xstarsqp));
    obj.xstarsqp_old=coder.internal.blas.xcopy(nVar,obj.xstarsqp,INT_ONE,INT_ONE,obj.xstarsqp_old,INT_ONE,INT_ONE);







    for i=1:nVar
        obj.grad_old(i)=obj.grad(i);
    end


    obj.cIneq_old=coder.internal.blas.xcopy(obj.mIneq,obj.cIneq,INT_ONE,INT_ONE,obj.cIneq_old,INT_ONE,INT_ONE);


    obj.cEq_old=coder.internal.blas.xcopy(obj.mEq,obj.cEq,INT_ONE,INT_ONE,obj.cEq_old,INT_ONE,INT_ONE);

end

