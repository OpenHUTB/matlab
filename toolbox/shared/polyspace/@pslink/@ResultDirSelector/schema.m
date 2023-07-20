function schema





    hSuperCls=findclass(findpackage('DAStudio'),'Object');
    hPkg=findpackage('pslink');


    hCls=schema.class(hPkg,'ResultDirSelector',hSuperCls);


    hProp=schema.prop(hCls,'treeItems','mxArray');
    hProp.FactoryValue={};

    hProp=schema.prop(hCls,'goodTreeItems','mxArray');
    hProp.FactoryValue={};

    hProp=schema.prop(hCls,'treeItemsList','mxArray');
    hProp.FactoryValue={};

    hProp=schema.prop(hCls,'selectedItem','string');
    hProp.FactoryValue='';

    hProp=schema.prop(hCls,'mrefDir','string vector');
    hProp.FactoryValue={};

    hProp=schema.prop(hCls,'sysDir','string');
    hProp.FactoryValue='';

    hProp=schema.prop(hCls,'isModel','bool');
    hProp.FactoryValue=true;

    hProp=schema.prop(hCls,'isMdlRef','bool');
    hProp.FactoryValue=false;

    hProp=schema.prop(hCls,'isBugFinder','bool');
    hProp.FactoryValue=false;


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


