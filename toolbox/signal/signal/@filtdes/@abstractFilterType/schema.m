function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'abstractFilterType');
    c.description='abstract';


    p=schema.prop(c,'Tag','ustring');
    p.AccessFlags.PublicSet='off';


    findclass(pk,'abstractSpec');
    p=schema.prop(c,'specobjs','filtdes.abstractSpec vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';

