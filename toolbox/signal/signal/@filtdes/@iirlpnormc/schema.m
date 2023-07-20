function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'iirlpnormc',findclass(pk,'iirlpnorm'));


    if isempty(findtype('unitRadius'))
        schema.UserType('unitRadius','udouble',@check_unitRadius);
    end
    p=schema.prop(c,'maxRadius','unitRadius');
    p.FactoryValue=0.95;


    function check_unitRadius(value)

        if value>=1
            error(message('signal:filtdes:iirlpnormc:schema:InvalidRange'));
        end


