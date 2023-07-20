function obj=factoryConstruct(MaxDims)


























%#codegen

    coder.allowpcode('plain');

    validateattributes(MaxDims,{coder.internal.indexIntClass},{'scalar'});
    coder.internal.prefer_const(MaxDims);

    obj=struct();


    obj.FMat=coder.nullcopy(realmax*ones(MaxDims,'double'));
    obj.ldm=coder.internal.indexInt(MaxDims);
    obj.ndims=coder.internal.indexInt(0);
    obj.info=coder.internal.lapack.info_t;
    obj.scaleFactor=0.0;
    obj.ConvexCheck=true;






    obj.regTol_=coder.internal.inf;
    obj.workspace_=coder.internal.inf;
    obj.workspace2_=coder.internal.inf;





end

