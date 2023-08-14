function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'freqiirnotchwfnotch',pk.findclass('freqiirnotch'));

    p=schema.prop(c,'Fnotch','ustring');
    set(p,'Description','spec','FactoryValue','9600');


