

function defaultValue=getEnumDefaultValue(enumTag)

    assert(~isempty(enumTag),' Enumeration tag cannot be empty ');
    try
        enumDefault=Simulink.data.getEnumTypeInfo(enumTag,'DefaultValue');
        defaultValue=int32(enumDefault);
    catch
        defaultValue=[];
    end

end
