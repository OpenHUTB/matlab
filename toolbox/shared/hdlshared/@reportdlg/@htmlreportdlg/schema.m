function schema







    mlock;

    sCls=findclass(findpackage('DAStudio'),'Object');
    cls=schema.class(findpackage('reportdlg'),'htmlreportdlg',sCls);

    p=schema.prop(cls,'dispContent','string');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p=schema.prop(cls,'dispTittle','string');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p=schema.prop(cls,'dispIcon','string');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p=schema.prop(cls,'listeners','handle.listener vector');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';






    m=schema.method(cls,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

