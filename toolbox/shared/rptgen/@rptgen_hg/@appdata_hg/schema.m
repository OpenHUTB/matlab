function schema




    mlock;

    pkg=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'appdata_hg',pkgRG.findclass('appdata'));

    p=schema.prop(h,'CurrentFigure','MATLAB array');
    p.FactoryValue=[];
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getCurrentFigure;

    p=schema.prop(h,'CurrentAxes','MATLAB array');
    p.FactoryValue=[];
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';

    p.getFunction=@getCurrentAxes;

    p=schema.prop(h,'CurrentObject','MATLAB array');
    p.FactoryValue=[];
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getCurrentObject;

    p=schema.prop(h,'PreRunOpenFigures','MATLAB array');
    p.FactoryValue=0;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getPreRunOpenFigures;

    p=schema.prop(h,'CurrentName','ustring');
    p.FactoryValue='';
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';

