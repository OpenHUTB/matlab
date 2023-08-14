function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'iirgrpdelayoptsframe',pk.findclass('iirlpnormcoptsframe'));


    p=schema.prop(c,'InitNum','ustring');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';


