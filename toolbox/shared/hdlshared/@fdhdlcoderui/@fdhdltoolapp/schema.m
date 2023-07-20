function schema




    mlock;

    pkg=findpackage('fdhdlcoderui');

    sCls=findclass(pkg,'fdhdltooldlg');
    cls=schema.class(pkg,'fdhdltoolapp',sCls);






    findclass(findpackage('DAStudio'),'ActionManager');
    p=schema.prop(cls,'ActionManager','DAStudio.ActionManager');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';




