function schema





    pk=findpackage('siglayout');
    c=schema.class(pk,'gridlayout',pk.findclass('abstractlayout'));

    p=schema.prop(c,'Grid','mxArray');
    set(p,'AccessFlags.PublicSet','Off','FactoryValue',[]);

    schema.prop(c,'HorizontalGap','double');
    schema.prop(c,'VerticalGap','double');

    p=schema.prop(c,'UpdateListener','handle.listener vector');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');

    p=schema.prop(c,'ChildrenListeners','mxArray');
    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');


