function schema

    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'bpmagul',pk.findclass('abstractmagul'));
    p=schema.prop(c,'Dstop1Upper','ustring');
    set(p,'FactoryValue','.1','Description','spec');
    p=schema.prop(c,'Dstop1Lower','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'DpassUpper','ustring');
    set(p,'FactoryValue','.1','Description','spec');

    p=schema.prop(c,'DpassLower','ustring');
    set(p,'FactoryValue','.1','Description','spec');
    p=schema.prop(c,'Dstop2Upper','ustring');
    set(p,'FactoryValue','.1','Description','spec');
    p=schema.prop(c,'Dstop2Lower','ustring');
    set(p,'FactoryValue','.1','Description','spec');


