function schema





    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'upperlowervector',pk.findclass('freqvector'));

    p=schema.prop(c,'MagnitudeVector','ustring');
    set(p,'FactoryValue','[0 1 0]','Description','spec');

    p=schema.prop(c,'UpperVector','ustring');
    set(p,'FactoryValue','[.1 1.02 .1]','Description','spec');

    p=schema.prop(c,'LowerVector','ustring');
    set(p,'FactoryValue','[-.1 .98 -.1]','Description','spec');


