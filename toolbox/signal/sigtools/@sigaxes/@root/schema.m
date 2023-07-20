function schema





    pk=findpackage('sigaxes');
    c=schema.class(pk,'root',findclass(findpackage('siggui'),'siggui'));


    schema.prop(c,'ButtonDownFcn','MATLAB array');
    schema.prop(c,'UIContextMenu','MATLAB array');
    schema.prop(c,'Current','on/off');
    schema.prop(c,'Real','double');
    schema.prop(c,'Imaginary','double');


    p=schema.prop(c,'Conjugate','on/off');
    set(p,'AccessFlags.PublicSet','Off');

    schema.event(c,'NewValue');


