function schema




    hCreateInPackage=findpackage('RTW');


    hBaseClass=findclass(hCreateInPackage,'FcnCtl');


    hThisClass=schema.class(hCreateInPackage,'FcnDefault',hBaseClass);

    hThisProp=schema.prop(hThisClass,'Multirate','bool');
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

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array','ustring','bool','ustring'};
    s.OutputTypes={'bool','ustring'};

    m=schema.method(hThisClass,'closeCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getPreview');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'attachToModel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};
