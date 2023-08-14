function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'magnyquist',findclass(pk,'abstractfiltertype'));


    p=schema.prop(c,'DesignType','magnyquistDesignType');
    p.Description='spec';


