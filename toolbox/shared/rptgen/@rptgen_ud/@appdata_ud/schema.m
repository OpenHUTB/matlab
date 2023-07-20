function schema




    pkg=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'appdata_ud',pkgRG.findclass('appdata'));

    p=schema.prop(h,'CurrentPackage','handle');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getCurrentPackage;

    p=schema.prop(h,'CurrentObject','mxArray');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';

    p=schema.prop(h,'CurrentClass','handle');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getCurrentClass;

    p=schema.prop(h,'CurrentProperty','handle vector');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';

    p=schema.prop(h,'CurrentMethod','handle vector');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';

    p=schema.prop(h,'Context','ustring');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';

    p=schema.prop(h,'ClassInheritanceTable','MATLAB array');
    p.FactoryValue=[];
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getClassInheritanceTable;






