function schema




    sCls=findclass(findpackage('DAStudio'),'Explorer');
    pkg=findpackage('TflDesigner');
    cls=schema.class(pkg,'explorer',sCls);

    findclass(findpackage('DAStudio'),'imExplorer');
    p=schema.prop(cls,'imme','DAStudio.imExplorer');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';


    p=schema.prop(cls,'actions','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';


    p=schema.prop(cls,'customactions','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';



    p=schema.prop(cls,'actionstate','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p=schema.prop(cls,'listeners','handle.listener vector');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';


