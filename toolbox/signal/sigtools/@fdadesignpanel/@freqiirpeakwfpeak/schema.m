function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'freqiirpeakwfpeak',pk.findclass('freqiirnotch'));

    p=schema.prop(c,'Fpeak','ustring');
    set(p,'Description','spec','FactoryValue','9600');


