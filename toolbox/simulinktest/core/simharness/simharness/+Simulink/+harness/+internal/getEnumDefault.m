function lhs=getEnumDefault(enumType)

    idx=Simulink.IntEnumType.getIndexOfDefaultValue(enumType);
    c=meta.class.fromName(enumType);
    enumDefault=c.EnumerationMemberList(idx).Name;
    lhs=[enumType,'.',enumDefault];

end
