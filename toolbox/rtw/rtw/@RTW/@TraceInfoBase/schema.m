function schema








    hCreateInPkg=findpackage('RTW');


    hPackage=findpackage('DAStudio');
    hBaseClass=findclass(hPackage,'Object');


    hThisClass=schema.class(hCreateInPkg,'TraceInfoBase',hBaseClass);






    hThisProp=schema.prop(hThisClass,'Model','string');
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'BuildDir','ustring');
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'BuildDirRoot','ustring');
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'Registry','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'RegistrySidMap','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'UseWidget','bool');
    hThisProp.Visible='off';
    hThisProp.FactoryValue=ispc;
    if~ispc
        hThisProp.AccessFlags.PublicSet='off';
    end

    hThisProp=schema.prop(hThisClass,'DisplayErrorInBrowser','bool');
    hThisProp.FactoryValue=true;
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'LastWarning','MATLAB array');
    hThisProp.FactoryValue={};
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'SourceSystem','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'TmpModel','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ModelVersionAtBuild','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ModelDirtyAtBuild','bool');
    hThisProp.FactoryValue=false;
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ModelFileNameAtBuild','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'GeneratedFiles','MATLAB array');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'TimeStamp','double');
    hThisProp.FactoryValue=0.0;
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ModifiedTimeStamp','double');
    hThisProp.FactoryValue=0.0;
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ReducedBlocks','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'InsertedBlocks','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'RelativeBuildDir','ustring');
    hThisProp.FactoryValue='';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ModelRefRelativeBuildDir','ustring');
    hThisProp.FactoryValue='';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ViewWidget','handle');
    hThisProp.FactoryValue=[];


    hThisProp=schema.prop(hThisClass,'FeatureDetectBuildDir','bool');
    hThisProp.FactoryValue=true;
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';


    hThisProp=schema.prop(hThisClass,'FeatureSubsysHighlight','bool');
    hThisProp.FactoryValue=false;
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';



    hThisProp=schema.prop(hThisClass,'FeatureResetRtwctagsRegistry','bool');
    hThisProp.FactoryValue=false;
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';

    hThisProp=schema.prop(hThisClass,'SystemMap','MATLAB array');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ReuseInfo','MATLAB array');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ReuseMap','MATLAB array');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'HighlightColor','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'FontSize','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';

    if isempty(findtype('RTWTraceTargetChoices'))
        targetChoices={'rtw','hdl','plc'};
        schema.EnumType('RTWTraceTargetChoices',...
        targetChoices);
    end

    hThisProp=schema.prop(hThisClass,'Target','RTWTraceTargetChoices');
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'HelpMethod','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'CheckModelTimeStamp','bool');
    hThisProp.FactoryValue=true;
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';

    hThisProp=schema.prop(hThisClass,'CheckTimeStampOneFileOnly','bool');
    hThisProp.FactoryValue=false;
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'CurrentModelReferenceTargetType','string');
    hThisProp.FactoryValue='';
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.Visible='off';


    hThisProp=schema.prop(hThisClass,'IsTestHarness','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'HarnessName','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'HarnessOwner','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'OwnerFileName','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'BlockReductionReasons','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'ReductionReasonIsCached','bool');
    hThisProp.FactoryValue=false;
    hThisProp.Visible='off';









    hThisMethod=schema.method(hThisClass,'datenum2timestamp','static');%#ok<NASGU>
    hThisMethod=schema.method(hThisClass,'htmlExportTraceLaunch','static');%#ok<NASGU>


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'dialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'postApplyCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'registryErrorHandler');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getInlineTrace');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'mergeInlineTrace');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'cacheBlockReductionReasons');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getBlockReductionReasons');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getRegistryWithScope');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    hThisProp=schema.prop(hThisClass,'inlineTraceIsMerged','bool');
    hThisProp.FactoryValue=false;
    hThisProp.Visible='off';

