function schema





    pk=findpackage('sigio');
    c=schema.class(pk,'xp2coeffile',pk.findclass('abstractxpdestination'));

    if isempty(findtype('fcfFileFormat'))
        schema.EnumType('fcfFileFormat',{'Decimal','Hexadecimal','Binary'});
    end

    schema.prop(c,'Format','fcfFileFormat');


