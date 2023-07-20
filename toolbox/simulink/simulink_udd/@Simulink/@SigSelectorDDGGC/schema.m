function schema












    hPackage=findpackage('Simulink');
    hThisClass=schema.class(hPackage,'SigSelectorDDGGC');





    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'applyFilter');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','handle'};

    m=schema.method(hThisClass,'update');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','MATLAB array','MATLAB array'};


    m=schema.method(hThisClass,'updateItems');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','MATLAB array','MATLAB array'};

    m=schema.method(hThisClass,'selectSignalInTree');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','handle'};

    m=schema.method(hThisClass,'selectSignalInList');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','handle'};


    m=schema.method(hThisClass,'constructTreeItems');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle'};
    m.signature.OutputTypes={'mxArray','mxArray','mxArray','mxArray'};

    m=schema.method(hThisClass,'setMinimumSize');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','MATLAB array'};

    m=schema.method(hThisClass,'setFilterOptions');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','string','handle'};






    p=schema.prop(hThisClass,'TCPeer','MATLAB array');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';
    schema.prop(hThisClass,'Parent','MATLAB array');
    p=schema.prop(hThisClass,'TCListeners','MATLAB array');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p=schema.prop(hThisClass,'MinimumSize','MATLAB array');
    p.FactoryValue=[200,200];
    p=schema.prop(hThisClass,'ShowFilteringOptions','MATLAB array');
    p.FactoryValue=false;
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p=schema.prop(hThisClass,'DDGItems','MATLAB array');
    p.FactoryValue=false;
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p=schema.prop(hThisClass,'DDGIDs','MATLAB array');
    p.FactoryValue=false;
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p=schema.prop(hThisClass,'DDGSelectionPaths','MATLAB array');
    p.FactoryValue=false;
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';




    schema.event(hThisClass,'TreeChangeEvent');

end


