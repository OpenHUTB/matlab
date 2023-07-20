function schema
    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'ParallelExecutionNode',hDeriveFromClass);





    p=schema.prop(hThisClass,'name','string');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'rootnode','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';

    p=schema.prop(hThisClass,'Model','handle');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'NodeName','string');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'NodeType','string');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'ParallelExecutionTime','double');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'SerialExecutionTime','double');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';



    p=schema.prop(hThisClass,'ExecutionMode','string');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';

    p=schema.prop(hThisClass,'PreviousExecutionMode','string');
    p.AccessFlags.PublicSet='On';
    p.Visible='On';




    m=schema.method(hThisClass,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(hThisClass,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getPropValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getPropAllowedValues');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string vector'};

    m=schema.method(hThisClass,'getPropDataType');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getEditableProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(hThisClass,'propertyHyperlink');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','bool'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'setDialogProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'hiliteNode');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

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

