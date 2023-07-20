function schema()






    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');



    hThisClass=schema.class(hCreateInPackage,'ConfigSetAllowedUnitSystems',hDeriveFromClass);














    hThisProp=schema.prop(hThisClass,'unitSysList','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'selectedUnitSys','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'availableUnitSys','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'selectedForAllow','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'selectedForDisallow','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'dirty','int');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'allUnitSysFlag','on/off');
    hThisProp.FactoryValue='on';

    hThisProp=schema.prop(hThisClass,'unitSysCopy','string');
    hThisProp.FactoryValue='all';

    hThisProp=schema.prop(hThisClass,'ParentDlg','handle');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'ThisDlg','handle');
    hThisProp.FactoryValue=[];

    hThipProp=schema.prop(hThisClass,'myDebuggingCC','Simulink.DebuggingCC');

    hThisProp=schema.prop(hThisClass,'Listener','handle');
    hThisProp.FactoryValue=[];



    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'OKCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'CancelCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'helpCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'availablelist_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'selectedlist_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'allowbtn_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'disallowbtn_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'allowallunitsystems_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray','string','string','string','string'};
    s.OutputTypes={};


