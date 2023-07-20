function schema





    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'hpmagul',pk.findclass('abstractmagul'));

    p=schema.prop(c,'DstopUpper','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'DstopLower','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'DpassUpper','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'DpassLower','ustring');
    set(p,'FactoryValue','.1','Description','spec');


