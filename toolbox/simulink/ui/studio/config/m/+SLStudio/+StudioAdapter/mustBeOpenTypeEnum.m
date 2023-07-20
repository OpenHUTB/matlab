function mustBeOpenTypeEnum(openTypeStr)
    if isempty(openTypeStr)
        return
    end
    validEnumValues={'REUSE_TAB','NEW_TAB','NEW_WINDOW'};

    SLStudio.StudioAdapter.mustBeString(openTypeStr,'OpenType is not a string');

    if~any(find(strcmp(validEnumValues,openTypeStr)))
        error([openTypeStr,' type is not a valid OpenType enumeration value']);
    end
end