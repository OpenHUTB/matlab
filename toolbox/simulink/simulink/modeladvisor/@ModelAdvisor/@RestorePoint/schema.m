function schema





    hDeriveFromPackage1=findpackage('DAStudio');
    hDeriveFromClass1=findclass(hDeriveFromPackage1,'Object');
    hCreateInPackage=findpackage('ModelAdvisor');


    hThisClass=schema.class(hCreateInPackage,'RestorePoint',hDeriveFromClass1);








    hThisProp=schema.prop(hThisClass,'MAObj','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'IsSaveDlg','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'SelectedLineIndex','mxArray');
    hThisProp.FactoryValue=0;







    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'closeDialog');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'saveBtnCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'loadBtnCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'deleteBtnCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'openLoadDlg','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={};


    m=schema.method(hThisClass,'openSaveDlg','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={};


    m=schema.method(hThisClass,'quickSave','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={};
