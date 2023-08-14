function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'lpnorm',findclass(pk,'abstractDesignMethodwFs'));
    c.description='abstract';


    p=schema.prop(c,'Pnorm','evenuint32');
    p.FactoryValue=128;

    p=schema.prop(c,'initPnorm','evenuint32');
    p.FactoryValue=2;

    p=schema.prop(c,'DensityFactor','spt_uint32');
    p.FactoryValue=20;


