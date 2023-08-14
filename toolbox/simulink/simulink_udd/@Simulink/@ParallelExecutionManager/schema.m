function schema


    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'ParallelExecutionManager',hDeriveFromClass);



    p=schema.prop(hThisClass,'explorer','handle');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'executionNodes','handle vector');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'model','double');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'ModelHandleString','string');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';










    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(hThisClass,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(hThisClass,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

