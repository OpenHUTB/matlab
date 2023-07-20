function obj=factoryConstruct(MaxDims)


























%#codegen

    coder.allowpcode('plain');

    validateattributes(MaxDims,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(MaxDims);

    obj=struct();

    BLOCK_SIZE=coder.const(optim.coder.DynamicRegCholManager.Constants('BlockSizeL3BLAS'));


    obj.FMat=coder.nullcopy(realmax*ones(MaxDims*MaxDims,1,'double'));
    obj.ldm=coder.internal.indexInt(MaxDims);
    obj.ndims=coder.internal.indexInt(0);
    obj.info=coder.internal.lapack.info_t;
    obj.scaleFactor=1.0;
    obj.ConvexCheck=true;


    obj.regTol_=0.0;


    obj.workspace_=coder.nullcopy(realmax*ones(BLOCK_SIZE*MaxDims,1,'double'));




    obj.workspace2_=coder.nullcopy(realmax*ones(BLOCK_SIZE*MaxDims,1,'double'));









end

