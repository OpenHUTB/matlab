function schema



    mlock;


    sCls=findclass(findpackage('DAStudio'),'Explorer');
    pkg=findpackage('SigLogSelector');
    cls=schema.class(pkg,'explorer',sCls);


    findclass(findpackage('DAStudio'),'imExplorer');
    p=schema.prop(cls,'imme','DAStudio.imExplorer');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';


    schema.prop(cls,'hOverrideCombo','handle');


    schema.prop(cls,'hLoggingOffTxt','handle');





    p=schema.prop(cls,'actions','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';






    p=schema.prop(cls,'actionState','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';


    p=schema.prop(cls,'listeners','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';



    p=schema.prop(cls,'sleepCount','int32');
    p.FactoryValue=0;


    p=schema.prop(cls,'status','string');
    p.FactoryValue='done';


    p=schema.prop(cls,'displayMdlRefHelp','bool');
    p.FactoryValue=false;
    p.Visible='Off';


    p=schema.prop(cls,'isLoadingActions','bool');
    p.FactoryValue=false;
    p.Visible='Off';


    p=schema.prop(cls,'isSettingDataLoggingOveride','bool');
    p.FactoryValue=false;
    p.Visible='Off';


    p=schema.prop(cls,'isBeingDestroyed','bool');
    p.FactoryValue=false;
    p.Visible='Off';


    p=schema.prop(cls,'isTesting','bool');
    p.FactoryValue=false;
    p.Visible='Off';


    p=schema.prop(cls,'displayFullMenus','bool');
    p.FactoryValue=false;
    p.Visible='Off';


    schema.prop(cls,'unloadingModelRefNode','handle');


    p=schema.prop(cls,'cachedWarningDlgs','MATLAB array');
    p.FactoryValue={};
    p.Visible='Off';


    m=schema.method(cls,'setOverrideModeValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

end
