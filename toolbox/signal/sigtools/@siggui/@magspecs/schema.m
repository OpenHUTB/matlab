function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'magspecs',pk.findclass('magframe'));
    set(c,'Description','Magnitude Specifications');


    if isempty(findtype('siggui_magspecs_IRType'))
        schema.EnumType('siggui_magspecs_IRType',{'FIRUnits','IIRUnits'});
    end



    p=schema.prop(c,'FIRunits','siggui_magspecs_FIRUnits');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';


    p=schema.prop(c,'IIRunits','siggui_magspecs_IIRUnits');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';


    p=schema.prop(c,'IRType','siggui_magspecs_IRType');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';







