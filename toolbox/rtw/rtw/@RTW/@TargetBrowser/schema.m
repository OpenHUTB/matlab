function schema()





    hCreateInPackage=findpackage('RTW');


    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');


    hThisClass=schema.class(hCreateInPackage,'TargetBrowser',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'tlcfiles','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'tlcfiles_selected','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'tlclist','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'tlclist_selected','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'ParentDlg','handle');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'ParentSrc','handle');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'ThisDlg','handle');
    hThisProp.FactoryValue=[];



    hThisProp=schema.prop(hThisClass,'selectedSettings','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'column1Width','double');
    hThisProp.FactoryValue=28;
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'uploadTarget');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};


