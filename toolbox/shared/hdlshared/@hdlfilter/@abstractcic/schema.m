function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractmultirate');
    c=schema.class(pk,'abstractcic',parent);
    set(c,'Description','abstract');

    schema.prop(c,'NumberOfSections','mxArray');

    schema.prop(c,'DifferentialDelay','mxArray');

    schema.prop(c,'RoundMode','rmodetype');

    p=schema.prop(c,'OverflowMode','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'SectionSLtypes','mxArray');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'VarRate','bool');
    set(p,'FactoryValue',false);


