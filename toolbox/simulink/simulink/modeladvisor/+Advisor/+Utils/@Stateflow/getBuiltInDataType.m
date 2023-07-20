function dataType=getBuiltInDataType(system,className)
    if strcmp(className,'boolean')||strcmp(className,'logical')...
        ||strcmp(className,'true')||strcmp(className,'false')
        dataType='boolean';
    elseif startsWith(className,'int')||startsWith(className,'uint')||...
        strcmp(className,'double')||strcmp(className,'single')
        dataType=className;
    elseif startsWith(className,'Enum:')
        ens=enumeration(strtrim(className(6:end)));
        if~isempty(ens)
            meta=metaclass(ens(1));
            dataType=getTopLevelSuperClassName(meta);
        end
    elseif startsWith(className,'Bus:')||Advisor.Utils.Simulink.isBusDataTypeStr(system,className)
        dataType=className;
    elseif startsWith(className,'sfix')||startsWith(className,'ufix')
        dataType=className;
    else
        dataType='unknown';
    end
end

function metaName=getTopLevelSuperClassName(metaclass)
    if~isempty(metaclass.SuperclassList)
        metaName=getTopLevelSuperClassName(metaclass.SuperclassList(1));
    else
        metaName=metaclass.Name;
    end
end