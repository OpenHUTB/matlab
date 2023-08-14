function typeCastedValue=getTypeCastValue(origValue,targetDataType)







    switch targetDataType
    case 'boolean'
        typeCastedValue=convertToBoolean(origValue);
    case{'double','single','int16','uint16',...
        'int32','uint32'}
        typeCastedValue=convertToNumeric(origValue,targetDataType);
    case{'string','ustring'}
        typeCastedValue=convertToString(origValue);
    otherwise
        typeCastedValue=origValue;
    end
end

function typeCastedValue=convertToBoolean(origValue)
    switch origValue
    case{'true','1'}
        typeCastedValue=true;
    case{'false','0'}
        typeCastedValue=false;
    otherwise
        typeCastedValue=origValue;
    end
end

function typeCastedValue=convertToNumeric(origValue,targetDataType)
    if ischar(origValue)||isStringScalar(origValue)
        origValue=str2double(origValue);
    end
    typeCastedValue=cast(origValue,targetDataType);
end

function typeCastedValue=convertToString(origValue)
    if islogical(origValue)
        if origValue
            typeCastedValue='1';
        else
            typeCastedValue='0';
        end
    elseif isa(origValue,'double')||isa(origValue,'single')
        typeCastedValue=rtw.connectivity.CodeInfoUtils.double2str(origValue);
    elseif isnumeric(origValue)
        typeCastedValue=int2str(origValue);
    else
        typeCastedValue=origValue;
    end
end

