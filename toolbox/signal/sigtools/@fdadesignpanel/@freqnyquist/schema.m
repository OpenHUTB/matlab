function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqnyquist',findclass(pk,'freqwtransition'));


    p=schema.prop(c,'Band','ustring');
    p.FactoryValue='4';
    p.Description='spec';


