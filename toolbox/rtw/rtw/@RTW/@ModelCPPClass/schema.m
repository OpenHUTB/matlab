function schema




    hCreateInPackage=findpackage('RTW');
    hBaseClass=findclass(hCreateInPackage,'FcnCtl');
    hThisClass=schema.class(hCreateInPackage,'ModelCPPClass',hBaseClass);

    hThisProp=schema.prop(hThisClass,'Data','handle vector');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'ModelClassName','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'ClassNamespace','string');
    hThisProp.FactoryValue='';




    hThisProp=schema.prop(hThisClass,'CalculatedMdlRefInstanceVariables','MATLAB array');
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.FactoryValue={};

    hThisProp=schema.prop(hThisClass,'MdlRefInstanceVariablesMdlNames','MATLAB array');
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.FactoryValue={};

    hThisProp=schema.prop(hThisClass,'cache','RTW.ModelCPPClass');
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'isTemp','bool');
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.FactoryValue=false;



    m=schema.method(hThisClass,'getSectionDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array','ustring','bool','ustring'};
    s.OutputTypes={'bool','ustring'};

    m=schema.method(hThisClass,'supValidation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool','ustring'};

    m=schema.method(hThisClass,'getStepMethodName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setStepMethodName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getClassName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setClassName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getNamespace');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setNamespace');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'attachToModel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'preConfig');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'closeCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'syncWithModel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(hThisClass,'setDefaultStepMethodName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'setDefaultClassName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'setDefaultNamespace');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getDefaultConf');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getNumArgs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'int32'};

    m=schema.method(hThisClass,'needsCompilation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getPortDefaultConf');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double','int32','int32'};
    s.OutputTypes={'handle'};


