function schema






    hCreateInPackage=findpackage('PMDialogs');


    hThisClass=schema.class(hCreateInPackage,'PmGuiObj');


    p=schema.prop(hThisClass,'BlockHandle','mxArray');
    p.Description='Handle of the source SL block.';
    p.FactoryValue=[];

    p=schema.prop(hThisClass,'Name','ustring');
    p=schema.prop(hThisClass,'ColSpan','MATLAB array');
    p=schema.prop(hThisClass,'RowSpan','MATLAB array');
    p=schema.prop(hThisClass,'Items','PMDialogs.PmGuiObj vector');
    p=schema.prop(hThisClass,'CreateInstanceFcn','handle');

    p=schema.prop(hThisClass,'ObjId','ustring');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PrivateSet='on';
    p.AccessFlags.PrivateGet='on';



    m=schema.method(hThisClass,'PreApply');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool','ustring'};

    m=schema.method(hThisClass,'Apply');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};

    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'Refresh');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'Validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'buildFromPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array'};
    s.OutputTypes={'bool','MATLAB array'};

    m=schema.method(hThisClass,'getPmSchemaFromChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool','MATLAB array'};

    m=schema.method(hThisClass,'buildChildrenFromPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'createInstance');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'realizeChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'refreshChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getDlgSrcObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'assignObjId');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(hThisClass,'PreDlgDisplay');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

