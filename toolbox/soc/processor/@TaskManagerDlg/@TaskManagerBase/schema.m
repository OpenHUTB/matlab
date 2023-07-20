function schema








    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');

    hPackage=findpackage('TaskManagerDlg');
    this=schema.class(hPackage,'TaskManagerBase',hDeriveFromClass);




    schema.prop(this,'TskMgrBlocks','mxArray');
    schema.prop(this,'TskMgrBlockHandles','MATLAB array');
    schema.prop(this,'Root','mxArray');



    m=schema.method(this,'makeText');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','mxArray','mxArray','bool','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'makeEdit');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','bool','string','mxArray','mxArray','bool','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'makeCheckbox');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','bool','string','mxArray','mxArray','bool','bool','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'makeCombobox');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','MATLAB array','bool','string','mxArray','mxArray','bool','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'makeButton');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','string','mxArray','mxArray','bool','bool','string','double'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'makePanel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','MATLAB array','mxArray','mxArray','mxArray','mxArray','mxArray','bool','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'makeGroup');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','MATLAB array','mxArray','mxArray','mxArray','mxArray','mxArray','bool','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'makeTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array','string','MATLAB array','MATLAB array','MATLAB array','MATLAB array','mxArray','mxArray','bool','bool','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'makeWidget');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','string','MATLAB array','bool','string','mxArray','mxArray','bool','bool','bool'};
    s.OutputTypes={'mxArray'};

end
