function schema




    hSuperPackage=findpackage('DAStudio');
    hSuperClass=findclass(hSuperPackage,'Object');
    hPackage=findpackage('Simulink');
    hThisClass=schema.class(hPackage,...
    'BusHierarchyViewer',...
    hSuperClass);



    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createSignalSelector');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'getModel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(hThisClass,'getPorts');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'setPorts');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};



    m=schema.method(hThisClass,'CloseCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};



    p=schema.prop(hThisClass,'fDlg','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=[];


    p=schema.prop(hThisClass,'fModel','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(hThisClass,'fPorts','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=[];


    p=schema.prop(hThisClass,'fSigSelWid','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.FactoryValue=[];


    p=schema.prop(hThisClass,'fListener','mxArray');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.FactoryValue=[];
end


