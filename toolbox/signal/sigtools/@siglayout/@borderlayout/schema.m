function schema





    pk=findpackage('siglayout');
    c=schema.class(pk,'borderlayout',pk.findclass('abstractlayout'));

    p=schema.prop(c,'North','mxArray');
    set(p,'SetFunction',{@set_child,'north'});

    p=schema.prop(c,'South','mxArray');
    set(p,'SetFunction',{@set_child,'south'});

    p=schema.prop(c,'West','mxArray');
    set(p,'SetFunction',{@set_child,'west'});

    p=schema.prop(c,'East','mxArray');
    set(p,'SetFunction',{@set_child,'east'});

    p=schema.prop(c,'Center','mxArray');
    set(p,'SetFunction',{@set_child,'center'});

    schema.prop(c,'HorizontalGap','spt_uint32');
    schema.prop(c,'VerticalGap','spt_uint32');

    p=schema.prop(c,'ChildrenListeners','mxArray');
    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');

    p=schema.prop(c,'UpdateListener','handle.listener vector');
    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');


