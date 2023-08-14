function schema





















    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmGuiObj');


    hThisClass=schema.class(hCreateInPackage,'PmBaseWidget',hBaseObj);


    p=schema.prop(hThisClass,'ValueBlkParam','ustring');
    p=schema.prop(hThisClass,'EnableStatus','bool');
    p=schema.prop(hThisClass,'Listeners','mxArray');


    m=schema.method(hThisClass,'notifyListeners');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','string'};
    s.OutputTypes={};
