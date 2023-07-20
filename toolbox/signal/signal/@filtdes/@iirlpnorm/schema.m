function schema






    pk=findpackage('filtdes');


    c=schema.class(pk,'iirlpnorm',findclass(pk,'lpnorm'));


    p=schema.prop(c,'initNum','MATLAB array');
    p.FactoryValue=[];

    p=schema.prop(c,'initDen','MATLAB array');
    p.FactoryValue=[];



    p=schema.prop(c,'numOrder','spt_uint32');
    p.SetFunction=@set_numorder;
    p.GetFunction=@get_numorder;

    p=schema.prop(c,'denOrder','spt_uint32');
    p.SetFunction=@set_denorder;
    p.GetFunction=@get_denorder;


    findclass(pk,'numDenFilterOrder');
    p=schema.prop(c,'numDenFilterOrderObj','filtdes.numDenFilterOrder');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
