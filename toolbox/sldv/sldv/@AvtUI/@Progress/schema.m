function schema()




    interfacePackage=findpackage('AvtUI');


    hDeriveFromPackageDAS=findpackage('DAStudio');
    hDeriveFromClassDAS=findclass(hDeriveFromPackageDAS,'Object');

    targetClass=schema.class(interfacePackage,'Progress',hDeriveFromClassDAS);


















    schema.prop(targetClass,'browserparam1','MATLAB array');
    schema.prop(targetClass,'browserparam2','double');
    schema.prop(targetClass,'abortSignal','bool');

    schema.prop(targetClass,'ProgressStr','string');
    schema.prop(targetClass,'Log','ustring');
    schema.prop(targetClass,'progressArea','handle');
    schema.prop(targetClass,'logArea','handle');
    schema.prop(targetClass,'mode','string');


    p=schema.prop(targetClass,'ElapsedTimer','MATLAB array');
    p.FactoryValue=[];
    p.AccessFlag.PublicGet='off';
    p.AccessFlag.PublicSet='off';


    p=schema.prop(targetClass,'analysisStartTime','MATLAB array');
    p.FactoryValue=0;
    p.AccessFlag.PublicSet='off';



    p=schema.prop(targetClass,'Launcher','MATLAB array');
    p.FactoryValue=[];
    p.AccessFlag.PublicGet='off';
    p.AccessFlag.PublicSet='off';



    p=schema.prop(targetClass,'ExecListener','MATLAB array');
    p.FactoryValue=[];
    p.AccessFlag.PublicGet='off';
    p.AccessFlag.PublicSet='off';





    p=schema.prop(targetClass,'AnalysisMode','string');
    p.FactoryValue='';
    p.AccessFlag.PublicGet='on';
    p.AccessFlag.PublicSet='off';

    p=schema.prop(targetClass,'stopped','bool');
    p.FactoryValue=0;

    p=schema.prop(targetClass,'finalized','bool');
    p.FactoryValue=0;

    p=schema.prop(targetClass,'logPath','ustring');
    p.FactoryValue='';


    p=schema.prop(targetClass,'breakOnCompat','bool');
    p.FactoryValue=0;

    schema.prop(targetClass,'saved','bool');


    schema.prop(targetClass,'hasInfoPanel','bool');


    schema.prop(targetClass,'testComp','handle');


    schema.prop(targetClass,'dialogH','handle');


    p=schema.prop(targetClass,'selectDialogH','handle');
    p.FactoryValue=[];


    schema.prop(targetClass,'lastRefresh','MATLAB array');

    p=schema.prop(targetClass,'modelName','string');
    p.FactoryValue='';

    p=schema.prop(targetClass,'closed','bool');
    p.FactoryValue=0;



    p=schema.prop(targetClass,'sldvCoreAnalInProgress','bool');
    p.FactoryValue=0;
    p.AccessFlag.PublicGet='on';
    p.AccessFlag.PublicSet='off';


    m=schema.method(targetClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(targetClass,'abortAnalysis');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'highlightCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'analyzeCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'destroyLogarea');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'closeButton');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'saveButton');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'appendToLog');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={};

    m=schema.method(targetClass,'setLog');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={};

    m=schema.method(targetClass,'saveTextLog');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={};

    m=schema.method(targetClass,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'initialize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(targetClass,'progressHTML');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'showLogArea');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'refreshLogArea');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'setSelectDialogH');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(targetClass,'setAnalysisStatus');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','bool'};
    s.OutputTypes={};

    m=schema.method(targetClass,'setElapsedTimerMode');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','bool'};
    s.OutputTypes={};

