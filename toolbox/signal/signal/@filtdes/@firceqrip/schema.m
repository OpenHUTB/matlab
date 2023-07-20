function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'firceqrip',findclass(pk,'abstractSingleOrderMethod'));


    p=schema.prop(c,'stopbandSlope','udouble');
    p.FactoryValue=0;

    p=schema.prop(c,'minPhase','on/off');
    p.FactoryValue='off';

