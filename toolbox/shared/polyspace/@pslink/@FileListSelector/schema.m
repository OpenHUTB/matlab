function schema





    hSuperCls=findclass(findpackage('DAStudio'),'Object');
    hPkg=findpackage('pslink');


    hCls=schema.class(hPkg,'FileListSelector',hSuperCls);


    hProp=schema.prop(hCls,'AdditionalFileList','string vector');
    hProp.Visible='off';
    hProp.FactoryValue={};

    hProp=schema.prop(hCls,'pslinkcc','MATLAB array');
    hProp.FactoryValue=[];

    hProp=schema.prop(hCls,'pslinkccDlg','MATLAB array');
    hProp.FactoryValue=[];


    hMethod=schema.method(hCls,'getDialogSchema');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle','string'};
    hSig.OutputTypes={'mxArray'};

    hMethod=schema.method(hCls,'dialogCB');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle','string','handle'};
    hSig.OutputTypes={};


    hMethod=schema.method(hCls,'closeCB','static');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle','string'};
    hSig.OutputTypes={};


