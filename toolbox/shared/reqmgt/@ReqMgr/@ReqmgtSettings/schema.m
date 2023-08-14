function schema()




    reqIntPackage=findpackage('ReqMgr');


    hDeriveFromPackageDAS=findpackage('DAStudio');
    hDeriveFromClassDAS=findclass(hDeriveFromPackageDAS,'Object');

    targetClass=schema.class(reqIntPackage,'ReqmgtSettings',hDeriveFromClassDAS);






    p=schema.prop(targetClass,'wordindx','double');
    p=schema.prop(targetClass,'excelindx','double');
    p=schema.prop(targetClass,'doorsindx','double');




    m=schema.method(targetClass,'getDialogSchema');

    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};
