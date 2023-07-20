















function result=isSimulinkBasicType(typeString)
    if nargin>0
        typeString=convertStringsToChars(typeString);
    end

    baseTypes={...
    'double',...
    'single',...
    'int8',...
    'uint8',...
    'int16',...
    'uint16',...
    'int32',...
    'uint32',...
    'boolean'};
    if any(strcmp(baseTypes,typeString))
        result=true;
    else
        result=false;
    end
end

