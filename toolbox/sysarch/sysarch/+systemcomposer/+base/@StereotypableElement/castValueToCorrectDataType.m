function value=castValueToCorrectDataType(~,typeImpl,strValue)





    value=strValue;
    switch class(typeImpl)
    case 'systemcomposer.property.FloatType'
        baseTypeName=typeImpl.baseType.getName;
        value=cast(str2num(strValue),baseTypeName);
    case 'systemcomposer.property.IntegerType'
        baseTypeName=typeImpl.baseType.getName;
        value=cast(str2num(strValue),baseTypeName);
    case 'systemcomposer.property.BooleanType'
        value=logical(str2num(strValue));%#ok<ST2NM> 
    case 'systemcomposer.property.StringType'
        if isempty(strValue)
            value='';
        else
            value=eval(strValue);
        end
    case 'systemcomposer.property.Enumeration'
        value=typeImpl.getValueFromString(strrep(strValue,"'",""));
    end
end