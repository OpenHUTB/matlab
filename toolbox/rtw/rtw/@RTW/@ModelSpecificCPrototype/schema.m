function schema




    hCreateInPackage=findpackage('RTW');
    hBaseClass=findclass(hCreateInPackage,'FcnCtl');
    hThisClass=schema.class(hCreateInPackage,'ModelSpecificCPrototype',hBaseClass);

    hThisProp=schema.prop(hThisClass,'Data','handle vector');
    hThisProp.FactoryValue=[];



    findclass(findpackage('RTW'),'ModelSpecificCPrototype');
    hThisProp=schema.prop(hThisClass,'cache','RTW.ModelSpecificCPrototype');
    hThisProp.AccessFlags.Serialize='off';

    hThisProp=schema.prop(hThisClass,'selRow','int32');
    hThisProp.FactoryValue=0;
    hThisProp.AccessFlags.Serialize='off';


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getDescriptionGrpSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getPreconfGrpSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getPreviewGrpSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getValidateGrpSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'upCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'downCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'codeConstruction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

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

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array','ustring','bool','ustring'};
    s.OutputTypes={'bool','ustring'};

    m=schema.method(hThisClass,'preConfig');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'syncWithModel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(hThisClass,'runValidation');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={'bool','ustring'};

    m=schema.method(hThisClass,'getDefaultConf');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getPortDefaultConf');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double'};
    s.OutputTypes={'string','string','string'};

    m=schema.method(hThisClass,'addArgConf');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getFunctionName');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setFunctionName');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getArgName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setArgName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getArgCategory');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setArgCategory');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getArgPosition');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'int32'};

    m=schema.method(hThisClass,'setArgPosition');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','int32'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getArgQualifier');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setArgQualifier');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getPreview');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};
