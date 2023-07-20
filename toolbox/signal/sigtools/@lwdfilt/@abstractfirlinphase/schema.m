function schema





    pk=findpackage('lwdfilt');
    c=schema.class(pk,'abstractfirlinphase');
    set(c,'Description','abstract');

    p=schema.prop(c,'Numerator','mxArray');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'refnum','mxArray');
    set(p,'FactoryValue',1);


