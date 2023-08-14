function schema




    sCls=findclass(findpackage('DAStudio'),'Explorer');
    pkg=findpackage('DeploymentDiagram');
    cls=schema.class(pkg,'explorer',sCls);

    findclass(findpackage('DAStudio'),'imExplorer');
    p=schema.prop(cls,'imme','DAStudio.imExplorer');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';


    p=schema.prop(cls,'actions','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';



    p=schema.prop(cls,'actionstate','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p=schema.prop(cls,'listeners','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p=schema.prop(cls,'explorerID','string');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p=schema.prop(cls,'archSelectDialog','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p=schema.prop(cls,'isFrozen','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';
    p.FactoryValue=false;



    p=schema.prop(cls,'sleepCount','int32');
    p.FactoryValue=0;

    p=schema.prop(cls,'MCOSListeners','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';






    p=schema.prop(cls,'lastSelectedNodeActions','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    m=schema.method(cls,'updateactions');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={};

    m=schema.method(cls,'attachMCOSListeners');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};


    m=schema.method(cls,'updateTitle');
    s=m.Signature;
    s.varargin='off';
    s.InputType={'handle'};
    s.OutputTypes={};
