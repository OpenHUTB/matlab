function schema








    mlock;

    schema.package('hdlfilter');

    if isempty(findtype('filterdesignarith')),
        schema.EnumType('filterdesignarith',{'double','single','fixed'});
    end

    if isempty(findtype('rmodetype')),
        schema.EnumType('rmodetype',{'floor','convergent','ceil','fix','nearest','round'});
    end

    if isempty(findtype('hdlimplementations')),
        schema.EnumType('hdlimplementations',{'parallel','serial','serialcascade',...
        'distributedarithmetic','localmultirate'});
    end