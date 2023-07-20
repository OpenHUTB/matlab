function schema()





    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'ConfigSetDialogController');


    hThisProp=schema.prop(hThisClass,'TLCBrowser','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'ParentDialog','mxArray');
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'ObjectiveWindow','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'AllowedUnitSystemsWindow','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'FunctionArrayLayoutDialog','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'inRunningCGA','int');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'SampleTimeInfoStr','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'SFSimTargetOptions','mxArray');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'CustomCodeDeterministicFunctionsDialog','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'showDetails','mxArray');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'usingToolchainApproach','mxArray');
    hThisProp.FactoryValue=-1;

    hThisProp=schema.prop(hThisClass,'ErrorDialog','mxArray');
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.Visible='off';
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'configSetRefSourceNameExisting','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'ModelSelectorObjs','mxArray');
    hThisProp.FactoryValue={};
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'hasUnappliedChanges','bool');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'applyResponseTimer','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'DataDictionary','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'HighlightedWidgets','mxArray');
    hThisProp.FactoryValue={};
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'HighlightColor','mxArray');
    hThisProp.FactoryValue=[0,175,255,255];
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'PanesToExpand','mxArray');
    hThisProp.FactoryValue={};
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'csv2','mxArray');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'ModelParameterConfigurationDialogID','mxArray');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'covSubSysTreeDlg','mxArray');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'CoderDataView','mxArray');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';



    hThisProp=schema.prop(hThisClass,'SourceObject','mxArray');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';


    m=schema.method(hThisClass,'ConfigSetDialogController');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'dialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','string'};
    s.OutputTypes={};

    mlock;




