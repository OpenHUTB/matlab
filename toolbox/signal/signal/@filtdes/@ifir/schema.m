function schema





    pk=findpackage('filtdes');

    c=schema.class(pk,'ifir',pk.findclass('abstractNoOrderMethod'));

    p=schema.prop(c,'InterpolationFactor','double');
    set(p,'FactoryValue',5);

    if isempty(findtype('ifirOptimization'))
        schema.EnumType('ifirOptimization',{'Simple','Intermediate','Advanced'});
    end

    p=schema.prop(c,'Optimization','ifirOptimization');
    set(p,'FactoryValue','Intermediate');


