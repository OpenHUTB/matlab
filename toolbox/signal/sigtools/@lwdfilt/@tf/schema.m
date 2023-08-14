function schema





    pk=findpackage('lwdfilt');
    c=schema.class(pk,'tf');

    p=schema.prop(c,'Numerator','mxArray');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'Denominator','mxArray');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'refnum','mxArray');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'refden','mxArray');
    set(p,'FactoryValue',1);


