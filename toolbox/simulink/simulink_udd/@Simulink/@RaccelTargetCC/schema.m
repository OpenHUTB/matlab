function schema()





    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomTargetCC');


    hThisClass=schema.class(hCreateInPackage,'RaccelTargetCC',hDeriveFromClass);



    if isempty(findtype('CONFIG_TARGET_RSIM_SOLVERSELECTION_ENUM'))
        schema.EnumType('CONFIG_TARGET_RSIM_SOLVERSELECTION_ENUM',...
        {'Auto','UseSolverModule','UseFixStep'},[1,2,3]);
    end
    hThisProp=add_prop(hThisClass,'RSIM_SOLVER_SELECTION',...
    'CONFIG_TARGET_RSIM_SOLVERSELECTION_ENUM');
    hThisProp.FactoryValue='UseSolverModule';

    hThisProp=add_prop(hThisClass,'PCMatlabRoot','string');

    hThisProp.FactoryValue=strrep(matlabroot,'\','\\');
    hThisProp.AccessFlags.Serialize='off';

    hThisProp=add_prop(hThisClass,'ExtMode','on/off');
    hThisProp.FactoryValue='on';

    hThisProp=add_prop(hThisClass,'ExtModeTransport','slint');
    hThisProp.FactoryValue=0;

    hThisProp=add_prop(hThisClass,'ExtModeStaticAlloc','on/off');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'ExtModeStaticAllocSize','slint');
    hThisProp.FactoryValue=1000000;

    hThisProp=add_prop(hThisClass,'ExtModeTesting','on/off');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'ExtModeMexFile','ustring');
    hThisProp.FactoryValue='ext_comm';

    hThisProp=add_prop(hThisClass,'ExtModeMexArgs','ustring');
    hThisProp.FactoryValue='';

    hThisProp=add_prop(hThisClass,'ExtModeIntrfLevel','ustring');
    hThisProp.FactoryValue='Level1';

    hThisProp=add_prop(hThisClass,'ENABLE_SLEXEC_SSBRIDGE','slint');
    hThisProp.FactoryValue=0;

    hThisProp=add_prop(hThisClass,'RSIM_PARAMETER_LOADING','on/off');
    hThisProp.FactoryValue='on';

    hThisProp=add_prop(hThisClass,'RSIM_STORAGE_CLASS_AUTO','on/off');
    hThisProp.FactoryValue='on';

    hThisProp=add_prop(hThisClass,'RTWCAPISignals','slbool');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'RTWCAPIParams','slbool');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'RTWCAPIStates','slbool');
    hThisProp.FactoryValue='off';

    hThisProp=add_prop(hThisClass,'RTWCAPIRootIO','slbool');
    hThisProp.FactoryValue='off';

    hPreSetListener=handle.listener(hThisClass,hThisClass.Properties,'PropertyPreSet',...
    @preSetFcn_Prop);
    add_prop(hThisProp,'PreSetListener','handle');
    hThisProp.PreSetListener=hPreSetListener;



    m=schema.method(hThisClass,'getStringFormat');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getMdlRefComplianceTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','Sl_MdlRefTarget_EnumType'};
    s.OutputTypes={'MATLAB array'};




    function preSetFcn_Prop(hProp,eventData)

        hObj=eventData.AffectedObject;
        if~isequal(get(hObj,hProp.Name),eventData.NewVal)
            hObj.dirtyHostBD;
        end

        function p=add_prop(h,name,type)

            p=Simulink.TargetCCProperty(h,name,type);
            p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');


