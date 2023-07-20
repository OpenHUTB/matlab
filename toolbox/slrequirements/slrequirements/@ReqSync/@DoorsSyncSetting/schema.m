function schema()




    reqSyncPackage=findpackage('ReqSync');


    hDeriveFromPackageDAS=findpackage('DAStudio');
    hDeriveFromClassDAS=findclass(hDeriveFromPackageDAS,'Object');

    targetClass=schema.class(reqSyncPackage,'DoorsSyncSetting',hDeriveFromClassDAS);






    p=schema.prop(targetClass,'detaillevel','double');
    p=schema.prop(targetClass,'surrogatepath','MATLAB array');
    p=schema.prop(targetClass,'doorsLinks2sl','MATLAB array');
    p=schema.prop(targetClass,'slLinks2Doors','MATLAB array');
    p=schema.prop(targetClass,'updateLinks','MATLAB array');
    p=schema.prop(targetClass,'savesurrogate','MATLAB array');
    p=schema.prop(targetClass,'savemodel','MATLAB array');
    p=schema.prop(targetClass,'lastsync','MATLAB array');
    p=schema.prop(targetClass,'synctime','MATLAB array');
    p=schema.prop(targetClass,'surrogateId','MATLAB array');
    p=schema.prop(targetClass,'modelH','MATLAB array');
    p=schema.prop(targetClass,'purgeSimulink','MATLAB array');
    p=schema.prop(targetClass,'purgeDoors','MATLAB array');



    m=schema.method(targetClass,'getDialogSchema');

    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};
