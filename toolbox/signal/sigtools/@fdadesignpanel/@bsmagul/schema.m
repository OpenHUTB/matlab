function schema





    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'bsmagul',pk.findclass('abstractmagul'));

    p=schema.prop(c,'Dpass1Upper','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'Dpass1Lower','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'DstopUpper','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'DstopLower','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'Dpass2Upper','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'Dpass2Lower','ustring');
    set(p,'FactoryValue','.1','Description','spec');


