function setMemBlkEnumIC(memBlkH,enumType)
    idx=Simulink.IntEnumType.getIndexOfDefaultValue(enumType);
    c=meta.class.fromName(enumType);
    enumDefault=c.EnumerationMemberList(idx).Name;
    if strcmp(get_param(memBlkH,'BlockType'),'UnitDelay')
        set_param(memBlkH,'InitialCondition',sprintf('%s.%s',enumType,enumDefault));
    else
        set_param(memBlkH,'X0',sprintf('%s.%s',enumType,enumDefault));
    end
end