function[simdIntrinsic,simdType]=getSimdIntrinsicAndType(targetSimdFcn,simdApi)

    if isempty(targetSimdFcn.Operation)||isempty(targetSimdFcn.Operation.Name)
        error([targetSimdFcn.Name...
        ,'does not corresponding to an valid operation']);
    end

    simdIntrinsic=RTW.SimdServiceHelper.internal.getSimdIntrinsicFromString(targetSimdFcn.Operation.Name);

    if isempty(simdIntrinsic)
        error([targetSimdFcn.Name,'for operation',targetSimdFcn.Operation.Name...
        ,'does not corresponding to an valid simd intrinsic']);
    end


    if~isempty(targetSimdFcn.ReturnType)
        returnTypeString=targetSimdFcn.ReturnType;
    else
        returnTypeString='';
    end


    numInputs=length(targetSimdFcn.Inputs);
    if numInputs>0
        inputTypeStrings=repmat({''},numInputs,1);%#ok<USENS> 
        for i=1:numInputs
            inputTypeStrings{i}=loc_getInputTypeString(targetSimdFcn,i);
        end
    else
        inputTypeStrings={};
    end

    simdType=loc_extractTgtSimdType(simdIntrinsic,...
    returnTypeString,...
    inputTypeStrings,...
    simdApi);
end

function typeString=loc_getInputTypeString(targetSimdFcn,idx)
    aInput=targetSimdFcn.Inputs(idx);

    typeString='';
    if~isempty(aInput.Type)
        typeString=aInput.Type;
    end
end


function tgtSimdType=loc_extractTgtSimdType(simdIntrinsic,returnTypeString,inputTypeStrings,simdApi)



    if strcmp(simdIntrinsic,'vstore')

        num=length(inputTypeStrings);
        for i=1:num
            tgtSimdType=RTW.SimdServiceHelper.internal.getPackedTypeForApi(inputTypeStrings{i},simdApi);
            if~isempty(tgtSimdType)
                break;
            end
        end
    else
        tgtSimdType=RTW.SimdServiceHelper.internal.getPackedTypeForApi(returnTypeString,simdApi);
    end

    assert(~isempty(tgtSimdType));
end

