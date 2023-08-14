function varsEncoded=encodePerVars(vars,oldRawVars)















































    if isempty(vars)
        varsEncoded=[];
        return;
    end

    fields=fieldnames(vars);

    if isempty(oldRawVars)
        fieldExists=false(length(fields),1);
    else
        oldFields=fieldnames(oldRawVars);
        fieldExists=ismember(fields,oldFields);
    end

    varsEncoded=[];
    for i=1:length(fields)
        if fieldExists(i)
            varsEncoded.(fields{i})=locEncodePerVar(fields{i},vars.(fields{i}),...
            fieldExists(i),oldRawVars.(fields{i}));
        else
            varsEncoded.(fields{i})=locEncodePerVar(fields{i},vars.(fields{i}));
        end
    end
end


function varStruct=locEncodePerVar(varName,varValue,varExists,oldVarStruct)
























    narginchk(2,4);
    if nargin==2
        varExists=false;
        oldVarStruct=[];
    elseif nargin==3
        assert(false,'locEncodePerVar() should have either 2 or 4 inputs.');
    end

    varStruct.DataType=encodeDataType(varName,class(varValue));
    if~isreal(varValue)
        varStruct.Complexity='true';
    else
        varStruct.Complexity='false';
    end
    varStruct.NumDimensions=num2str(length(size(varValue)));
    varStruct.Size=numVector2charCell(size(varValue));

    if varExists

        skipCheckForDims=false;
        errorForNumDims=false;
        if~strcmp(varStruct.NumDimensions,oldVarStruct.NumDimensions)
            if strcmp(oldVarStruct.NumDimensions,'1')&&strcmp(varStruct.NumDimensions,'2')



                if(strcmp(varStruct.Size{1},'1')&&strcmp(varStruct.Size{2},oldVarStruct.Size{1}))||...
                    (strcmp(varStruct.Size{2},'1')&&strcmp(varStruct.Size{1},oldVarStruct.Size{1}))
                    skipCheckForDims=true;
                    errorForNumDims=false;
                else
                    skipCheckForDims=false;
                    errorForNumDims=true;
                end
            else
                skipCheckForDims=false;
                errorForNumDims=true;
            end

            if errorForNumDims
                oldVarSizeStr='';
                for k=1:length(oldVarStruct.Size)-1
                    oldVarSizeStr=strcat(oldVarSizeStr,oldVarStruct.Size{k},'x');
                end
                oldVarSizeStr=strcat(oldVarSizeStr,oldVarStruct.Size{end});

                varSizeStr='';
                for k=1:length(varStruct.Size)-1
                    varSizeStr=strcat(varSizeStr,varStruct.Size{k},'x');
                end
                varSizeStr=strcat(varSizeStr,varStruct.Size{end});

                slrealtime.internal.throw.Error('slrealtime:persistentVar:dimsMismatch',...
                varName,oldVarSizeStr,varSizeStr);
            end
        end

        if~skipCheckForDims
            if~isequal(varStruct.Size,oldVarStruct.Size)
                oldVarSizeStr='';
                for k=1:length(oldVarStruct.Size)-1
                    oldVarSizeStr=strcat(oldVarSizeStr,oldVarStruct.Size{k},'x');
                end
                oldVarSizeStr=strcat(oldVarSizeStr,oldVarStruct.Size{end});

                varSizeStr='';
                for k=1:length(varStruct.Size)-1
                    varSizeStr=strcat(varSizeStr,varStruct.Size{k},'x');
                end
                varSizeStr=strcat(varSizeStr,varStruct.Size{end});

                slrealtime.internal.throw.Error('slrealtime:persistentVar:dimsMismatch',...
                varName,oldVarSizeStr,varSizeStr);
            end
        end


        if~strcmp(varStruct.DataType,oldVarStruct.DataType)
            varDataTypeStr=class(varValue);
            try
                switch oldVarStruct.DataType
                case slrealtime.internal.PerVarDataType_E.SS_DOUBLE_E.int2char()
                    oldVarDataTypeStr='double';
                    varValue=double(varValue);
                case slrealtime.internal.PerVarDataType_E.SS_SINGLE_E.int2char()
                    oldVarDataTypeStr='single';
                    varValue=single(varValue);
                case slrealtime.internal.PerVarDataType_E.SS_INT8_E.int2char()
                    oldVarDataTypeStr='int8';
                    varValue=int8(varValue);
                case slrealtime.internal.PerVarDataType_E.SS_UINT8_E.int2char()
                    oldVarDataTypeStr='uint8';
                    varValue=uint8(varValue);
                case slrealtime.internal.PerVarDataType_E.SS_INT16_E.int2char()
                    oldVarDataTypeStr='int16';
                    varValue=int16(varValue);
                case slrealtime.internal.PerVarDataType_E.SS_UINT16_E.int2char()
                    oldVarDataTypeStr='uint16';
                    varValue=uint16(varValue);
                case slrealtime.internal.PerVarDataType_E.SS_INT32_E.int2char()
                    oldVarDataTypeStr='int32';
                    varValue=int32(varValue);
                case slrealtime.internal.PerVarDataType_E.SS_UINT32_E.int2char()
                    oldVarDataTypeStr='uint32';
                    varValue=uint32(varValue);
                case slrealtime.internal.PerVarDataType_E.SS_BOOLEAN_E.int2char()
                    oldVarDataTypeStr='logical';
                    varValue=logical(varValue);
                case slrealtime.internal.PerVarDataType_E.INT64_E.int2char()
                    oldVarDataTypeStr='int64';
                    varValue=int64(varValue);
                case slrealtime.internal.PerVarDataType_E.UINT64_E.int2char()
                    oldVarDataTypeStr='uint64';
                    varValue=uint64(varValue);
                otherwise
                    oldVarDataTypeStr=getString(message('slrealtime:persistentVar:unknown'));
                    slrealtime.internal.throw.Error('slrealtime:persistentVar:unsupportedDataTypeErr',varName);
                end
            catch ME
                slrealtime.internal.throw.ErrorWithCause('slrealtime:persistentVar:dataTypeMismatchErr',ME,...
                varName,oldVarDataTypeStr,varDataTypeStr);
            end
            if isnan(varValue)
                slrealtime.internal.throw.Error('slrealtime:persistentVar:dataTypeMismatchErr',...
                varName,oldVarDataTypeStr,varDataTypeStr);
            end

            slrealtime.internal.throw.Warning('slrealtime:persistentVar:dataTypeMismatchWarn',...
            varName,oldVarDataTypeStr,varDataTypeStr);
            varStruct.DataType=encodeDataType(varName,class(varValue));
        end


        if~strcmp(varStruct.Complexity,oldVarStruct.Complexity)
            if strcmp(oldVarStruct.Complexity,'true')
                oldVarComplexityStr=getString(message('slrealtime:persistentVar:complex'));
                varComplexityStr=getString(message('slrealtime:persistentVar:real'));
            else
                oldVarComplexityStr=getString(message('slrealtime:persistentVar:real'));
                varComplexityStr=getString(message('slrealtime:persistentVar:complex'));
            end
            try
                if strcmp(oldVarStruct.Complexity,'true')
                    varValue=complex(varValue);
                    varStruct.Complexity='true';
                else
                    varValue=real(varValue);
                    varStruct.Complexity='false';
                end
            catch ME
                slrealtime.internal.throw.ErrorWithCause('slrealtime:persistentVar:complexityMismatchErr',ME,...
                varName,oldVarComplexityStr,varComplexityStr);
            end

            slrealtime.internal.throw.Warning('slrealtime:persistentVar:complexityMismatchWarn',...
            varName,oldVarComplexityStr,varComplexityStr);
        end
    end

    if strcmp(varStruct.Complexity,'true')
        varStruct.Value=complexVector2charCell(varValue(:));
    else
        varStruct.Value=numVector2charCell(varValue(:));
    end
