function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'firceqripoptsframe',pk.findclass('abstractoptionsframe'));


    p=schema.prop(c,'isMinPhase','on/off');


    p=schema.prop(c,'StopbandSlope','ustring');
    p.FactoryValue='0';


