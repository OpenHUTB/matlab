function schema






    pk=findpackage('siggui');


    c=schema.class(pk,'abstractoptionsframe',pk.findclass('sigcontainer'));
    set(c,'Description','abstract');



    p=schema.prop(c,'Name','ustring');
    set(p,'FactoryValue','Options');


