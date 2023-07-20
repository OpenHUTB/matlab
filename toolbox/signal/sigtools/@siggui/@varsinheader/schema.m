function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'varsinheader',pk.findclass('siggui'));

    schema.prop(c,'CurrentStructure','ustring');
    schema.prop(c,'VariableNames','MATLAB array');

    p=schema.prop(c,'Labels','MATLAB array');
    set(p,'AccessFlag.PublicSet','Off','AccessFlag.PublicGet','Off');

    schema.event(c,'NewVariables');


