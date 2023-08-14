function hEntry=createSimdEntryFromTgtFcn(targetSimdFcn,simdApi)

    [intrinsic,tgtPackedDataType]=RTW.SimdServiceHelper.internal.getSimdIntrinsicAndType(targetSimdFcn,simdApi);

    implFcnName=targetSimdFcn.Name;
    includeFiles=targetSimdFcn.Includes;
    additionalIncludeFiles=targetSimdFcn.SystemIncludes;

    hEntry=[];
    switch intrinsic
    case{'vceil','vfloor','vsqrt'}
        hEntry=loc_createUnaryOpEntry(intrinsic,implFcnName,tgtPackedDataType,targetSimdFcn.ReturnType,targetSimdFcn.Inputs);
    case{'vadd','vsub','vmul','vdiv','vmax','vmin'}
        hEntry=loc_createBinaryOpEntry(intrinsic,implFcnName,tgtPackedDataType,targetSimdFcn.ReturnType,targetSimdFcn.Inputs);
    case{'vmac','vmas'}
        hEntry=loc_createTernaryOpEntry(intrinsic,implFcnName,tgtPackedDataType,targetSimdFcn.ReturnType,targetSimdFcn.Inputs);
    case 'vload'
        hEntry=loc_createLoadEntry(intrinsic,implFcnName,tgtPackedDataType,targetSimdFcn.ReturnType,targetSimdFcn.Inputs);
    case 'vstore'
        hEntry=loc_createStoreEntry(intrinsic,implFcnName,tgtPackedDataType,targetSimdFcn.ReturnType,targetSimdFcn.Inputs);
    case 'vbroadcast'
        hEntry=loc_createBroadcastEntry(intrinsic,implFcnName,tgtPackedDataType,targetSimdFcn.ReturnType,targetSimdFcn.Inputs);
    otherwise
        error([intrinsic,'is not a supported simd intrinsic']);
    end


    if~isempty(hEntry)

        [ovMode,rndModes,nonFiniteMode]=RTW.SimdServiceHelper.internal.getMathModesAndNonFinite(targetSimdFcn);
        hEntry.setTflCFunctionEntryParameters('SaturationMode',ovMode,...
        'RoundingModes',rndModes,...
        'NonFiniteSupportMode',nonFiniteMode);


        if~isempty(includeFiles)
            assert(length(includeFiles)==1,...
            'There should be only one implementation header');
            hEntry.setTflCFunctionEntryParameters('ImplementationHeaderFile',includeFiles{1});
        end
        if~isempty(additionalIncludeFiles)
            hEntry.setTflCFunctionEntryParameters('AdditionalHeaderFiles',additionalIncludeFiles);
        end
    end
end

function hEntry=loc_createUnaryOpEntry(intrinsic,implFcnName,tgtPackedDataType,returnTypeString,inputs)
    assert(strcmp(returnTypeString,tgtPackedDataType.TypeName),'Return type of unary simd operation must be simdType');
    assert(strcmp(inputs(1).Type,tgtPackedDataType.TypeName),'Input type of unary simd operation must be simdType');

    simdType=RTW.SimdServiceHelper.internal.createEmbeddedSimdType(tgtPackedDataType);
    hEntry=RTW.SimdHelper.createUnaryEntry(intrinsic,implFcnName,simdType);
end

function hEntry=loc_createBinaryOpEntry(intrinsic,implFcnName,tgtPackedDataType,returnTypeString,inputs)
    assert(strcmp(returnTypeString,tgtPackedDataType.TypeName),'Return type of binary simd operation must be simdType');
    assert(strcmp(inputs(1).Type,tgtPackedDataType.TypeName)&&strcmp(inputs(2).Type,tgtPackedDataType.TypeName),'Input type of binary simd operation must be simdType');

    simdType=RTW.SimdServiceHelper.internal.createEmbeddedSimdType(tgtPackedDataType);
    hEntry=RTW.SimdHelper.createBinopEntry(intrinsic,implFcnName,simdType);
end