end

function dtID=encodeDataType(varName,dataType)
    switch dataType
    case 'double'
        dtID=slrealtime.internal.PerVarDataType_E.SS_DOUBLE_E.int2char();
    case 'single'
        dtID=slrealtime.internal.PerVarDataType_E.SS_SINGLE_E.int2char();
    case 'int8'
        dtID=slrealtime.internal.PerVarDataType_E.SS_INT8_E.int2char();
    case 'uint8'
        dtID=slrealtime.internal.PerVarDataType_E.SS_UINT8_E.int2char();
    case 'int16'
        dtID=slrealtime.internal.PerVarDataType_E.SS_INT16_E.int2char();
    case 'uint16'
        dtID=slrealtime.internal.PerVarDataType_E.SS_UINT16_E.int2char();
    case 'int32'
        dtID=slrealtime.internal.PerVarDataType_E.SS_INT32_E.int2char();
    case 'uint32'
        dtID=slrealtime.internal.PerVarDataType_E.SS_UINT32_E.int2char();
    case 'logical'
        dtID=slrealtime.internal.PerVarDataType_E.SS_BOOLEAN_E.int2char();
    case 'int64'
        dtID=slrealtime.internal.PerVarDataType_E.INT64_E.int2char();
    case 'uint64'
        dtID=slrealtime.internal.PerVarDataType_E.UINT64_E.int2char();
    otherwise
        slrealtime.internal.throw.Error('slrealtime:persistentVar:unsupportedDataTypeErr2',...
        varName);
    end
end

function charCell=numVector2charCell(numVector)

    charCell=cell(length(numVector),1);
    for i=1:length(numVector)
        charCell{i}=num2str(numVector(i));
    end
end

function charCell=complexVector2charCell(numVector)

    charCell=cell(length(numVector),1);
    for i=1:length(numVector)
        charCell{i}=['(',num2str(real(numVector(i))),',',num2str(imag(numVector(i))),')'];
    end
end