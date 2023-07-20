function schema





    pk=findpackage('dspopts');
    c=schema.class(pk,'abstractoptionswfs');
    set(c,'Description','abstract');

    p=schema.prop(c,'NormalizedFrequency','bool');
    p.FactoryValue=true;

    p=schema.prop(c,'Fs','mxArray');
    p.AccessFlags.init='off';
    p.SetFunction=@set_fs;
    p.GetFunction=@get_fs;
    p.AccessFlags.Serialize='Off';

    p=schema.prop(c,'privFs','posdouble');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.FactoryValue=1;


