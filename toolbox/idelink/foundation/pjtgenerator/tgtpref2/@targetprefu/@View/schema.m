function schema




    hDerivedFromPackage=findpackage('DAStudio');
    hDerivedFromClass=findclass(hDerivedFromPackage,'Object');
    hMyPackage=findpackage('targetprefu');
    hthisClass=schema.class(hMyPackage,'View',hDerivedFromClass);










    p=schema.prop(hthisClass,'mController','mxArray');
    p.FactoryValue='';

    p=schema.prop(hthisClass,'mLabels','mxArray');
    p.FactoryValue=[];

    p=schema.prop(hthisClass,'mToolTips','mxArray');
    p.FactoryValue=[];

    p=schema.prop(hthisClass,'mCurTab','mxArray');
    p.FactoryValue=0;

    p=schema.prop(hthisClass,'mCurSelection','mxArray');
    p.FactoryValue=0;

    p=schema.prop(hthisClass,'mCustomMemBanks','mxArray');
    p.FactoryValue=[];

    p=schema.prop(hthisClass,'mPeripheralPanel','mxArray');
    p.FactoryValue=0;

    p=schema.prop(hthisClass,'mBoardProcessor','mxArray');
    p.FactoryValue=0;






    m=schema.method(hthisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hthisClass,'callController');
    s=m.signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(hthisClass,'validateEntries');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hthisClass,'applyEntries');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hthisClass,'closeDialog');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hthisClass,'dismissDialog');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};
