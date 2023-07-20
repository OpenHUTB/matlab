function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'remez',findclass(pk,'dynamicMinOrdMethod'));


    p=schema.prop(c,'DensityFactor','spt_uint32');
    set(p,'SetFunction',@setdensityfactor,'FactoryValue',16);


    function df=setdensityfactor(h,df)

        if df<16
            error(message('signal:filtdes:remez:schema:InvalidDensityFactor'));
        end


