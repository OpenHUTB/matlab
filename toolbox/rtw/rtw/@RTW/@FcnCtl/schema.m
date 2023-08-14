function schema





    hCreateInPackage=findpackage('RTW');
    hPackage=findpackage('DAStudio');
    hBaseClass=findclass(hPackage,'Object');
    hThisClass=schema.class(hCreateInPackage,'FcnCtl',hBaseClass);


    hThisProp=schema.prop(hThisClass,'Name','string');
    hThisProp.FactoryValue='FunctionControl';


    hThisProp=schema.prop(hThisClass,'ArgSpecData','handle vector');
    hThisProp.FactoryValue=[];
    hThisProp=schema.prop(hThisClass,'ViewWidget','handle');
    hThisProp.FactoryValue=[];
    hThisProp.AccessFlags.Serialize='off';
    hThisProp=schema.prop(hThisClass,'ModelHandle','double');
    hThisProp.FactoryValue=0;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp=schema.prop(hThisClass,'FunctionName','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'InitFunctionName','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'Description','string');
    hThisProp.FactoryValue='';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp=schema.prop(hThisClass,'PreConfigFlag','bool');
    hThisProp.AccessFlags.Serialize='off';
    hThisProp=schema.prop(hThisClass,'RightClickBuild','bool');
    hThisProp.FactoryValue=false;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp=schema.prop(hThisClass,'SubsysBlockHdl','double');
    hThisProp.FactoryValue=-1;
    hThisProp.AccessFlags.Serialize='off';


    m=schema.method(hThisClass,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'codeConstruction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';

    s.InputTypes={'handle','MATLAB array','ustring','MATLAB array','ustring'};
    s.OutputTypes={'bool','ustring'};


    m=schema.method(hThisClass,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'closeCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};



    m=schema.method(hThisClass,'preConfig');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getPreview');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getPortHandles');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getPortProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','mxArray'};
    s.OutputTypes={'string','mxArray','mxArray'};

    m=schema.method(hThisClass,'getControlPortHandle');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double'};
    s.OutputTypes={'double'};

    m=schema.method(hThisClass,'isControlPort');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'foundCombinedIO');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','int32','handle vector','string'};
    s.OutputTypes={'bool','int32','bool','string'};


