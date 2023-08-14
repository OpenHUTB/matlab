


function isIntEnum=isIntEnumType(typeName)

    if nargin>0
        typeName=convertStringsToChars(typeName);
    end

    assert(Simulink.data.isSupportedEnumClass(typeName));
    mclass=meta.class.fromName(typeName);
    assert(isa(mclass,'meta.class'));
    assert(numel(mclass.SuperclassList)>0);
    isIntEnum=strcmpi(mclass.SuperclassList(1).Name,'Simulink.IntEnumType');

end
