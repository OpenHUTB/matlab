function schema





    pk=findpackage('sigio');

    c=schema.class(pk,'abstractxpdestwvars',pk.findclass('abstractxpdestination'));
    c.description='abstract';

    p=schema.prop(c,'DefaultLabels','mxArray');
    set(p,'SetFunction',@setdefaultlabels,'GetFunction',@getdefaultlabels,...
    'AccessFlags.Init','Off');

    p=schema.prop(c,'privDefaultLabels','mxArray');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');

    p=schema.prop(c,'VariableLabels','mxArray');
    set(p,'SetFunction',@setvariablelabels,'GetFunction',@getvariablelabels,...
    'AccessFlags.AbortSet','Off');

    p=schema.prop(c,'VariableNames','mxArray');
    set(p,'SetFunction',@setvariablenames,'GetFunction',@getvariablenames);

    p=schema.prop(c,'ValuesListener','handle.listener');
    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');

    p=schema.prop(c,'PreviousLabelsAndNames','mxArray');
    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');

    schema.event(c,'ForceResize');


