function schema






    mlock;

    schema.package('hdlgui');

    if isempty(findtype('ResetAssertedLevelType')),
        schema.EnumType('ResetAssertedLevelType',{'Active-high','Active-low'});
    end


