function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'magrcos',findclass(pk,'abstractfiltertype'));


    p=schema.prop(c,'DesignType','magrcosDesignType');
    p.Description='spec';


