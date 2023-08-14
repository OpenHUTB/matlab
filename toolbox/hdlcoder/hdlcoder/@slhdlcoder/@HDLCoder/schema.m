function schema





    mlock;

    pkg=findpackage('slhdlcoder');
    findpackage('hdlshared');

    propspkg=findpackage('hdlcoderprops');
    findclass(propspkg,'HDLProps');

    this=schema.class(pkg,'HDLCoder');



    schema.prop(this,'CmdLineParams','mxArray');


    schema.prop(this,'FrontEnd','mxArray');


    schema.prop(this,'BackEnd','mxArray');

    p=schema.prop(this,'CoderParameters','mxArray');
    set(p,'AccessFlags.Init','Off','GetFunction',@get_coderparameters);

    schema.prop(this,'CoderParameterObject','mxArray');
    schema.prop(this,'TimeStamp','string');
    schema.prop(this,'CodeGenSuccessful','bool');
    schema.prop(this,'LastStartNodeName','string');
    schema.prop(this,'LastTargetLanguage','string');


    schema.prop(this,'CachedSingleTaskRateTransMsg','string');


    schema.prop(this,'TestBenchFilesList','string vector');

    schema.prop(this,'ImplDB','mxArray');

    schema.prop(this,'ConfigManager','mxArray');


    schema.prop(this,'SequentialContext','bool');


    schema.prop(this,'SubModelData','mxArray');
    schema.prop(this,'PirInstance','mxArray');


    schema.prop(this,'isIPTestbench','bool');


    schema.prop(this,'AllModels','mxArray');

    schema.prop(this,'ProtectedModels','mxArray');

    schema.prop(this,'BlackBoxModels','mxArray');



    p=schema.prop(this,'mdlIdx','int32');
    p.FactoryValue=1;





    p=schema.prop(this,'hs','mxArray');
    p.FactoryValue=[];







    p=schema.prop(this,'SkipFrontEnd','bool');
    p.FactoryValue=false;




    schema.prop(this,'CurrentNetwork','mxArray');



    p=schema.prop(this,'TimingControllerInfo','mxArray');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Serialize='off';



    p=schema.prop(this,'ExistingRamMap','mxArray');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Serialize='off';


    p=schema.prop(this,'CurrentClock','mxArray');
    p.FactoryValue=[];

    p=schema.prop(this,'CurrentClockEnable','mxArray');
    p.FactoryValue=[];

    p=schema.prop(this,'CurrentReset','mxArray');
    p.FactoryValue=[];


    p=schema.prop(this,'HasClockEnable','bool');
    p.FactoryValue=true;

    schema.prop(this,'ModelName','string');
    schema.prop(this,'CoverifyModelName','string');
    schema.prop(this,'CosimModelName','string');
    schema.prop(this,'OrigModelName','string');


    p=schema.prop(this,'nonTopDut','bool');
    p.factoryValue=false;
    schema.prop(this,'OrigStartNodeName','string');
    p=schema.prop(this,'DUTMdlRefHandle','double');
    p.factoryValue=0;
    p=schema.prop(this,'DUTVariantName','string');
    p.factoryValue='HDLC_internal_variant_OriginalDUT';
    p=schema.prop(this,'gmVariantName','string');
    p.factoryValue='HDLC_internal_variant_GeneratedDUT';
    p=schema.prop(this,'VariantControlVarName','string');
    p.factoryValue='HDLC_internal_variant_control';



    p=schema.prop(this,'DutSTIRate','double');
    p.FactoryValue=-1.0;

    p=schema.prop(this,'ModelConnection','mxArray');

    p.AccessFlags.Serialize='off';

    p=schema.prop(this,'MCPinfo','mxArray');
    p.FactoryValue=[];


    p=schema.prop(this,'TraceabilityDriver','mxArray');
    p.AccessFlags.Serialize='off';

    p=schema.prop(this,'DownstreamIntegrationDriver','mxArray');
    p.AccessFlags.Serialize='off';

    p=schema.prop(this,'WorkflowAdvisorDriver','mxArray');
    p.AccessFlags.Serialize='off';

    p=schema.prop(this,'IncrementalCodeGenDriver','mxArray');
    p.AccessFlags.Serialize='off';

    p=schema.prop(this,'TargetCodeGenerationDriver','mxArray');
    p.AccessFlags.Serialize='off';

    p=schema.prop(this,'logInfo','mxArray');
    set(p,'FactoryValue',{});

    schema.prop(this,'cgInfo','mxArray');

    schema.method(this,'initLintScript','static');
    schema.method(this,'addCGIRCheck','static');
    schema.method(this,'addCheckCurrentDriver','static');
    schema.method(this,'reportToMessageViewer','static');
    schema.method(this,'i18nParameterChecks','static');


    p=schema.prop(this,'NeedToGenerateHTMLReport','mxArray');
    p.FactoryValue=true;



    p=schema.prop(this,'ChecksCatalog','mxArray');
    p.FactoryValue=containers.Map();


    p=schema.prop(this,'TestbenchChecksCatalog','mxArray');
    p.FactoryValue=containers.Map();


    p=schema.prop(this,'WebBrowserHandles','mxArray');
    p.FactoryValue=containers.Map();


    p=schema.prop(this,'nfp_stats','mxArray');
    p.FactoryValue=containers.Map();


    p=schema.prop(this,'cache_tunableparam','mxArray');
    p.FactoryValue=containers.Map('KeyType','char','ValueType','any');
    p.AccessFlags.Serialize='off';


    p=schema.prop(this,'CalledFromMakehdl','mxArray');
    p.FactoryValue=true;


    schema.prop(this,'HasDspba','bool');

    p=schema.prop(this,'AllowBlockAsDUT','bool');
    p.factoryValue=false;


    p=schema.prop(this,'hasMatrixPortAtDUT','bool');
    p.factoryValue=false;


    pkg=findpackage('embedded');%#ok<NASGU>


    function cp=get_coderparameters(this,~)
        cp=struct(this.CoderParameterObject.INI);



