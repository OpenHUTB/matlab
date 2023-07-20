function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'cfi',pk.findclass('siggui'));

    p=schema.prop(c,'Filter','mxArray');
    set(p,'AccessFlags.AbortSet','Off');

    schema.prop(c,'Source','ustring');







    p=schema.prop(c,'FastUpdate','on/off');
    set(p,'FactoryValue','off');