function hEntry=loc_createTernaryOpEntry(intrinsic,implFcnName,tgtPackedDataType,returnTypeString,inputs)
    assert(strcmp(returnTypeString,tgtPackedDataType.TypeName),'Return type of ternary simd operation must be simdType');
    assert(strcmp(inputs(1).Type,tgtPackedDataType.TypeName)&&...
    strcmp(inputs(2).Type,tgtPackedDataType.TypeName)&&...
    strcmp(inputs(3).Type,tgtPackedDataType.TypeName),'Input type of binary simd operation must be simdType');

    simdType=RTW.SimdServiceHelper.internal.createEmbeddedSimdType(tgtPackedDataType);
    hEntry=RTW.SimdHelper.createTernaryopEntry(intrinsic,implFcnName,simdType);
end

function hEntry=loc_createLoadEntry(intrinsic,implFcnName,tgtPackedDataType,returnTypeString,inputs)
    assert(strcmp(returnTypeString,tgtPackedDataType.TypeName),'Return type of load simd operation must be simdType');
    assert(strcmp(inputs(1).Type(end),'*'),'Input type of load simd operation must be a pointer type');
    inputBaseTypeString=RTW.SimdServiceHelper.internal.getBaseTypeStringNoQualifier(inputs(1).Type);

    simdType=RTW.SimdServiceHelper.internal.createEmbeddedSimdType(tgtPackedDataType);
    if strcmp(inputBaseTypeString,tgtPackedDataType.BaseDataTypeName)
        hEntry=RTW.SimdHelper.createLoadEntry(intrinsic,...
        implFcnName,...
        simdType,...
        false);
    elseif strcmp(inputBaseTypeString,tgtPackedDataType.TypeName)
        hEntry=RTW.SimdHelper.createLoadEntry(intrinsic,...
        implFcnName,...
        simdType,...
        true);
    else
        error('Input type of load simd operation must be a pointer type to simdType or its baseType')
    end
    simdType=RTW.SimdServiceHelper.internal.createEmbeddedSimdType(tgtPackedDataType);
    hEntry=RTW.SimdHelper.createLoadEntry(intrinsic,implFcnName,simdType);
end


function hEntry=loc_createStoreEntry(intrinsic,implFcnName,tgtPackedDataType,~,inputs)

    assert(strcmp(inputs(1).Type(end),'*'),'First input type of store simd operation must be a pointer type');

    secondInputBaseTypeString=RTW.SimdServiceHelper.internal.getBaseTypeStringNoQualifier(inputs(2).Type);
    assert(strcmp(secondInputBaseTypeString,tgtPackedDataType.TypeName),'Second input type of store simd operation must be simd type');

    firstInputBaseTypeString=RTW.SimdServiceHelper.internal.getBaseTypeStringNoQualifier(inputs(1).Type);
    simdType=RTW.SimdServiceHelper.internal.createEmbeddedSimdType(tgtPackedDataType);
    if strcmp(firstInputBaseTypeString,tgtPackedDataType.BaseDataTypeName)
        hEntry=RTW.SimdHelper.createStoreEntry(intrinsic,...
        implFcnName,...
        simdType,...
        false);
    elseif strcmp(firstInputBaseTypeString,tgtPackedDataType.TypeName)
        hEntry=RTW.SimdHelper.createStoreEntry(intrinsic,...
        implFcnName,...
        simdType,...
        true);
    else
        error('Input type of load simd operation must be a pointer type to simdType or its baseType')
    end
end

function hEntry=loc_createBroadcastEntry(intrinsic,implFcnName,tgtPackedDataType,returnTypeString,inputs)
    assert(strcmp(returnTypeString,tgtPackedDataType.TypeName),'Return type of broadcast simd operation must be simdType');
    assert(~strcmp(inputs(1).Type(end),'*'),'Input type of broad simd operation must NOT be a pointer type');

    inputBaseTypeString=RTW.SimdServiceHelper.internal.getBaseTypeStringNoQualifier(inputs(1).Type);
    assert(strcmp(inputBaseTypeString,tgtPackedDataType.BaseDataTypeName),...
    'Input type of broad simd operation must corespond to baseType of simdtype')

    simdType=RTW.SimdServiceHelper.internal.createEmbeddedSimdType(tgtPackedDataType);
    hEntry=RTW.SimdHelper.createBroadcastEntry(intrinsic,implFcnName,simdType);
end