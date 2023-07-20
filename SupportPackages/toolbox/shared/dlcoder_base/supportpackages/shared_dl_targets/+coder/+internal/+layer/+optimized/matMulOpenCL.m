function Z=matMulOpenCL(X,Y,varargin)













































%#codegen
%#internal



    coder.allowpcode("plain");
    coder.inline("always");

    parms={
"NumSimdOutputHeightTilesPerWorkItem"
"NumSimdOutputWidthTilesPerWorkItem"
"SimdLength"
"WarpOutputHeightTileSize"
"WarpOutputWidthTileSize"
"WorkGroupOutputHeightTileSize"
"InnerDimTileSize"
"WorkGroupOutputWidthTileSize"
"LocalMemoryPaddingA"
"LocalMemoryPaddingB"
"UsePrefetching"
    };
    pstruct=coder.internal.parseParameterInputs(parms,[],varargin{:});

    numSimdOutputHeightTilesPerWorkItem=coder.const(coder.internal.getParameterValue(...
    pstruct.NumSimdOutputHeightTilesPerWorkItem,[],varargin{:}));
    numSimdOutputWidthTilesPerWorkItem=coder.const(coder.internal.getParameterValue(...
    pstruct.NumSimdOutputWidthTilesPerWorkItem,[],varargin{:}));
    simdLength=coder.const(coder.internal.getParameterValue(...
    pstruct.SimdLength,[],varargin{:}));
    warpOutputHeightTileSize=coder.const(coder.internal.getParameterValue(...
    pstruct.WarpOutputHeightTileSize,[],varargin{:}));
    warpOutputWidthTileSize=coder.const(coder.internal.getParameterValue(...
    pstruct.WarpOutputWidthTileSize,[],varargin{:}));
    workGroupOutputHeightTileSize=coder.internal.getParameterValue(...
    pstruct.WorkGroupOutputHeightTileSize,[],varargin{:});
    innerDimTileSize=coder.internal.getParameterValue(...
    pstruct.InnerDimTileSize,[],varargin{:});
    workGroupOutputWidthTileSize=coder.internal.getParameterValue(...
    pstruct.WorkGroupOutputWidthTileSize,[],varargin{:});
    localMemoryPaddingA=coder.const(coder.internal.getParameterValue(...
    pstruct.LocalMemoryPaddingA,0,varargin{:}));
    localMemoryPaddingB=coder.const(coder.internal.getParameterValue(...
    pstruct.LocalMemoryPaddingB,0,varargin{:}));
    usePrefetching=coder.const(coder.internal.getParameterValue(...
    pstruct.UsePrefetching,0,varargin{:}));

    checkValidAttributes(numSimdOutputHeightTilesPerWorkItem,"numSimdOutputHeightTilesPerWorkItem",CheckPositive=true);
    checkValidAttributes(numSimdOutputWidthTilesPerWorkItem,"numSimdOutputWidthTilesPerWorkItem",CheckPositive=true);
    checkValidAttributes(simdLength,"simdLength",CheckPositive=true);
    checkValidAttributes(warpOutputHeightTileSize,"warpOutputHeightTileSize",CheckPositive=true);
    checkValidAttributes(warpOutputWidthTileSize,"warpOutputWidthTileSize",CheckPositive=true);
    checkValidAttributes(workGroupOutputHeightTileSize,"workGroupOutputHeightTileSize",CheckPositive=true);
    checkValidAttributes(innerDimTileSize,"innerDimTileSize",CheckPositive=true);
    checkValidAttributes(workGroupOutputWidthTileSize,"workGroupOutputWidthTileSize",CheckPositive=true);
    checkValidAttributes(localMemoryPaddingA,"localMemoryPaddingA");
    checkValidAttributes(localMemoryPaddingB,"localMemoryPaddingB");
    checkValidAttributes(usePrefetching,"usePrefetching",CheckLogical=true);

    if coder.const(simdLength~=1&&simdLength~=2&&simdLength~=4)
        coder.internal.assert(false,"Coder:builtins:Explicit","For OpenCL code generation, SIMD length parameter must be 1, 2 or 4");
    end

    if coder.const(~iIsFactor(simdLength,localMemoryPaddingA))
        coder.internal.assert(false,"Coder:builtins:Explicit","localMemoryPaddingA must be a multiple of simdLength");
    end

    if coder.const(~iIsFactor(simdLength,localMemoryPaddingB))
        coder.internal.assert(false,"Coder:builtins:Explicit","localMemoryPaddingB must be a multiple of simdLength");
    end

    workItemOutputHeightTileSize=coder.const(numSimdOutputHeightTilesPerWorkItem*simdLength);
    if coder.const(~iIsFactor(workItemOutputHeightTileSize,warpOutputHeightTileSize))
        coder.internal.assert(false,"Coder:builtins:Explicit","warpOutputHeightTileSize must be a multiple of workItemOutputHeightTileSize (numSimdOutputHeightTilesPerWorkItem * simdLength)");
    end

    workItemOutputWidthTileSize=coder.const(numSimdOutputWidthTilesPerWorkItem*simdLength);
    if coder.const(~iIsFactor(workItemOutputWidthTileSize,warpOutputWidthTileSize))
        coder.internal.assert(false,"Coder:builtins:Explicit","warpOutputWidthTileSize must be a multiple of workItemOutputWidthTileSize (numSimdOutputWidthTilesPerWorkItem * simdLength)");
    end

    if coder.const(~iIsFactor(warpOutputHeightTileSize,workGroupOutputHeightTileSize))
        coder.internal.assert(false,"Coder:builtins:Explicit","workGroupOutputHeightTileSize must be a multiple of warpOutputHeightTileSize");
    end

    if coder.const(~iIsFactor(warpOutputWidthTileSize,workGroupOutputWidthTileSize))
        coder.internal.assert(false,"Coder:builtins:Explicit","workGroupOutputWidthTileSize must be a multiple of warpOutputWidthTileSize");
    end

    if coder.const(workGroupOutputHeightTileSize/workItemOutputHeightTileSize~=workGroupOutputWidthTileSize/workItemOutputWidthTileSize)
        coder.internal.assert(false,"Coder:builtins:Explicit","(workGroupOutputHeightTileSize / workItemOutputHeightTileSize) must be equal to (workGroupOutputWidthTileSize / workItemOutputWidthTileSize)");
    end

    if coder.const(workGroupOutputHeightTileSize/workItemOutputHeightTileSize~=innerDimTileSize)
        coder.internal.assert(false,"Coder:builtins:Explicit","(workGroupOutputHeightTileSize / workItemOutputHeightTileSize) must be equal to innerDimTileSize");
    end

    coder.internal.assert(size(X,2)==size(Y,1),"MATLAB:innerdim");

    M=toInt(size(X,1));
    N=toInt(size(Y,2));
    K=toInt(size(X,2));

    Z=coder.nullcopy(zeros(M,N,'like',X));

    if coder.const(coder.isRowMajor)




        coder.ceval("-layout:any","#__matmul_opencl_anchor",...
        N,M,K,...
        coder.rref(Y),coder.rref(X),coder.ref(Z),...
        coder.const(numSimdOutputWidthTilesPerWorkItem),...
        coder.const(numSimdOutputHeightTilesPerWorkItem),...
        coder.const(simdLength),...
        coder.const(warpOutputWidthTileSize),...
        coder.const(warpOutputHeightTileSize),...
        coder.const(workGroupOutputWidthTileSize),...
        coder.const(innerDimTileSize),...
        coder.const(workGroupOutputHeightTileSize),...
        coder.const(localMemoryPaddingA),...
        coder.const(localMemoryPaddingB),...
        coder.const(usePrefetching)...
        );
    else
        coder.ceval("-layout:any","#__matmul_opencl_anchor",...
        M,N,K,...
        coder.rref(X),coder.rref(Y),coder.ref(Z),...
        coder.const(numSimdOutputHeightTilesPerWorkItem),...
        coder.const(numSimdOutputWidthTilesPerWorkItem),...
        coder.const(simdLength),...
        coder.const(warpOutputHeightTileSize),...
        coder.const(warpOutputWidthTileSize),...
        coder.const(workGroupOutputHeightTileSize),...
        coder.const(innerDimTileSize),...
        coder.const(workGroupOutputWidthTileSize),...
        coder.const(localMemoryPaddingA),...
        coder.const(localMemoryPaddingB),...
        coder.const(usePrefetching)...
        );
    end


end

function v=toInt(x)
    v=coder.internal.indexInt(x);
end

function checkValidAttributes(x,param,varargin)
    coder.internal.prefer_const(x,param)

    params=struct('CheckPositive',false,...
    'CheckLogical',false);

    pstruct=coder.internal.parseParameterInputs(params,[],varargin{:});

    checkPositive=coder.internal.getParameterValue(pstruct.CheckPositive,[],varargin{:});
    checkLogical=coder.internal.getParameterValue(pstruct.CheckLogical,[],varargin{:});

    coder.inline("always");
    coder.internal.assert(~isempty(x),"Coder:builtins:Explicit",...
    "unspecified parameter: "+param);

    if checkPositive
        coder.internal.assert(coder.const(x>0),"Coder:builtins:Explicit",...
        param+" Must be positive");
    end

    if checkLogical
        coder.internal.assert(islogical(x),"Coder:builtins:Explicit",...
        param+" Must be logical type");
    end

end

function tf=iIsFactor(a,b)
    coder.internal.prefer_const(a,b);
    coder.inline('always');
    tf=coder.const(mod(b,a)==0);
end
