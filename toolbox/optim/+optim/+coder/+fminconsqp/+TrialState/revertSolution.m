function obj=revertSolution(obj)












%#codegen

    coder.allowpcode('plain');


    validateattributes(obj,{'struct'},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);


    obj.sqpFval=obj.sqpFval_old;

    nVar=coder.internal.indexInt(numel(obj.xstarsqp));
    obj.xstarsqp=coder.internal.blas.xcopy(nVar,obj.xstarsqp_old,INT_ONE,INT_ONE,obj.xstarsqp,INT_ONE,INT_ONE);


    obj.cIneq=coder.internal.blas.xcopy(obj.mIneq,obj.cIneq_old,INT_ONE,INT_ONE,obj.cIneq,INT_ONE,INT_ONE);


    obj.cEq=coder.internal.blas.xcopy(obj.mEq,obj.cEq_old,INT_ONE,INT_ONE,obj.cEq,INT_ONE,INT_ONE);

end

