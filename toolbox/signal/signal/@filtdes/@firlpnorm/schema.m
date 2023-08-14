function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'firlpnorm',findclass(pk,'lpnorm'));



    p=schema.prop(c,'minPhase','on/off');
    p.FactoryValue='off';

    p=schema.prop(c,'initNum','MATLAB array');
    p.FactoryValue=[];



    p=schema.prop(c,'order','spt_uint32');
    p.FactoryValue=20;

