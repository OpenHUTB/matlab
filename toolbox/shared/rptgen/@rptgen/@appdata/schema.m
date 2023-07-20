function schema




    mlock;

    pkg=findpackage('rptgen');

    h=schema.class(pkg,...
    'appdata',...
    pkg.findclass('rpt_all'));

    findclass(findpackage('handle'),'listener');
    p=schema.prop(h,'PropertyListeners','handle.listener vector');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';

    p=schema.prop(h,'StackPrevious','handle');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';




    p=schema.prop(h,'ImplyValues','bool');
    p.AccessFlags.Init='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';
    p.FactoryValue=true;
