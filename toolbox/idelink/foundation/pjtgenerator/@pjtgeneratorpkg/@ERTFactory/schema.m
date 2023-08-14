function schema()





    hCreateInPackage=findpackage('pjtgeneratorpkg');
    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ERTTargetCC');
    hThisClass=schema.class(hCreateInPackage,'ERTFactory',hDeriveFromClass);


    hThisProp=add_prop(hThisClass,'ProjectMgr','mxArray');
    hThisProp.FactoryValue=[];
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';


    hThisProp=add_prop(hThisClass,'AdaptorName','string');
    hThisProp.FactoryValue='';

    hThisProp=add_prop(hThisClass,'exportIDEObj','on/off');
    hThisProp.FactoryValue='on';

    hThisProp=add_prop(hThisClass,'ideObjName','string');
    hThisProp.FactoryValue='IDE_Obj';

    hThisProp=add_prop(hThisClass,'oldideObjName','string');
    hThisProp.FactoryValue='IDE_Obj';

    hThisProp=add_prop(hThisClass,'ideObjTimeout','double');
    hThisProp.FactoryValue=10;

    hThisProp=add_prop(hThisClass,'oldideObjTimeout','double');
    hThisProp.FactoryValue=10;

    hThisProp=add_prop(hThisClass,'ideObjBuildTimeout','double');
    hThisProp.FactoryValue=1000;

    hThisProp=add_prop(hThisClass,'oldideObjBuildTimeout','double');
    hThisProp.FactoryValue=1000;

    hThisProp=add_prop(hThisClass,'TargetPrefTimeStamp','string');
    hThisProp.FactoryValue=datestr(now);

    hThisProp=add_prop(hThisClass,'ProfileGenCode','on/off');
    hThisProp.FactoryValue='off';

    if isempty(findtype('CONFIG_profileBy_ENUM'))
        schema.EnumType('CONFIG_profileBy_ENUM',{'Tasks','Atomic subsystems'},[0,1]);
    end
    hThisProp=add_prop(hThisClass,'profileBy','CONFIG_profileBy_ENUM');
    hThisProp.FactoryValue='Tasks';

    hThisProp=add_prop(hThisClass,'ProfileNumSamples','double');
    hThisProp.FactoryValue=100;

    hThisProp=add_prop(hThisClass,'InlineDSPBlks','on/off');
    hThisProp.FactoryValue='off';

    if isempty(findtype('CONFIG_projectOptions_ENUM'))
        schema.EnumType('CONFIG_projectOptions_ENUM',{'Debug','Release','Custom'},[0,1,2]);
    end
    hThisProp=add_prop(hThisClass,'projectOptions','CONFIG_projectOptions_ENUM');
    hThisProp.FactoryValue='Custom';

    hThisProp=add_prop(hThisClass,'debugCompilerOptions','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';

    hThisProp=add_prop(hThisClass,'releaseCompilerOptions','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';

    hThisProp=add_prop(hThisClass,'customCompilerOptions','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';

    hThisProp=add_prop(hThisClass,'compilerOptionsStr','string');
    hThisProp.FactoryValue='';

    hThisProp=add_prop(hThisClass,'getCompilerOptions','on/off');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'resetCompilerOptions','on/off');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'debugLinkerOptions','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';

    hThisProp=add_prop(hThisClass,'releaseLinkerOptions','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';

    hThisProp=add_prop(hThisClass,'customLinkerOptions','string');
    hThisProp.FactoryValue='';
    hThisProp.Visible='off';

    hThisProp=add_prop(hThisClass,'linkerOptionsStr','string');
    hThisProp.FactoryValue='';

    hThisProp=add_prop(hThisClass,'getLinkerOptions','on/off');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'resetLinkerOptions','on/off');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'systemStackSize','double');
    hThisProp.FactoryValue=512;

    hThisProp=add_prop(hThisClass,'systemHeapSize','double');
    hThisProp.FactoryValue=512;

    if isempty(findtype('CONFIG_buildFormat_ENUM'))
        schema.EnumType('CONFIG_buildFormat_ENUM',{'Project','Makefile'},[0,1]);
    end
    hThisProp=add_prop(hThisClass,'buildFormat','CONFIG_buildFormat_ENUM');
    hThisProp.FactoryValue='Project';

    if isempty(findtype('CONFIG_IDELINK_buildAction_ENUM'))
        schema.EnumType('CONFIG_IDELINK_buildAction_ENUM',...
        {'Create','Archive_library','Build','Build_and_execute','Create_Processor_In_the_Loop_project'},[0,1,2,3,4]);
    end
    hThisProp=add_prop(hThisClass,'buildAction',...
    'CONFIG_IDELINK_buildAction_ENUM');
    hThisProp.FactoryValue='Create';

    if isempty(findtype('CONFIG_overrunNotificationMethod_ENUM'))
        schema.EnumType('CONFIG_overrunNotificationMethod_ENUM',...
        {'None','Print_message','Call_custom_function'},[0,1,2]);
    end
    hThisProp=add_prop(hThisClass,'overrunNotificationMethod',...
    'CONFIG_overrunNotificationMethod_ENUM');
    hThisProp.FactoryValue='None';

    hThisProp=add_prop(hThisClass,'overrunNotificationFcn','string');
    hThisProp.FactoryValue='myfunction';

    hThisProp=add_prop(hThisClass,'oldoverrunNotificationFcn','string');
    hThisProp.FactoryValue='myfunction';



    hThisProp=add_prop(hThisClass,'configurePIL','on/off');
    hThisProp.FactoryValue='off';

    if isempty(findtype('CONFIG_pilblockAction_ENUM'))
        schema.EnumType('CONFIG_pilblockAction_ENUM',...
        {'None','Create_PIL_block','Create_PIL_block_build_and_download'},[0,1,2]);
    end
    hThisProp=add_prop(hThisClass,'configPILBlockAction',...
    'CONFIG_pilblockAction_ENUM');
    hThisProp.FactoryValue='Create_PIL_block_build_and_download';

    hThisProp=schema.prop(hThisClass,'TargetResourceManagerActiveTab','int');
    set(hThisProp,'FactoryValue',0,'Visible','off');


    hPreSetListener=handle.listener(hThisClass,hThisClass.Properties,'PropertyPreSet',...
    @preSetFcn_Prop);
    add_prop(hThisProp,'PreSetListener','handle');
    hThisProp.PreSetListener=hPreSetListener;



    m=schema.method(hThisClass,'tgtDialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getTagPrefix');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    if isempty(findtype('CONFIG_DiagnosticActions_ENUM'))
        schema.EnumType('CONFIG_DiagnosticActions_ENUM',...
        {'none','warning','error'},[0,1,2]);
    end



    hThisProp=add_prop(hThisClass,'DiagnosticActions',...
    'CONFIG_DiagnosticActions_ENUM');
    hThisProp.FactoryValue='warning';




    function preSetFcn_Prop(hProp,eventData)

        hObj=eventData.AffectedObject;
        if~isequal(get(hObj,hProp.Name),eventData.NewVal)
            hObj.dirtyHostBD;
        end

        function p=add_prop(h,name,type)

            p=Simulink.TargetCCProperty(h,name,type);
            p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
