function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'dynamicMinOrdMethod',findclass(pk,'abstractSingleOrderMethod'));
    c.description='abstract';


    p=schema.prop(c,'ordModeListener','handle.listener');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
