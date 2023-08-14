function schema





    pk=findpackage('lwdfilt');
    c=schema.class(pk,'sos');

    p=schema.prop(c,'sosMatrix','mxArray');
    set(p,'FactoryValue',[1,0,0,1,0,0]);

    p=schema.prop(c,'ScaleValues','mxArray');
    set(p,'FactoryValue',[1,1]');

    p=schema.prop(c,'refsosMatrix','mxArray');
    set(p,'FactoryValue',[1,0,0,1,0,0]);

    p=schema.prop(c,'refScaleValues','mxArray');
    set(p,'FactoryValue',[1,1]');


