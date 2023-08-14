function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'abstractfilterorder',pk.findclass('sigcontainer'));
    set(c,'Description','abstract');

    p=schema.prop(c,'isMinOrd','bool');
    set(p,'FactoryValue',1,'SetFunction',@setisminord);


    p=schema.prop(c,'order','string');
    set(p,'FactoryValue','10');


    function out=setisminord(h,out)

        if~out
            set(h,'Mode','specify')
        end


