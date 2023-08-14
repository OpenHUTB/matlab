function varsDecoded=decodePerVars(vars)





































    if isempty(vars)
        varsDecoded=[];
        return;
    end

    fields=fieldnames(vars);
    varsDecoded=[];
    for i=1:length(fields)
        varsDecoded.(fields{i})=locDecodePerVar(fields{i},vars.(fields{i}));
    end
end


function varValue=locDecodePerVar(varName,varStruct)




















    isComplex=strcmp(varStruct.Complexity,'true');


    numDims=str2double(varStruct.NumDimensions);
    if(numDims==1)
        varSize=[str2double(varStruct.Size{1}),1];
    else
        varSize=zeros(1,numDims);
        for i=1:numDims
            varSize(i)=str2double(varStruct.Size{i});
        end
    end



    tmp=zeros(varSize);
    tmp=tmp(:);
    if isComplex
        for i=1:length(varStruct.Value)

            cmdStr=['complex',varStruct.Value{i}];
            tmp(i)=eval(cmdStr);
        end
    else
        for i=1:length(varStruct.Value)
            tmp(i)=str2double(varStruct.Value{i});
            if isnan(tmp(i))&&strcmp(varStruct.DataType,'8')
                tmp(i)=strcmp(varStruct.Value{i},'true');
            end
        end
    end


    switch varStruct.DataType
    case slrealtime.internal.PerVarDataType_E.SS_DOUBLE_E.int2char()
        tmp=double(tmp);
    case slrealtime.internal.PerVarDataType_E.SS_SINGLE_E.int2char()
        tmp=single(tmp);
    case slrealtime.internal.PerVarDataType_E.SS_INT8_E.int2char()
        tmp=int8(tmp);
    case slrealtime.internal.PerVarDataType_E.SS_UINT8_E.int2char()
        tmp=uint8(tmp);
    case slrealtime.internal.PerVarDataType_E.SS_INT16_E.int2char()
        tmp=int16(tmp);
    case slrealtime.internal.PerVarDataType_E.SS_UINT16_E.int2char()
        tmp=uint16(tmp);
    case slrealtime.internal.PerVarDataType_E.SS_INT32_E.int2char()
        tmp=int32(tmp);
    case slrealtime.internal.PerVarDataType_E.SS_UINT32_E.int2char()
        tmp=uint32(tmp);
    case slrealtime.internal.PerVarDataType_E.SS_BOOLEAN_E.int2char()
        tmp=logical(tmp);
    case slrealtime.internal.PerVarDataType_E.INT64_E.int2char()
        tmp=int64(tmp);
    case slrealtime.internal.PerVarDataType_E.UINT64_E.int2char()
        tmp=uint64(tmp);
    otherwise
        slrealtime.internal.throw.Warning('slrealtime:persistentVar:unsupportedDataTypeWarn',varName);
        tmp=double(tmp);
    end


    varValue=reshape(tmp,varSize);
end