



function supported=isSupportedEnumClass(typeName)


    if nargin>0
        typeName=convertStringsToChars(typeName);
    end

    supported=Simulink.data.isSupportedEnumClass(typeName)...
    &&slci.compatibility.isIntEnumType(typeName)...
    &&isZeroDefaultValue(typeName);
end

function defIsZero=isZeroDefaultValue(typeName)
    defEnumVal=Simulink.data.getEnumTypeInfo(typeName,'DefaultValue');
    defIsZero=(defEnumVal==0);
end
