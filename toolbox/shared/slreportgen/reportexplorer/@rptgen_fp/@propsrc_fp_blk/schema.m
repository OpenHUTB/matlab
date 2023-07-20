function schema






    pkgFP=findpackage('rptgen_fp');
    pkgSL=findpackage('rptgen_sl');

    h=schema.class(pkgFP,'propsrc_fp_blk',pkgSL.findclass('propsrc_sl_blk'));


    p=schema.prop(h,'SignalInfo','MATLAB array');
    p.AccessFlags.Reset='on';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicSet='off';
    p.FactoryValue=[];
    p.Visible='off';

    p=schema.prop(h,'PropertyListeners','handle vector');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
