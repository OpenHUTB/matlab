function schema()




    reqIntPackage=findpackage('ReqMgr');


    hDeriveFromPackageDAS=findpackage('DAStudio');
    hDeriveFromClassDAS=findclass(hDeriveFromPackageDAS,'Object');

    targetClass=schema.class(reqIntPackage,'LinkSet',hDeriveFromClassDAS);












    p=schema.prop(targetClass,'modelObj','double');

    p=schema.prop(targetClass,'dialogUD','MATLAB array');
    p=schema.prop(targetClass,'reqItems','MATLAB array');
    p=schema.prop(targetClass,'typeItems','MATLAB array');
    p=schema.prop(targetClass,'locItems','MATLAB array');
    p=schema.prop(targetClass,'docHistory','MATLAB array');
    p=schema.prop(targetClass,'tagHistory','MATLAB array');
    p=schema.prop(targetClass,'extensions','MATLAB array');
    p=schema.prop(targetClass,'locMark','MATLAB array');
    p=schema.prop(targetClass,'reqIdx','double');
    p=schema.prop(targetClass,'typeIdx','double');
    p=schema.prop(targetClass,'docContents','MATLAB array');
    p=schema.prop(targetClass,'objectH','MATLAB array');
    p=schema.prop(targetClass,'title','MATLAB array');
    p=schema.prop(targetClass,'index','double');
    p=schema.prop(targetClass,'count','double');
    p=schema.prop(targetClass,'switchTab','double');
    p=schema.prop(targetClass,'source','MATLAB array');
    p=schema.prop(targetClass,'tabIndex','double');
    p=schema.prop(targetClass,'listener','MATLAB array');


    m=schema.method(targetClass,'getDialogSchema');


    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(targetClass,'doSelItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'doUpItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'doNewItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'doCopyItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'doDeleteItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'changeDescItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'doDownItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'typeSel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'cacheChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'refreshChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    m=schema.method(targetClass,'updateContents');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','bool'};
    s.OutputTypes={};

    m=schema.method(targetClass,'selectContent');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'doApply');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'double','MATLAB array'};

    m=schema.method(targetClass,'changeDocItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'refreshDiag');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'getBookMarkEntries');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array','double','MATLAB array'};

    m=schema.method(targetClass,'getTypeIdx');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','MATLAB array'};
    s.OutputTypes={'double'};

    m=schema.method(targetClass,'doLocChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'reset');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};
