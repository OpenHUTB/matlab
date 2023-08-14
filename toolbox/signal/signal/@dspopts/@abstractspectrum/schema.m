function schema





    pk=findpackage('dspopts');
    c=schema.class(pk,'abstractspectrum',pk.findclass('abstractoptionswfs'));
    set(c,'Description','abstract');

    p=schema.prop(c,'CenterDC','mxArray');
    p.AccessFlags.Serialize='Off';
    p.AccessFlags.init='off';
    p.SetFunction=@set_centerdc;
    p.GetFunction=@get_centerdc;

    p=schema.prop(c,'privcenterdc','bool');
    p.FactoryValue=false;
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';


