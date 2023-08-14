function schema()






mlock



    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'BaseMSDefn');




    hThisProp=schema.prop(hThisClass,'Name','string');

    hThisProp=schema.prop(hThisClass,'OwnerPackage','string');





    m=schema.method(hThisClass,'getProp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(hThisClass,'updateRefObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'convert2struct');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'checkCircularReference');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'deepCopy');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};


    m=schema.method(hThisClass,'getTabs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getMSPropDetails');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getMemorySectionDefnForPreview');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'getDefnsForValidation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'handle','handle'};

    m=schema.method(hThisClass,'setPropAndDirty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={};




