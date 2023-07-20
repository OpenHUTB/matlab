function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'numdenfilterorder',pk.findclass('sigcontainer'));



    p=schema.prop(c,'NumOrder','ustring');
    set(p,'Description','Numerator order');


    p=schema.prop(c,'DenOrder','ustring');
    set(p,'Description','Denominator order');


