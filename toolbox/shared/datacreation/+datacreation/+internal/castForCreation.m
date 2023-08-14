function castedDataVals=castForCreation(dataValsToCast,dataTypeString,varargin)




    builtinDataTypeStrings=datacreation.internal.DataTypeHelper.getDataTypeStrings;

    if isa(dataTypeString,'embedded.numerictype')||~any(strcmp(builtinDataTypeStrings,...
        dataTypeString))

        if isa(dataTypeString,'embedded.numerictype')
            error(message('datacreation:datacreation:dataTypeNotSupported',dataTypeString.tostring));
        else
            error(message('datacreation:datacreation:dataTypeNotSupported',dataTypeString));
        end
    end

    try
        castH=str2func(dataTypeString);
        castedDataVals=castH(dataValsToCast);
    catch ME
        throwAsCaller(ME);
    end
