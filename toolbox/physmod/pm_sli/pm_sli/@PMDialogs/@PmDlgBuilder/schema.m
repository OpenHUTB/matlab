function schema












    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmGuiObj');


    hThisClass=schema.class(hCreateInPackage,'PmDlgBuilder',hBaseObj);


    p=schema.prop(hThisClass,'OnBlockSchema','MATLAB array');
    p=schema.prop(hThisClass,'PanelObjLst','handle vector');


    m=schema.method(hThisClass,'getPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array'};
    s.OutputTypes={'bool','MATLAB array'};

    m=schema.method(hThisClass,'buildFromPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array'};
    s.OutputTypes={'bool'};



