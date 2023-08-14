function schema





    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'propsrc_sl',pkgRG.findclass('propsrc'));

    p=schema.prop(h,'CompiledInfo','MATLAB array');
    p.AccessFlags.Reset='on';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicSet='off';
    p.FactoryValue=[];
    p.Visible='off';

