function validateSimdFunction(targetSimdFcn,simdApi)

    if isempty(targetSimdFcn.Operation)||isempty(targetSimdFcn.Operation.Name)
        error('SIMD function must correspond to a valid simd intrinsic');
    end

    intrinsic=RTW.SimdServiceHelper.internal.getSimdIntrinsicFromString(targetSimdFcn.Operation.Name);
    implFcnName=targetSimdFcn.Name;
    returnType=targetSimdFcn.ReturnType;
    inputs=targetSimdFcn.Inputs;
    includeFiles=targetSimdFcn.Includes;
    additionalIncludeFiles=targetSimdFcn.SystemIncludes;

    switch intrinsic
    case{'vceil','vfloor','vsqrt'}
        loc_validateVectorMathOperation(implFcnName,returnType,inputs,simdApi,1);
    case{'vadd','vsub','vmul','vdiv','vmax','vmin'}
        loc_validateVectorMathOperation(implFcnName,returnType,inputs,simdApi,2);
    case{'vmac','vmas'}
        loc_validateVectorMathOperation(implFcnName,returnType,inputs,simdApi,3);
    case 'vload'
        loc_validateLoadOperation(implFcnName,returnType,inputs,simdApi);
    case 'vstore'
        loc_validateStoreOperation(implFcnName,returnType,inputs,simdApi);
    case 'vbroadcast'
        loc_validateBroadCastOpeartion(implFcnName,returnType,inputs,simdApi);
    otherwise
        error([implFcnName,'does not correspond to a supported simd intrinsic']);
    end

    assert(length(includeFiles)==1,[implFcnName,':expecting one header file for each target simd function']);

end

function loc_validateLoadOperation(implFcnName,returnType,inputs,simdApi)


    tgtPackedType=RTW.SimdServiceHelper.internal.getPackedTypeForApi(returnType,simdApi);
    if isempty(tgtPackedType)
        error([implFcnName,':Return type of the load operation must be a simd type']);
    end

    assert(length(inputs)==1,[implFcnName,':Expecting only one input for load']);
    assert(loc_compatibleType(inputs(1).Type,tgtPackedType),[implFcnName,':input type of the load operation must be compatible pointer type to simd type']);

end

function loc_validateStoreOperation(implFcnName,returnType,inputs,simdApi)


    if~isempty(returnType)&&~strcmp(returnType,'void')
        error([implFcnName,'Expect the return type to be void for store intrinsic'])
    end

    assert(length(inputs)==2,'Expecting two inputs for store');
    tgtSimdType=RTW.SimdServiceHelper.internal.getPackedTypeForApi(inputs(2).Type,simdApi);
    assert(loc_compatibleType(inputs(1).Type,tgtSimdType),[implFcnName,'first input of the store operation must be compatible pointer type to simd type']);
end

function loc_validateBroadCastOpeartion(implFcnName,returnType,inputs,simdApi)

    tgtPackedType=RTW.SimdServiceHelper.internal.getPackedTypeForApi(returnType,simdApi);
    if isempty(tgtPackedType)
        error([implFcnName,':Return type of the broadcast operation must be a simd type']);
    end

    assert(length(inputs)==1,[implFcnName,':Expecting only one input for broadcast']);
    assert(loc_compatibleType(inputs(1).Type,tgtPackedType),[implFcnName,':input of the store operation must be compatible type to simd type']);
end


function loc_validateVectorMathOperation(implFcnName,returnType,inputs,simdApi,expectedNumInputs)




    tgtPackedType=RTW.SimdServiceHelper.internal.getPackedTypeForApi(returnType,simdApi);
    if isempty(tgtPackedType)
        error([implFcnName,':Return type of the simd operation must be a simd type']);
    end

    numInputs=length(inputs);
    assert(length(inputs)==expectedNumInputs,[implFcnName,':Wrong number of inputs for math operation']);
    for i=1:numInputs
        assert(strcmp(inputs(i).Type,returnType),[implFcnName,':input type and return type are inconsistent for operation']);
    end
end

function isCompatible=loc_compatibleType(typeString,tgtPackedType)

    baseTypeString=RTW.SimdServiceHelper.internal.getBaseTypeStringNoQualifier(typeString);
    simdTypeName=tgtPackedType.TypeName;
    simdBaseTypeName=tgtPackedType.BaseDataTypeName;

    if strcmp(baseTypeString,simdTypeName)
        isCompatible=true;
    elseif strcmp(baseTypeString,simdBaseTypeName)
        isCompatible=true;
    else
        isCompatible=false;
    end
end

