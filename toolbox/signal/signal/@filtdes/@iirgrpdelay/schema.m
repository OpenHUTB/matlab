function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'iirgrpdelay',findclass(pk,'lpnorm'));



    p=schema.prop(c,'maxRadius','double0t1');
    p.FactoryValue=0.95;



    p=schema.prop(c,'order','spt_uint32');
    p.FactoryValue=8;

    p=schema.prop(c,'initDen','MATLAB array');
    p.FactoryValue=[];
