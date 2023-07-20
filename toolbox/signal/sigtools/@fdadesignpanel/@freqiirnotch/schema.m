function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'freqiirnotch',pk.findclass('abstractfreqwbw'));

    p=schema.prop(c,'Q','ustring');
    set(p,'Description','spec','FactoryValue','45');


