function schema





    pk=findpackage('siglayout');
    c=schema.class(pk,'abstractlayout');
    set(c,'Description','abstract');

    p=schema.prop(c,'Panel','mxArray');
    set(p,'SetFunction',@set_panel,'AccessFlags.PublicSet','Off');

    p=schema.prop(c,'OldPosition','double_vector');
    set(p,'Visible','Off');

    p=schema.prop(c,'Invalid','bool');
    set(p,'Visible','Off');

    p=schema.prop(c,'Panel_Listeners','mxArray');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


