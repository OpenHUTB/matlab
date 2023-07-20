function schema



    mlock;

    hPackage=findpackage('tdkfpgacc');
    this=schema.class(hPackage,'UddUtil');





    m=schema.method(this,'EnumByStrStruct');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','string'};
    m.Signature.OutputTypes={'mxArray'};

    m=schema.method(this,'EnumByPosArray');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','string'};
    m.Signature.OutputTypes={'mxArray'};



    m=schema.method(this,'EnumInt2Str');
    m.Signature.varargin='off';

    m.Signature.InputTypes={'handle','string','int'};

    m.Signature.OutputTypes={'string'};

    m=schema.method(this,'EnumStr2Int');
    m.Signature.varargin='off';

    m.Signature.InputTypes={'handle','string','string'};

    m.Signature.OutputTypes={'int'};


